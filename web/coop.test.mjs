import { test } from 'node:test';
import assert from 'node:assert/strict';
import { SteeringInputs, keyDirection } from './controls.mjs';
import { validRaceReport } from './race-report.mjs';
import { award } from './rewards.mjs';

const player = (fruit = 4) => ({ species: 'trex', progress: 1, lap: 1, fruit, golden: 0, speed: 2.27, baseSpeed: 2.27, finished: true });
const report = () => ({ type: 'park-race', mode: 'coop', players: [player(), player(5)], stage: 'finished', countdown: 0, paused: false, progress: 1, rivalProgress: 1, fruit: 9, golden: 0, speed: 2.27, baseSpeed: 2.27, boostLeft: 0, recoveryBoostLeft: 0, rivalRecoveryBoostLeft: 0, recoveryTarget: '', dino: 'trex', track: 'forest', winner: '', lateral: -0.9, rivalLateral: 0.9, rivalSpeed: 2.27, rival: 'none', rivalDistracted: false, speedLevel: 0, streak: 0, lap: 1, laps: 1, arrows: 0 });

test('two pointers and keyboard compose independently and opposite directions cancel', () => {
  const commands = [];
  const inputs = new SteeringInputs(value => commands.push(value));
  inputs.set('pointer11', 1, 'left', true);
  inputs.set('pointer22', 2, 'right', true);
  inputs.set('keyA', 1, 'left', true);
  inputs.set('pointer11', 1, 'left', false);
  assert.deepEqual(commands, ['input:1:left:down:page', 'input:2:right:down:page']);
  inputs.set('keyD', 1, 'right', true);
  inputs.set('pointer22', 2, 'right', false);
  assert.deepEqual([inputs.held(1, 'left'), inputs.held(1, 'right')], [true, true]);
  assert.deepEqual([inputs.held(2, 'left'), inputs.held(2, 'right')], [false, false]);
  inputs.set('keyA', 1, 'left', false);
  assert.deepEqual([inputs.held(1, 'left'), inputs.held(1, 'right')], [false, true]);
  inputs.clear();
  assert.deepEqual([inputs.held(1, 'left'), inputs.held(1, 'right')], [false, false]);
  assert.deepEqual([inputs.held(2, 'left'), inputs.held(2, 'right')], [false, false]);
  assert.equal(commands.at(-1), 'release');
  assert.deepEqual(keyDirection('ArrowLeft', 'coop'), [2, 'left']);
  assert.deepEqual(keyDirection('A', 'coop'), [1, 'left']);
  assert.deepEqual(keyDirection('ArrowRight', 'solo'), [1, 'right']);
  assert.equal(keyDirection('d', 'competitive'), null);
});

test('reports reject malformed enums, numbers, slots and inconsistent team facts', () => {
  assert.equal(validRaceReport(report()), true);
  for (const bad of [
    { mode: 'dupla' }, { track: 'bad' }, { rival: 'human' }, { winner: 'bad' }, { paused: 'false' },
    { fruit: NaN }, { speed: Infinity }, { progress: -1 }, { golden: -1 }, { countdown: 4 },
    { lap: 2 }, { laps: 3 }, { lateral: Infinity }, { players: [] }, { players: {} },
    { players: [player(), { ...player(), species: 'bad' }] },
    { players: [player(), { ...player(5), finished: false }] },
    { players: [player(), { ...player(5), fruit: Infinity }] },
    { players: [player(), { ...player(5), progress: NaN }] },
    { players: [player(), { ...player(5), speed: -1 }] },
    { players: [player(), player()] },
  ]) assert.equal(validRaceReport({ ...report(), ...bad }), false, JSON.stringify(bad));
  const solo = { ...report(), mode: 'solo', players: [player(9)], winner: 'player' };
  assert.equal(validRaceReport(solo), true);
  assert.equal(validRaceReport({ ...solo, players: [player(9), player()] }), false);
});

test('volcano reports and existing rewards work in all three modes', () => {
  const coop = { ...report(), track: 'volcano', lap: 3, laps: 3, players: [player(), player(5)].map(value => ({ ...value, lap: 3 })) };
  assert.equal(validRaceReport(coop), true);
  assert.deepEqual(award([], coop), ['first-lap']);
  const solo = { ...coop, mode: 'solo', players: [{ ...player(9), lap: 3 }], winner: 'player' };
  assert.equal(validRaceReport(solo), true);
  const competitive = { ...solo, mode: 'competitive', rival: 'playful' };
  assert.equal(validRaceReport(competitive), true);
  for (const result of [coop, solo, competitive]) {
    assert.equal(validRaceReport({ ...result, track: 'lava' }), false);
    assert.equal(validRaceReport({ ...result, lap: 1, laps: 1, players: result.players.map(value => ({ ...value, lap: 1 })) }), false);
    for (const lap of [1, 2]) {
      const racing = { ...result, stage: 'racing', lap, progress: lap / 3, rivalProgress: lap / 3,
        players: result.players.map(value => ({ ...value, lap, progress: lap / 3, finished: false })) };
      assert.equal(validRaceReport(racing), true);
      assert.equal(validRaceReport({ ...racing, stage: 'finished' }), false);
    }
  }
  assert.deepEqual(award([], { ...coop, players: [player(), { ...player(5), finished: false, progress: 0.9 }] }), []);
});

test('coop awards only after both finish and never competitive/solo stickers', () => {
  const result = report();
  assert.deepEqual(award([], result), ['first-lap', 'forest']);
  result.players[1].fruit++;
  result.fruit++;
  result.players[1].golden = result.golden = 1;
  for (const rival of ['none', 'speedy']) {
    assert.deepEqual(award([], { ...result, rival, winner: 'player' }), ['first-lap', 'forest', 'basket', 'golden']);
  }
  const owned = award([], result);
  assert.deepEqual(award(owned, result), []);
  assert.deepEqual(award([], { ...result, stage: 'racing' }), []);
  assert.deepEqual(award([], { ...result, players: [player(), { ...player(6), finished: false, progress: 0.9 }] }), []);
  assert.deepEqual(award([], { ...result, players: undefined }), []);
  assert.deepEqual(award([], { ...result, laps: Infinity }), []);
  assert.deepEqual(award([], { ...result, track: 'unknown' }), []);
});

test('cave reports keep one lap and require both humans at the finish', () => {
  for (const mode of ['coop', 'solo', 'competitive']) {
    const result = { ...report(), track: 'cave', mode, rival: mode === 'competitive' ? 'playful' : 'none',
      players: mode === 'coop' ? [player(), player(5)] : [player(9)] };
    assert.equal(validRaceReport(result), true);
    assert.deepEqual(award([], result), mode === 'solo' ? ['first-lap', 'calm'] : ['first-lap']);
    assert.equal(validRaceReport({ ...result, track: 'cavern' }), false);
    assert.equal(validRaceReport({ ...result, laps: 3 }), false);
    if (mode === 'coop') {
      const waiting = { ...result, rivalProgress: 0.9, players: [player(), { ...player(5), progress: 0.9, finished: false }] };
      assert.equal(validRaceReport(waiting), false);
      assert.deepEqual(award([], waiting), []);
      assert.equal(validRaceReport({ ...waiting, stage: 'racing' }), true);
    }
  }
});
