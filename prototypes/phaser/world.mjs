export function project(x, z) {
  return { x: 480 + (x - z) * 44, y: 310 + (x + z) * 22 };
}

export function unproject(x, y, bounds) {
  return {
    x: Math.max(-bounds, Math.min(bounds, (x - 480) / 88 + (y - 310) / 44)),
    z: Math.max(-bounds, Math.min(bounds, (y - 310) / 44 - (x - 480) / 88))
  };
}

export function stepToward(position, target, distance) {
  const dx = target.x - position.x;
  const dz = target.z - position.z;
  const length = Math.hypot(dx, dz);
  if (length <= distance || length === 0) return { ...target };
  return { x: position.x + dx / length * distance, z: position.z + dz / length * distance };
}
