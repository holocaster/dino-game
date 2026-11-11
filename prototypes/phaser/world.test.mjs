import { test } from 'node:test';
import assert from 'node:assert/strict';
import { project, unproject, stepToward } from './world.mjs';

test('toques isométricos preservam a posição e ficam dentro do parque', () => {
  for (const [x, z] of [[0, 0], [-2.2, -1.3], [2.1, -1.7], [2.3, 1.8]]) {
    const point = project(x, z);
    const result = unproject(point.x, point.y, 3.7);
    assert.ok(Math.abs(result.x - x) < 1e-9);
    assert.ok(Math.abs(result.z - z) < 1e-9);
  }
  const outside = unproject(-9000, 9000, 3.7);
  assert.ok(Math.abs(outside.x) <= 3.7 && Math.abs(outside.z) <= 3.7);
});

test('o dinossauro alcança o destino sem ultrapassar ou mudar a velocidade na diagonal', () => {
  const start = { x: 0, z: 0 };
  assert.deepEqual(stepToward(start, { x: 0.1, z: 0 }, 1), { x: 0.1, z: 0 });
  assert.deepEqual(stepToward(start, start, 0), start);
  const diagonal = stepToward(start, { x: 3, z: 4 }, 2);
  assert.ok(Math.abs(Math.hypot(diagonal.x, diagonal.z) - 2) < 1e-9);
});
