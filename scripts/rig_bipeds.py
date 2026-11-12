import json
import math
import struct
from pathlib import Path

from rig_triceratops import CYCLE, foot_offset, leg_angles, quaternion, smooth


ROOT = Path(__file__).resolve().parents[1]
RUN_STRIDE = 0.40
RUN_STANCE = 0.50
CALIBRATION = {
    "trex": {"center_z": 0.21, "hip_y": 0.53, "foot_z": 0.0, "head": (0, 0.86, -0.18), "tail_y": 0.40},
    "raptor": {"center_z": 0.24, "hip_y": 0.53, "foot_z": -0.03, "head": (0, 0.82, -0.25), "tail_y": 0.48},
}


def build(species):
    calibration = CALIBRATION[species]
    source = (ROOT / f"art/fal/{species}-source.glb").read_bytes()
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
    scale = 1.45 / (max(p[1] for p in positions) - floor)
    positions = [(z * scale, (y - floor) * scale, -x * scale + calibration["center_z"]) for x, y, z in positions]
    primitive["attributes"]["POSITION"] = append(positions, "VEC3")
    primitive["attributes"]["NORMAL"] = append([(z, y, -x) for x, y, z in read(primitive["attributes"]["NORMAL"])], "VEC3")
    if "TANGENT" in primitive["attributes"]:
        primitive["attributes"]["TANGENT"] = append([(z, y, -x, w) for x, y, z, w in read(primitive["attributes"]["TANGENT"])], "VEC4")
    nodes = [{"name": species.capitalize(), "children": [1, 2]}, {"name": "Mesh", "mesh": 0, "skin": 0}]
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
    body = bone("Body", (0, 0.64, 0.03), root)
    head = bone("Head", calibration["head"], body)
    tail = bone("Tail", (0, calibration["tail_y"], 0.34), body)
    arms = [bone("LeftArm" if side < 0 else "RightArm", (side * 0.20, 0.78, -0.18), body) for side in [-1, 1]]
    legs = []
    for name, side, phase in [("Left", -1, 0.0), ("Right", 1, 0.5)]:
        hp = (side * 0.26, calibration["hip_y"], 0.0)
        kp = (side * 0.26, 0.30, 0.13)
        fp = (side * 0.26, 0.07, calibration["foot_z"])
        hip = bone(name + "Hip", hp, root)
        knee = bone(name + "Knee", kp, hip)
        foot = bone(name + "Foot", fp, knee)
        legs.append((hip, knee, foot, hp, kp, fp, phase))

    vertex_joints, weights = [], []
    for x, y, z in positions:
        hip, knee, foot, hp, kp, fp, phase = legs[0 if x < 0 else 1]
        separation = 1 - smooth(0.10, 0.26, y) * (1 - smooth(0.10, 0.19, abs(x)))
        leg_weight = (1 - smooth(0.38, 0.65, y)) * separation * (1 - smooth(0.32, 0.50, abs(z - fp[2])))
        foot_weight = 1 - smooth(0.13, 0.25, y)
        hip_weight = smooth(0.28, 0.46, y)
        knee_weight = max(0, 1 - foot_weight - hip_weight)
        head_weight = smooth(0.76, 0.97, y) * (1 - smooth(0.12, 0.30, z)) * (1 - leg_weight)
        tail_weight = smooth(0.26, 0.55, z) * (1 - leg_weight - head_weight)
        arm = arms[0 if x < 0 else 1]
        arm_weight = 0.6 * smooth(0.16, 0.29, abs(x)) * smooth(0.55, 0.68, y) * (1 - smooth(0.88, 1.0, y)) * (1 - smooth(-0.13, 0.03, z))
        arm_weight *= 1 - leg_weight - head_weight - tail_weight
        influences = [(body, 1 - leg_weight - head_weight - tail_weight - arm_weight), (head, head_weight), (tail, tail_weight), (arm, arm_weight),
                      (hip, leg_weight * hip_weight), (knee, leg_weight * knee_weight), (foot, leg_weight * foot_weight)]
        influences = sorted(influences, key=lambda item: item[1], reverse=True)[:4]
        total = sum(weight for _, weight in influences)
        vertex_joints.append(tuple(joints.index(joint) for joint, _ in influences))
        weights.append(tuple(weight / total for _, weight in influences))
    assert all(min(row) >= 0 and abs(sum(row) - 1) < 1e-6 for row in weights)
    primitive["attributes"]["JOINTS_0"] = append(vertex_joints, "VEC4", 5123)
    primitive["attributes"]["WEIGHTS_0"] = append(weights, "VEC4")
    inverse_bind = [(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, -x, -y, -z, 1) for x, y, z in rests]
    document["nodes"] = nodes
    document["scenes"] = [{"nodes": [0]}]
    document["scene"] = 0
    document["skins"] = [{"name": "Biped", "joints": joints, "skeleton": root, "inverseBindMatrices": append(inverse_bind, "MAT4")}]
    document["animations"] = []
    for name, length in [("run", CYCLE), ("idle", 3.2)]:
        times = [i * length / 64 for i in range(65)]
        time_accessor = append([(t,) for t in times], "SCALAR")
        animation = {"name": name + "-loop", "channels": [], "samplers": []}

        def track(joint, path, values):
            sampler = len(animation["samplers"])
            animation["samplers"].append({"input": time_accessor, "output": append(values, "VEC4" if path == "rotation" else "VEC3"), "interpolation": "LINEAR"})
            animation["channels"].append({"sampler": sampler, "target": {"node": joint, "path": path}})

        heights = [-0.035 + 0.006 * math.cos((t / length - RUN_STANCE / 2) * math.tau * 2) if name == "run" else 0 for t in times]
        track(root, "translation", [(0, height, 0) for height in heights])
        for hip, knee, foot, hp, kp, fp, phase in legs:
            angles = []
            for t, height in zip(times, heights):
                if name == "idle":
                    angles.append((0, 0, 0))
                else:
                    lift, reach = foot_offset(t / length + phase, RUN_STRIDE, RUN_STANCE)
                    angles.append(leg_angles(hp, kp, fp, lift - height, reach))
            for axis_index, joint in enumerate((hip, knee, foot)):
                track(joint, "rotation", [quaternion(a[axis_index]) for a in angles])
        track(body, "rotation", [quaternion(math.sin(t / length * math.tau) * (0.018 if name == "run" else 0), 2) for t in times])
        track(head, "rotation", [quaternion(math.sin(t / length * math.tau - 0.35) * (0.025 if name == "run" else 0.018)) for t in times])
        track(tail, "rotation", [quaternion(math.sin(t / length * math.tau - 0.6) * (0.075 if name == "run" else 0.045), 1) for t in times])
        for side, arm in enumerate(arms):
            track(arm, "rotation", [quaternion(math.sin(t / length * math.tau + side * math.pi) * (0.09 if name == "run" else 0.015)) for t in times])
        document["animations"].append(animation)
    document["asset"]["generator"] = "Tripo H3.1 + scripts/rig_bipeds.py"
    document["asset"]["extras"] = {"height": 1.45, "run_speed": RUN_STRIDE / (RUN_STANCE * CYCLE), "run_stride": RUN_STRIDE, "run_stance_fraction": RUN_STANCE}
    document["buffers"] = [{"byteLength": len(binary)}]
    encoded = json.dumps(document, separators=(",", ":")).encode()
    encoded += b" " * (-len(encoded) % 4)
    binary.extend(b"\0" * (-len(binary) % 4))
    output = struct.pack("<4sII", b"glTF", 2, 28 + len(encoded) + len(binary))
    output += struct.pack("<I4s", len(encoded), b"JSON") + encoded
    output += struct.pack("<I4s", len(binary), b"BIN\0") + binary
    (ROOT / f"game/assets/{species}.glb").write_bytes(output)
    print(f"{species}: {len(joints)} bones, run + idle, {len(positions)} vertices, {len(output)} bytes.")


if __name__ == "__main__":
    for species in CALIBRATION:
        build(species)
