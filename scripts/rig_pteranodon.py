import json
import math
import struct
from pathlib import Path

from rig_triceratops import quaternion, smooth


ROOT = Path(__file__).resolve().parents[1]


def wing_rotation(pitch, flap):
    p, f = pitch / 2, flap / 2
    return (math.sin(p) * math.cos(f), -math.sin(p) * math.sin(f),
            math.cos(p) * math.sin(f), math.cos(p) * math.cos(f))


def build():
    source = (ROOT / "art/fal/pteranodon-source.glb").read_bytes()
    assert source[:4] == b"glTF" and struct.unpack_from("<I", source, 4)[0] == 2
    json_length = struct.unpack_from("<I", source, 12)[0]
    document = json.loads(source[20:20 + json_length])
    binary = bytearray(source[28 + json_length:])
    assert len(document["nodes"]) == 1 and set(document["nodes"][0]) == {"name", "mesh"}
    assert len(document["meshes"]) == 1 and len(document["meshes"][0]["primitives"]) == 1
    primitive = document["meshes"][0]["primitives"][0]
    assert primitive.get("mode", 4) == 4
    assert document["materials"][primitive["material"]]["pbrMetallicRoughness"]["baseColorTexture"]

    def read(index):
        accessor = document["accessors"][index]
        view = document["bufferViews"][accessor["bufferView"]]
        assert accessor["componentType"] == 5126 and "byteStride" not in view
        width = {"VEC3": 3, "VEC4": 4}[accessor["type"]]
        start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
        return list(struct.iter_unpack("<" + "f" * width, binary[start:start + accessor["count"] * width * 4]))

    def append(values, kind, component=5126):
        width = {"SCALAR": 1, "VEC3": 3, "VEC4": 4, "MAT4": 16}[kind]
        binary.extend(b"\0" * (-len(binary) % 4))
        offset = len(binary)
        for row in values:
            binary.extend(struct.pack("<" + ("f" if component == 5126 else "H") * width, *row))
        view_index = len(document["bufferViews"])
        document["bufferViews"].append({"buffer": 0, "byteOffset": offset, "byteLength": len(binary) - offset})
        accessor = {"bufferView": view_index, "componentType": component, "count": len(values), "type": kind}
        if kind != "MAT4":
            accessor["min"] = [min(row[i] for row in values) for i in range(width)]
            accessor["max"] = [max(row[i] for row in values) for i in range(width)]
        document["accessors"].append(accessor)
        return len(document["accessors"]) - 1

    positions = read(primitive["attributes"]["POSITION"])
    floor = min(p[1] for p in positions)
    span = max(p[2] for p in positions) - min(p[2] for p in positions)
    scale = 2.2 / span
    positions = [(z * scale, (y - floor) * scale + 0.5, -x * scale) for x, y, z in positions]
    primitive["attributes"]["POSITION"] = append(positions, "VEC3")
    primitive["attributes"]["NORMAL"] = append([(z, y, -x) for x, y, z in read(primitive["attributes"]["NORMAL"])], "VEC3")
    if "TANGENT" in primitive["attributes"]:
        primitive["attributes"]["TANGENT"] = append([(z, y, -x, w) for x, y, z, w in read(primitive["attributes"]["TANGENT"])], "VEC4")
    nodes = [{"name": "Pteranodon", "children": [1, 2]}, {"name": "Mesh", "mesh": 0, "skin": 0}]
    joints, rests = [], []

    def bone(name, position, parent=None):
        index = len(nodes)
        joints.append(index)
        rests.append(position)
        origin = rests[joints.index(parent)] if parent is not None else (0, 0, 0)
        nodes.append({"name": name, "translation": [position[i] - origin[i] for i in range(3)]})
        if parent is not None:
            nodes[parent].setdefault("children", []).append(index)
        return index

    root = bone("Root", (0, 0, 0))
    body = bone("Body", (0, 1.0, 0.1), root)
    head = bone("Head", (0, 1.53, -0.36), body)
    tail = bone("Tail", (0, 1.0, 0.4), body)
    legs = [bone("LeftLeg" if side < 0 else "RightLeg", (side * 0.15, 0.94, 0.05), body) for side in [-1, 1]]
    wings = []
    for name, side in [("Left", -1), ("Right", 1)]:
        shoulder = bone(name + "Wing", (side * 0.18, 1.30, 0.0), body)
        tip = bone(name + "WingTip", (side * 0.65, 1.48, -0.14), shoulder)
        wings.append((side, shoulder, tip))

    vertex_joints, weights = [], []
    for x, y, z in positions:
        _, wing, tip = wings[0 if x < 0 else 1]
        leg = legs[0 if x < 0 else 1]
        leg_weight = (1 - smooth(0.83, 1.04, y)) * (1 - smooth(0.10, 0.32, z)) * smooth(0.055, 0.11, abs(x))
        wing_weight = smooth(0.12, 0.30, abs(x)) * smooth(1.05, 1.20, y)
        tip_weight = smooth(0.48, 0.86, abs(x)) * wing_weight
        head_weight = smooth(1.20, 1.48, y) * (1 - smooth(0.0, 0.28, z)) * (1 - wing_weight)
        tail_weight = smooth(0.15, 0.45, z) * (1 - leg_weight) * (1 - wing_weight - head_weight)
        influences = [(body, 1 - wing_weight - head_weight - leg_weight - tail_weight), (head, head_weight),
                      (wing, wing_weight - tip_weight), (tip, tip_weight), (leg, leg_weight), (tail, tail_weight)]
        influences = sorted(influences, key=lambda item: item[1], reverse=True)[:4]
        total = sum(weight for _, weight in influences)
        vertex_joints.append(tuple(joints.index(joint) for joint, _ in influences))
        weights.append(tuple(weight / total for _, weight in influences))
    assert all(min(row) >= -1e-6 and abs(sum(row) - 1) < 1e-6 for row in weights)
    primitive["attributes"]["JOINTS_0"] = append(vertex_joints, "VEC4", 5123)
    primitive["attributes"]["WEIGHTS_0"] = append(weights, "VEC4")
    inverse_bind = [(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -x, -y, -z, 1) for x, y, z in rests]
    document["nodes"] = nodes
    document["scenes"] = [{"nodes": [0]}]
    document["scene"] = 0
    document["skins"] = [{"name": "Pterosaur", "joints": joints, "skeleton": root, "inverseBindMatrices": append(inverse_bind, "MAT4")}]
    document["animations"] = []
    for name, length in [("run", 0.9), ("idle", 1.3)]:
        times = [i * length / 64 for i in range(65)]
        time_accessor = append([(t,) for t in times], "SCALAR")
        animation = {"name": name + "-loop", "channels": [], "samplers": []}

        def track(joint, path, values):
            sampler = len(animation["samplers"])
            animation["samplers"].append({"input": time_accessor, "output": append(values, "VEC4" if path == "rotation" else "VEC3"), "interpolation": "LINEAR"})
            animation["channels"].append({"sampler": sampler, "target": {"node": joint, "path": path}})

        track(root, "translation", [(0, 0.055 * math.sin(t / length * math.tau - 0.5), 0) for t in times])
        pitch = -math.pi / 2
        track(body, "translation", [(0, 1.35, 0.1) for _ in times])
        track(body, "rotation", [quaternion(pitch) for _ in times])
        track(head, "translation", [(0, 0.65, -0.1) for _ in times])
        track(head, "rotation", [quaternion(-pitch + 0.025 * math.sin(t / length * math.tau - 0.35)) for t in times])
        track(tail, "translation", [(0, 0, 0.02) for _ in times])
        track(tail, "rotation", [quaternion(-pitch) for _ in times])
        for side, leg in zip([-1, 1], legs):
            track(leg, "translation", [(side * 0.10, -0.06, -0.05) for _ in times])
            track(leg, "rotation", [quaternion(-0.35) for _ in times])
        for side, shoulder, tip in wings:
            amplitude = 0.44 if name == "run" else 0.32
            track(shoulder, "rotation", [wing_rotation(-pitch, side * (0.10 + amplitude * math.sin(t / length * math.tau))) for t in times])
            track(tip, "rotation", [quaternion(side * 0.14 * math.sin(t / length * math.tau - 0.65), 2) for t in times])
        document["animations"].append(animation)
    document["asset"]["generator"] = "Tripo H3.1 + scripts/rig_pteranodon.py"
    document["buffers"] = [{"byteLength": len(binary)}]
    encoded = json.dumps(document, separators=(",", ":")).encode()
    encoded += b" " * (-len(encoded) % 4)
    binary.extend(b"\0" * (-len(binary) % 4))
    output = struct.pack("<4sII", b"glTF", 2, 28 + len(encoded) + len(binary))
    output += struct.pack("<I4s", len(encoded), b"JSON") + encoded
    output += struct.pack("<I4s", len(binary), b"BIN\0") + binary
    (ROOT / "game/assets/pteranodon.glb").write_bytes(output)
    print(f"pteranodon: {len(joints)} bones, flight + hover, {len(positions)} vertices, {len(output)} bytes.")


if __name__ == "__main__":
    build()
