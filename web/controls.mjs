export function keyDirection(key, mode) {
  if (key === 'ArrowLeft' || key === 'ArrowRight') return [mode === 'coop' ? 2 : 1, key === 'ArrowLeft' ? 'left' : 'right'];
  if (mode === 'coop' && ['a', 'd'].includes(key.toLowerCase())) return [1, key.toLowerCase() === 'a' ? 'left' : 'right'];
  return null;
}

export class SteeringInputs {
  constructor(send) {
    this.send = send;
    this.sources = new Map();
  }

  held(slot, direction) {
    return [...this.sources.values()].some(value => value.slot === slot && value.direction === direction);
  }

  set(source, slot, direction, pressed) {
    const before = this.held(slot, direction);
    if (pressed) this.sources.set(source, { slot, direction });
    else this.sources.delete(source);
    const after = this.held(slot, direction);
    if (before !== after) this.send(`input:${slot}:${direction}:${after ? 'down' : 'up'}:page`);
  }

  clear() {
    this.sources.clear();
    this.send('release');
  }
}
