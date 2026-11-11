import { beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { generate } from './fal.mjs';

const job = {
  request_id: 'test-request',
  status_url: 'https://queue.fal.run/fal-ai/flux/requests/test-request/status',
  response_url: 'https://queue.fal.run/fal-ai/flux/requests/test-request',
};

beforeEach((t) => {
  const previousKey = process.env.FAL_KEY;
  process.env.FAL_KEY = 'test-only-key';
  t.after(() => {
    if (previousKey === undefined) delete process.env.FAL_KEY;
    else process.env.FAL_KEY = previousKey;
  });
  t.mock.method(console, 'error', () => {});
});

function mockFal(t, responses) {
  const calls = [];
  t.mock.method(globalThis, 'fetch', async (url, options) => {
    calls.push({ url, options });
    assert.ok(responses.length, 'Uma chamada inesperada poderia gerar cobranca.');
    const { body, status = 200 } = responses.shift();
    return Response.json(body, { status });
  });
  return calls;
}

test('recusa chave ausente antes de enviar qualquer requisicao', async (t) => {
  const calls = mockFal(t, []);
  delete process.env.FAL_KEY;
  await assert.rejects(generate('fal-ai/flux/schnell', { prompt: 'dino' }), /Configure FAL_KEY/);
  assert.equal(calls.length, 0);
});

test('recusa modelo ou entrada invalidos antes de uma geracao paga', async (t) => {
  const calls = mockFal(t, []);
  await assert.rejects(generate('https://example.com/model', {}), /Informe um modelo/);
  await assert.rejects(generate('fal-ai/flux/schnell', []), /objeto JSON/);
  assert.equal(calls.length, 0);
});

test('envia uma vez, acompanha a fila pelas URLs retornadas e recupera o resultado', async (t) => {
  const result = { images: [{ url: 'https://fal.media/dino.png' }] };
  const calls = mockFal(t, [
    { status: 202, body: job },
    { body: { status: 'IN_PROGRESS' } },
    { body: { status: 'COMPLETED' } },
    { body: result },
  ]);

  assert.deepEqual(await generate('fal-ai/flux/schnell', { prompt: 'dino' }), result);
  assert.deepEqual(calls.map(({ url }) => url), [
    'https://queue.fal.run/fal-ai/flux/schnell',
    job.status_url,
    job.status_url,
    job.response_url,
  ]);
  assert.equal(calls[0].options.method, 'POST');
  assert.deepEqual(JSON.parse(calls[0].options.body), { prompt: 'dino' });
  for (const { options } of calls) {
    assert.equal(options.headers.Authorization, 'Key test-only-key');
    assert.equal(options.redirect, 'error');
  }
});

test('erro HTTP encerra sem repetir a submissao nem imprimir a chave', async (t) => {
  const calls = mockFal(t, [{ status: 402, body: { detail: process.env.FAL_KEY } }]);
  await assert.rejects(generate('fal-ai/flux/schnell', { prompt: 'dino' }), (error) => {
    assert.match(error.message, /HTTP 402/);
    assert.ok(!error.message.includes(process.env.FAL_KEY));
    return true;
  });
  assert.equal(calls.length, 1);
});

test('falha de geracao encerra sem criar outro trabalho', async (t) => {
  const calls = mockFal(t, [
    { body: job },
    { body: { status: 'COMPLETED', error: 'Generation failed' } },
  ]);
  await assert.rejects(generate('fal-ai/flux/schnell', { prompt: 'dino' }), /test-request/);
  assert.equal(calls.length, 2);
});

test('nunca envia a chave para uma URL de fila de outro dominio', async (t) => {
  const calls = mockFal(t, [
    { body: { ...job, status_url: 'https://example.com/status' } },
  ]);
  await assert.rejects(generate('fal-ai/flux/schnell', { prompt: 'dino' }), /URL da fila/);
  assert.equal(calls.length, 1);
});

test('comando sem argumentos mostra o uso e retorna erro', () => {
  const result = spawnSync(process.execPath, ['scripts/fal.mjs'], { encoding: 'utf8' });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Uso: npm run fal/);
});
