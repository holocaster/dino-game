import { readFile } from 'node:fs/promises';
import { setTimeout } from 'node:timers/promises';

export async function generate(model, input) {
  const key = process.env.FAL_KEY?.trim();
  if (!key) {
    throw new Error('Configure FAL_KEY no ambiente ou no arquivo .env. Crie a chave em https://fal.ai/dashboard/keys.');
  }
  if (typeof model !== 'string' || !/^[\w-]+(?:\/[\w-][\w.-]*)+$/.test(model)) {
    throw new Error('Informe um modelo como fal-ai/trellis-2.');
  }
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new Error('A entrada deve ser um objeto JSON.');
  }

  async function request(url, options = {}) {
    if (new URL(url).origin !== 'https://queue.fal.run') {
      throw new Error('A URL da fila deve pertencer a https://queue.fal.run.');
    }
    const response = await fetch(url, {
      ...options,
      headers: { Authorization: `Key ${key}`, 'Content-Type': 'application/json' },
      redirect: 'error',
      signal: AbortSignal.timeout(60_000),
    });
    if (!response.ok) {
      throw new Error(`A API fal retornou HTTP ${response.status}. Consulte a requisição no dashboard.`);
    }
    return response.json();
  }

  const job = await request(`https://queue.fal.run/${model}`, {
    method: 'POST',
    body: JSON.stringify(input),
  });
  console.error(`Request: ${job.request_id}\nStatus: ${job.status_url}\nResult: ${job.response_url}`);

  while (true) {
    const status = await request(job.status_url);
    if (status.error) {
      throw new Error(`A geração fal falhou. Consulte a requisição ${job.request_id} no dashboard.`);
    }
    if (status.status === 'COMPLETED') {
      return request(job.response_url);
    }
    if (!['IN_QUEUE', 'IN_PROGRESS'].includes(status.status)) {
      throw new Error(`Estado de fila inesperado na requisição ${job.request_id}.`);
    }
    await setTimeout(2000);
  }
}

if (import.meta.main) {
  try {
    const [model, inputPath, ...extra] = process.argv.slice(2);
    if (!model || !inputPath || extra.length) {
      throw new Error('Uso: npm run fal -- <modelo> <entrada.json>');
    }
    const result = await generate(model, JSON.parse(await readFile(inputPath, 'utf8')));
    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
