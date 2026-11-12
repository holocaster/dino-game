import { test } from 'node:test';
import assert from 'node:assert/strict';
import { STICKERS, COLORS, award, unlocked, prizeText, loadRewards, saveRewards } from './rewards.mjs';

const lap = { track: 'forest', fruit: 4, golden: 0, rival: 'playful', winner: 'rival' };

test('adesivos saem uma vez, conforme a volta', () => {
  assert.deepEqual(award([], lap), ['first-lap', 'forest']);
  assert.deepEqual(award(['first-lap', 'forest'], lap), []);
  assert.deepEqual(award(['first-lap'], { ...lap, track: 'beach', fruit: 10, golden: 1, rival: 'speedy', winner: 'player' }), ['beach', 'basket', 'golden', 'first-place', 'speedy']);
  assert.deepEqual(award(['first-lap', 'forest'], { ...lap, rival: 'none', winner: 'player' }), ['calm']);
  assert.deepEqual(award(STICKERS.map(s => s.id), { ...lap, winner: 'both' }), []);
  assert.ok(!award([], { ...lap, rival: 'speedy', winner: 'both' }).includes('speedy'));
  assert.deepEqual(award(['first-lap', 'forest'], { ...lap, track: 'valley', fruit: 10 }), ['valley', 'basket']);
});

test('vale tem adesivo próprio e a cesta conta a corrida inteira', () => {
  assert.equal(STICKERS.length, 9);
  assert.deepEqual(STICKERS.slice(1, 4).map(s => s.id), ['forest', 'beach', 'valley']);
  const valley = STICKERS.find(s => s.id === 'valley');
  assert.deepEqual([valley.name, valley.hint], ['Explorador do vale', 'Corra no vale']);
  assert.equal(STICKERS.find(s => s.id === 'basket').hint, 'Pegue 10 frutinhas numa corrida');
});

test('cores liberam com a quantidade de adesivos', () => {
  assert.ok(unlocked(COLORS[0], []));
  assert.ok(!unlocked(COLORS[1], ['first-lap']));
  assert.ok(unlocked(COLORS[1], ['first-lap', 'forest']));
  assert.ok(COLORS.every((color, i) => i === 0 || color.needs > COLORS[i - 1].needs));
  assert.ok(COLORS.at(-1).needs <= STICKERS.length);
});

test('progresso salvo é validado e tolera armazenamento bloqueado', () => {
  const memory = new Map();
  const storage = { getItem: key => memory.get(key) ?? null, setItem: (key, value) => memory.set(key, value) };
  assert.deepEqual(loadRewards(storage), { stickers: [], color: 'natural' });
  saveRewards(storage, { stickers: ['forest', 'first-lap', 'hack'], color: 'sunset' });
  assert.deepEqual(loadRewards(storage), { stickers: ['first-lap', 'forest'], color: 'sunset' });
  saveRewards(storage, { stickers: ['first-lap'], color: 'candy' });
  assert.deepEqual(loadRewards(storage), { stickers: ['first-lap'], color: 'natural' });
  memory.set('dino-race-rewards', '{broken');
  assert.deepEqual(loadRewards(storage), { stickers: [], color: 'natural' });
  const blocked = { getItem() { throw new Error('blocked'); }, setItem() { throw new Error('blocked'); } };
  assert.deepEqual(loadRewards(blocked), { stickers: [], color: 'natural' });
  assert.doesNotThrow(() => saveRewards(blocked, { stickers: [], color: 'natural' }));
});

test('mensagem cita todos os adesivos e cores novos', () => {
  assert.equal(prizeText([], ['first-lap']), 'Novo adesivo: Primeira volta!');
  assert.equal(prizeText([], ['first-lap', 'forest', 'basket', 'calm']), 'Novos adesivos: Primeira volta, Explorador da floresta, Cesta cheia, Passeio tranquilo! Novas cores liberadas: Pôr do sol e Oceano.');
  assert.equal(prizeText(['first-lap'], ['forest']), 'Novo adesivo: Explorador da floresta! Nova cor liberada: Pôr do sol.');
  assert.equal(prizeText(['first-lap', 'forest'], []), '');
});
