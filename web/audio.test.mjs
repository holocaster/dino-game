import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ParkAudio } from './audio.mjs';

test('poças, pássaros e torcida usam efeitos curtos e suaves', () => {
  for (const name of ['splash', 'bird', 'cheer', 'whoosh', 'last-lap']) {
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

test('pausa e silêncio impedem os novos efeitos', () => {
  for (const state of [{ paused: true }, { muted: true }]) {
    for (const name of ['splash', 'bird', 'cheer', 'last-lap']) {
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
