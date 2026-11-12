import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ParkAudio } from './audio.mjs';

test('poças, pássaros e torcida usam efeitos curtos e suaves', () => {
  for (const name of ['splash', 'bird', 'cheer']) {
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
    for (const name of ['splash', 'bird', 'cheer']) {
      ParkAudio.prototype.play.call({
        ...state,
        tone: () => assert.fail('Som emitido durante pausa ou silêncio'),
        rustle: () => assert.fail('Ruído emitido durante pausa ou silêncio'),
      }, name);
    }
  }
});
