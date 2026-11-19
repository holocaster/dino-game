import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ParkAudio } from './audio.mjs';

test('poças, pássaros e torcida usam efeitos curtos e suaves', () => {
  for (const name of ['splash', 'bird', 'cheer', 'whoosh', 'lap']) {
    const calls = [];
    ParkAudio.prototype.play.call({
      tone: (...args) => calls.push(['tone', ...args]),
      rustle: (...args) => calls.push(['rustle', ...args]),
    }, name);
    assert.ok(calls.length >= 2);
    assert.ok(calls.some(([kind]) => kind === 'tone'));
    for (const [, , , duration, volume, delay = 0] of calls.filter(([kind]) => kind === 'tone')) {
      assert.ok(duration > 0 && duration <= 0.5);
      assert.ok(volume > 0 && volume <= 0.15);
      assert.ok(delay >= 0 && delay <= 0.3);
    }
    if (name === 'splash') assert.ok(calls.some(([kind]) => kind === 'rustle'));
    if (name === 'bird') assert.ok(calls.every(([kind]) => kind === 'tone'));
  }
});

test('última volta toca uma fanfarra mais longa e cheia que a volta comum', () => {
  const sound = name => {
    const tones = [];
    ParkAudio.prototype.play.call({ tone: (...args) => tones.push(args), rustle: () => {} }, name);
    return { count: tones.length, end: Math.max(...tones.map(([, , duration, , delay = 0]) => delay + duration)), loud: Math.max(...tones.map(([, , , volume]) => volume)) };
  };
  const lap = sound('lap');
  const last = sound('last-lap');
  assert.ok(last.count > lap.count * 2 && last.end > lap.end * 2);
  assert.ok(last.end <= 2 && last.loud <= 0.15);
});

test('pausa e silêncio impedem os novos efeitos', () => {
  for (const state of [{ paused: true }, { muted: true }]) {
    for (const name of ['splash', 'bird', 'cheer', 'lap', 'last-lap']) {
      ParkAudio.prototype.play.call({
        ...state,
        tone: () => assert.fail('Som emitido durante pausa ou silêncio'),
        rustle: () => assert.fail('Ruído emitido durante pausa ou silêncio'),
      }, name);
    }
  }
});

test('vento acompanha o nível de velocidade dentro dos limites', () => {
  const targets = [];
  const param = name => ({ setTargetAtTime: value => targets.push([name, value]) });
  const fake = { context: { currentTime: 0 }, air: { gain: param('gain') }, airFilter: { frequency: param('frequency') } };
  for (const level of [-1, 0, 2, 3, 9, NaN]) ParkAudio.prototype.speed.call(fake, level);
  assert.deepEqual(targets.filter(([name]) => name === 'frequency').map(([, value]) => value), [350, 350, 900, 1400, 1400, 350]);
  assert.ok(targets.filter(([name]) => name === 'gain').every(([, value]) => value > 0 && value <= 0.08));
});

test('crystal sides form six soft short notes and suppress a same-frame burst', () => {
  const notes = [];
  const audio = { context: { currentTime: 1 }, crystalTimes: [], tone: (...args) => notes.push(args) };
  for (const [index, side] of [[0, 'left'], [0, 'right'], [1, 'left'], [1, 'right'], [2, 'left'], [2, 'right']]) {
    audio.context.currentTime += 1;
    ParkAudio.prototype.play.call(audio, `crystal-${index}-${side}`);
  }
  assert.equal(notes.length, 6);
  assert.equal(new Set(notes.map(([frequency]) => frequency)).size, 6);
  assert.ok(notes.every(([from, to, duration, volume]) => from === to && duration <= 0.35 && volume <= 0.1));
  notes.length = 0;
  audio.context.currentTime += 1;
  for (const name of ['crystal-0-left', 'crystal-0-right', 'crystal-1-left', 'crystal-9-left']) ParkAudio.prototype.play.call(audio, name);
  assert.equal(notes.length, 2);
  for (const state of [{ muted: true }, { paused: true }]) {
    ParkAudio.prototype.play.call({ ...audio, ...state, tone: () => assert.fail('Crystal sounded while silent') }, 'crystal-0-left');
  }
});

test('pause suspends the audio clock and resume keeps the scheduled note', async () => {
  const calls = [];
  const audio = { paused: false, muted: false, effects: new Set(['note']),
    context: { suspend: async () => calls.push('suspend'), resume: async () => calls.push('resume') },
    setMuted: () => {}, stopEffects: () => assert.fail('Pause discarded a note') };
  ParkAudio.prototype.setPaused.call(audio, true, true);
  ParkAudio.prototype.setPaused.call(audio, true, true);
  ParkAudio.prototype.setPaused.call(audio, false);
  await Promise.resolve();
  assert.deepEqual(calls, ['suspend', 'resume']);
  assert.ok(audio.effects.has('note'));
});
