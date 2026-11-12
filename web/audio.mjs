export class ParkAudio {
  constructor(context) {
    this.context = context;
    this.muted = false;
    this.paused = false;
    this.effects = new Set();
    this.nextBird = 0;
    this.master = context.createGain();
    this.master.gain.value = 0.22;
    this.master.connect(context.destination);
    this.noise = context.createBuffer(1, context.sampleRate * 4, context.sampleRate);
    const samples = this.noise.getChannelData(0);
    for (let i = 0; i < samples.length; i++) samples[i] = Math.random() * 2 - 1;
    [this.air, this.airFilter] = this.loop(350, 0.025);
    [this.water] = this.loop(1400, 0);
  }

  loop(frequency, volume) {
    const source = this.context.createBufferSource();
    source.buffer = this.noise;
    source.loop = true;
    const filter = this.context.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = frequency;
    const gain = this.context.createGain();
    gain.gain.value = volume;
    source.connect(filter).connect(gain).connect(this.master);
    source.start();
    return [gain, filter];
  }

  setMuted(muted) {
    this.muted = muted;
    this.master.gain.setTargetAtTime(muted || this.paused ? 0 : 0.22, this.context.currentTime, 0.015);
    if (muted) this.stopEffects();
  }

  setPaused(paused) {
    this.paused = paused;
    this.setMuted(this.muted);
    if (paused) this.stopEffects();
  }

  stopEffects() {
    for (const source of this.effects) source.stop();
    this.effects.clear();
  }

  reset() {
    this.stopEffects();
    this.water.gain.setTargetAtTime(0, this.context.currentTime, 0.15);
    this.speed(0);
    this.nextBird = this.context.currentTime + 2;
  }

  speed(level) {
    const index = Math.max(0, Math.min(3, Math.round(level) || 0));
    const time = this.context.currentTime;
    this.air.gain.setTargetAtTime([0.025, 0.04, 0.06, 0.08][index], time, 0.3);
    this.airFilter.frequency.setTargetAtTime([350, 600, 900, 1400][index], time, 0.3);
  }

  environment(state) {
    const level = value => Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0;
    const lake = level(state.lake);
    const grove = level(state.grove);
    this.water.gain.setTargetAtTime(lake * 0.12, this.context.currentTime, 0.3);
    if (!this.muted && !this.paused && grove > 0.15 && this.context.currentTime >= this.nextBird) {
      this.tone(2100, 2800, 0.18, 0.055 * grove);
      this.tone(2500, 1900, 0.22, 0.04 * grove, 0.22);
      this.nextBird = this.context.currentTime + 4 + Math.random() * 3;
    }
  }

  finish(source, nodes) {
    this.effects.add(source);
    source.onended = () => {
      this.effects.delete(source);
      source.disconnect();
      for (const node of nodes) node.disconnect();
    };
  }

  envelope(volume, duration, delay) {
    const gain = this.context.createGain();
    const time = this.context.currentTime + delay;
    gain.gain.setValueAtTime(0, time);
    gain.gain.linearRampToValueAtTime(volume, time + 0.015);
    gain.gain.exponentialRampToValueAtTime(0.00001, time + duration);
    gain.connect(this.master);
    return gain;
  }

  tone(from, to, duration, volume, delay = 0) {
    const source = this.context.createOscillator();
    source.type = 'sine';
    const time = this.context.currentTime + delay;
    source.frequency.setValueAtTime(from, time);
    source.frequency.exponentialRampToValueAtTime(to, time + duration);
    const gain = this.envelope(volume, duration, delay);
    source.connect(gain);
    this.finish(source, [gain]);
    source.start(time);
    source.stop(time + duration + 0.02);
  }

  rustle(frequency, duration, volume) {
    const source = this.context.createBufferSource();
    source.buffer = this.noise;
    const filter = this.context.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = frequency;
    const gain = this.envelope(volume, duration, 0);
    source.connect(filter).connect(gain);
    this.finish(source, [filter, gain]);
    source.start(this.context.currentTime, Math.random() * 2);
    source.stop(this.context.currentTime + duration + 0.02);
  }

  play(name) {
    if (this.muted || this.paused) return;
    switch (name) {
      case 'splash':
        this.rustle(1800, 0.3, 0.13);
        this.tone(260, 110, 0.18, 0.04);
        break;
      case 'bird':
        this.tone(2100, 2800, 0.18, 0.045);
        this.tone(2500, 1900, 0.22, 0.035, 0.2);
        break;
      case 'cheer':
        this.tone(392, 494, 0.22, 0.055);
        this.tone(494, 587, 0.3, 0.045, 0.18);
        this.rustle(1000, 0.18, 0.045);
        break;
      case 'whoosh':
        this.rustle(1600, 0.35, 0.08);
        this.tone(300, 900, 0.3, 0.035);
        break;
      case 'step':
        this.rustle(400, 0.14, 0.18);
        this.tone(95, 55, 0.12, 0.09);
        break;
      case 'flowers':
        [523, 659, 784].forEach((frequency, i) => this.tone(frequency, frequency, 0.45, 0.10, i * 0.12));
        break;
      case 'tracks':
        this.tone(330, 440, 0.25, 0.09);
        break;
      case 'pickup':
        this.rustle(900, 0.22, 0.09);
        this.tone(440, 590, 0.22, 0.07);
        break;
      case 'bite':
        this.rustle(850, 0.20, 0.20);
        this.tone(180, 130, 0.15, 0.055);
        break;
      case 'last-lap':
        [523, 659, 784].forEach((frequency, i) => this.tone(frequency, frequency * 1.06, 0.16, 0.08, i * 0.11));
        break;
      case 'happy':
        this.tone(659, 659, 0.45, 0.10);
        this.tone(784, 784, 0.55, 0.08, 0.18);
        break;
    }
  }
}
