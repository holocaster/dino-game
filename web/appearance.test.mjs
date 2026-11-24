import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadAppearances, saveAppearances } from './appearance.mjs';
import { loadRewards, saveRewards } from './rewards.mjs';

const defaults = [
  { species: 'triceratops', color: 'natural', accessory: 'none' },
  { species: 'trex', color: 'natural', accessory: 'none' },
];
const storage = () => {
  const data = new Map();
  return { getItem: key => data.get(key) ?? null, setItem: (key, value) => data.set(key, value) };
};

test('duas aparências recarregam sem perder o álbum e migram a cor antiga', () => {
  const memory = storage();
  saveRewards(memory, { stickers: ['first-lap', 'forest', 'beach', 'basket'], color: 'ocean' });
  const rewards = loadRewards(memory);
  assert.deepEqual(loadAppearances(memory, rewards), [{ ...defaults[0], color: 'ocean' }, defaults[1]]);
  const chosen = [{ species: 'raptor', color: 'sunset', accessory: 'cap' }, { species: 'raptor', color: 'ocean', accessory: 'glasses' }];
  saveAppearances(memory, chosen, rewards);
  assert.deepEqual(loadAppearances(memory, rewards), chosen);
  assert.deepEqual(loadRewards(memory), rewards);
});

test('aparências inválidas e cores bloqueadas usam padrões por slot', () => {
  const memory = storage();
  const rewards = { stickers: [], color: 'natural' };
  for (const data of [null, {}, 'broken', 23, []]) {
    memory.setItem('dino-race-appearances', JSON.stringify(data));
    assert.deepEqual(loadAppearances(memory, rewards), defaults);
  }
  memory.setItem('dino-race-appearances', JSON.stringify([
    { species: 'unknown', color: 'candy', accessory: 'paid' },
    { species: 'raptor', color: 'ocean', accessory: 'glasses' },
  ]));
  assert.deepEqual(loadAppearances(memory, rewards), [defaults[0], { species: 'raptor', color: 'natural', accessory: 'glasses' }]);
  saveAppearances(memory, [{ species: 'trex', color: 'candy', accessory: 'cap' }], rewards);
  assert.deepEqual(loadAppearances(memory, rewards), [{ species: 'trex', color: 'natural', accessory: 'cap' }, defaults[1]]);
});

test('JSON corrompido e storage bloqueado não impedem jogar', () => {
  const memory = storage();
  const rewards = { stickers: [], color: 'natural' };
  memory.setItem('dino-race-appearances', '{broken');
  assert.deepEqual(loadAppearances(memory, rewards), defaults);
  const blocked = { getItem() { throw new Error('blocked'); }, setItem() { throw new Error('blocked'); } };
  for (const unavailable of [blocked, null]) {
    assert.deepEqual(loadAppearances(unavailable, rewards), defaults);
    assert.doesNotThrow(() => saveAppearances(unavailable, defaults, rewards));
  }
});


test('pteranodon appearance persists for both players without changing rewards', () => {
  const memory = storage();
  const rewards = { stickers: [], color: 'natural' };
  const chosen = ['cap', 'glasses'].map(accessory => ({ species: 'pteranodon', color: 'natural', accessory }));
  saveAppearances(memory, chosen, rewards);
  assert.deepEqual(loadAppearances(memory, rewards), chosen);
  assert.deepEqual(rewards, { stickers: [], color: 'natural' });
});
