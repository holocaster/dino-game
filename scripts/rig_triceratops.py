import json
import math
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art/fal/triceratops-source.glb"
OUTPUT = ROOT / "game/assets/triceratops.glb"
CYCLE = 0.8
STANCE = 0.65
STRIDE = 0.44
RUN_STANCE = 0.60
RUN_STRIDE = 0.52


def smooth(low, high, value):
    t = max(0, min(1, (value - low) / (high - low)))
    return t * t * (3 - 2 * t)


def quaternion(angle, axis=0):
    result = [0, 0, 0, math.cos(angle / 2)]
    result[axis] = math.sin(angle / 2)
    return result


def foot_offset(phase, stride=STRIDE, stance=STANCE):
    phase %= 1
    if phase < stance:
        return 0, stride * (phase / stance - 0.5)
    swing = (phase - stance) / (1 - stance)
    easing = swing ** 3 * (10 - 15 * swing + 6 * swing ** 2)
    follow_through = (1 - stance) / stance
    lift = 0.12 * 64 * swing ** 3 * (1 - swing) ** 3
    reach = stride * (0.5 + follow_through * swing - (1 + follow_through) * easing)
    return lift, reach


def run_height(phase):
    return -0.07 + 0.012 * math.cos((phase - RUN_STANCE / 2) * math.tau * 2)


def leg_angles(hip, knee, foot, lift, stride):
    dy, dz = foot[1] + lift - hip[1], foot[2] + stride - hip[2]
    upper = math.hypot(knee[1] - hip[1], knee[2] - hip[2])
    lower = math.hypot(foot[1] - knee[1], foot[2] - knee[2])
    distance = math.hypot(dy, dz)
    assert abs(upper - lower) < distance < upper + lower
    along = (upper * upper - lower * lower + distance * distance) / (2 * distance)
    across = math.sqrt(max(0, upper * upper - along * along))
    ky = (along * dy + across * dz) / distance
    kz = (along * dz - across * dy) / distance
    hip_angle = math.atan2(kz, ky) - math.atan2(knee[2] - hip[2], knee[1] - hip[1])
    lower_angle = math.atan2(dz - kz, dy - ky) - math.atan2(foot[2] - knee[2], foot[1] - knee[1])
    return hip_angle, lower_angle - hip_angle, -lower_angle


def build():
    source = SOURCE.read_bytes()
    assert source[:4] == b"glTF" and struct.unpack_from("<I", source, 4)[0] == 2
    json_length = struct.unpack_from("<I", source, 12)[0]
    document = json.loads(source[20:20 + json_length])
    binary = bytearray(source[28 + json_length:])
    assert len(document["nodes"]) == 1 and document["nodes"][0] == {
        "name": "tripo_node_c86264e4-57fa-4d43-b3a9-6f2699b3afd7", "mesh": 0
    }
    primitive = document["meshes"][0]["primitives"][0]

    def read(index):
        accessor = document["accessors"][index]
        view = document["bufferViews"][accessor["bufferView"]]
        assert accessor["componentType"] == 5126 and "byteStride" not in view
        count = {"VEC3": 3, "VEC2": 2}[accessor["type"]]
        start = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
        return list(struct.iter_unpack("<" + "f" * count, binary[start:start + accessor["count"] * count * 4]))

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
    yaw = 1.213028068984582

    def rotate(x, y, z):
        return x * math.cos(yaw) + z * math.sin(yaw), y, -x * math.sin(yaw) + z * math.cos(yaw)

    positions = [tuple(v * scale for v in rotate(x - 0.01927003, y - floor, z - 0.02363447)) for x, y, z in positions]
    primitive["attributes"]["POSITION"] = append(positions, "VEC3")
    primitive["attributes"]["NORMAL"] = append([rotate(*p) for p in read(primitive["attributes"]["NORMAL"])], "VEC3")
    nodes = [{"name": "Triceratops", "children": [1, 2]}, {"name": "Mesh", "mesh": 0, "skin": 0}]
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
    body = bone("Body", (0, 0.73, 0), root)
    head = bone("Head", (0, 0.91, -0.35), body)
    tail = bone("Tail", (-0.12, 0.69, 0.47), body)
    legs = []
    for name, x, z, phase, run_phase in [
        ("HindLeft", -0.3350, 0.3838, 0.0, 0.0),
        ("HindRight", 0.3350, 0.3604, 0.5, 0.5),
        ("FrontLeft", -0.2535, -0.4017, 0.75, 0.5),
        ("FrontRight", 0.2535, -0.3426, 0.25, 0.0),
    ]:
        hip_position = (x, 0.60, z)
        knee_position = (x, 0.335, z + 0.15)
        foot_position = (x, 0.07, z)
        hip = bone(name + "Hip", hip_position, root)
        knee = bone(name + "Knee", knee_position, hip)
        foot = bone(name + "Foot", foot_position, knee)
        legs.append((hip, knee, foot, hip_position, knee_position, foot_position, phase, run_phase))

    vertex_joints, weights = [], []
    for x, y, z in positions:
        leg = min(legs, key=lambda leg: (x - leg[5][0]) ** 2 + (z - leg[5][2]) ** 2)
        hip, knee, foot, hp, kp, fp, phase, run_phase = leg
        radius = math.hypot(x - hp[0], z - hp[2])
        leg_weight = (1 - smooth(0.39, 0.67, y)) * (1 - smooth(0.22, 0.36, radius))
        foot_weight = 1 - smooth(0.15, 0.29, y)
        hip_weight = smooth(0.31, 0.50, y)
        knee_weight = 1 - foot_weight - hip_weight
        head_weight = (1 - smooth(-0.39, -0.18, z)) * smooth(0.52, 0.73, y)
        tail_weight = smooth(0.49, 0.81, z) * smooth(0.40, 0.58, y)
        torso_joint = head if head_weight > tail_weight else tail
        torso_weight = max(head_weight, tail_weight) * (1 - leg_weight)
        influences = [(body, 1 - leg_weight - torso_weight), (torso_joint, torso_weight),
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
    document["skins"] = [{"name": "Quadruped", "joints": joints, "skeleton": root, "inverseBindMatrices": append(inverse_bind, "MAT4")}]
    document["animations"] = []
    for name, length in [("walk", CYCLE), ("run", CYCLE), ("idle", 3.2)]:
        times = [i * length / 64 for i in range(65)]
        time_accessor = append([(t,) for t in times], "SCALAR")
        animation = {"name": name + "-loop", "channels": [], "samplers": []}

        def track(joint, path, values):
            sampler = len(animation["samplers"])
            animation["samplers"].append({"input": time_accessor, "output": append(values, "VEC4" if path == "rotation" else "VEC3"), "interpolation": "LINEAR"})
            animation["channels"].append({"sampler": sampler, "target": {"node": joint, "path": path}})

        heights = [run_height(t / length) if name == "run" else 0 for t in times]
        track(root, "translation", [(0, height, 0) for height in heights])
        for hip, knee, foot, hp, kp, fp, phase, run_phase in legs:
            angles = []
            for t, height in zip(times, heights):
                if name == "idle":
                    angles.append((0, 0, 0))
                    continue
                stride, stance, offset = (RUN_STRIDE, RUN_STANCE, run_phase) if name == "run" else (STRIDE, STANCE, phase)
                leg_phase = (t / length + offset) % 1
                lift, reach = foot_offset(leg_phase, stride, stance)
                hip_angle, knee_angle, foot_angle = leg_angles(hp, kp, fp, lift - height, reach)
                if name == "run" and leg_phase > stance:
                    foot_angle += 0.14 * math.sin(math.pi * (leg_phase - stance) / (1 - stance)) ** 3
                angles.append((hip_angle, knee_angle, foot_angle))
            for axis_index, joint in enumerate((hip, knee, foot)):
                track(joint, "rotation", [quaternion(a[axis_index]) for a in angles])
        track(body, "rotation", [quaternion(math.sin(t / length * math.tau) * 0.016 if name == "run" else 0, 2) for t in times])
        track(head, "rotation", [quaternion(math.sin(t / length * math.tau - (0.35 if name == "run" else 0)) * (0.04 if name == "run" else 0.025)) for t in times])
        track(tail, "rotation", [quaternion(math.sin(t / length * math.tau - (0.6 if name == "run" else 0)) * (0.09 if name == "run" else 0.07), 1) for t in times])
        track(body, "scale", [(1 + math.sin(t / length * math.tau) * 0.008, 1, 1) for t in times])
        document["animations"].append(animation)
    document["asset"]["generator"] = "Tripo H3.1 + scripts/rig_triceratops.py"
    document["asset"]["extras"] = {"walk_speed": STRIDE / (STANCE * CYCLE), "walk_cycle": CYCLE, "stance_fraction": STANCE, "run_speed": RUN_STRIDE / (RUN_STANCE * CYCLE), "run_stride": RUN_STRIDE, "run_stance_fraction": RUN_STANCE, "height": 1.45}
    document["buffers"] = [{"byteLength": len(binary)}]
    encoded = json.dumps(document, separators=(",", ":")).encode()
    encoded += b" " * (-len(encoded) % 4)
    binary.extend(b"\0" * (-len(binary) % 4))
    output = struct.pack("<4sII", b"glTF", 2, 28 + len(encoded) + len(binary))
    output += struct.pack("<I4s", len(encoded), b"JSON") + encoded
    output += struct.pack("<I4s", len(binary), b"BIN\0") + binary
    OUTPUT.write_bytes(output)
    print(f"Triceratops: {len(joints)} bones, walk + run + idle, {len(output)} bytes.")


if __name__ == "__main__":
    build()
