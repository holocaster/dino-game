import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { COLORS } from './rewards.mjs';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const state = read('../game/race/race_state.gd');
const scene = read('../game/race/race.gd');
const page = read('./index.html');
const effects = read('../game/race/speed_effects.gd');

function gdKeys(source, name) {
  const declaration = `const ${name} := `;
  const start = source.indexOf(declaration);
  assert.ok(start >= 0, `${name} não encontrado`);
  const keys = [];
  let depth = 0;
  for (let i = start + declaration.length; i < source.length; i++) {
    const char = source[i];
    if (char === '{' || char === '(' || char === '[') depth++;
    else if (char === '}' || char === ')' || char === ']') { if (--depth === 0) break; }
    else if (char === '"') {
      const end = source.indexOf('"', i + 1);
      if (depth === 1) keys.push(source.slice(i + 1, end));
      i = end;
    }
  }
  return keys;
}

const values = name => [...page.matchAll(new RegExp(`name="${name}" value="([\\w-]+)"`, 'g'))].map(match => match[1]);

test('lê chaves de primeiro nível do GDScript', () => {
  const source = 'const A := {\n\t"x": {"speed": 1},\n\t"y": Color("fff")\n}\nconst B := ["p", "q"]\n';
  assert.deepEqual(gdKeys(source, 'A'), ['x', 'y']);
  assert.deepEqual(gdKeys(source, 'B'), ['p', 'q']);
});

test('página e Godot usam os mesmos dinos, pistas e amigos', () => {
  assert.deepEqual(values('dino'), gdKeys(state, 'DINOS'));
  assert.deepEqual(values('track'), gdKeys(state, 'TRACKS'));
  assert.deepEqual(values('rival'), [...gdKeys(state, 'RIVALS'), 'none']);
  assert.deepEqual(gdKeys(scene, 'RIVAL_COLORS'), gdKeys(state, 'RIVALS'));
  assert.deepEqual(gdKeys(effects, 'DINO_COLORS'), gdKeys(state, 'DINOS'));
});

test('cores da página existem no Godot', () => {
  assert.deepEqual(COLORS.map(color => color.id), gdKeys(scene, 'PLAYER_COLORS'));
});

test('todas as versões de cache seguem o package.json', () => {
  const { version } = JSON.parse(read('../package.json'));
  for (const file of ['./index.html', './game.js', './godot/index.html', '../game/shell.html']) {
    const found = [...read(file).matchAll(/\?v=([\d.]+)/g)].map(match => match[1]);
    assert.ok(found.length > 0, `${file} sem versão de cache`);
    assert.deepEqual([...new Set(found)], [version], file);
  }
});
