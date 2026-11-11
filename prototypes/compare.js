const variants = {
  phaser: { name: 'Phaser', description: 'Desenhos 2D com sensação de profundidade', src: 'phaser/index.html' },
  godot: { name: 'Godot', description: 'Modelos 3D vistos por uma câmera fixa', src: 'godot/index.html' }
};
const frame = document.querySelector('#game');
const loading = document.querySelector('#loading');
const message = document.querySelector('#message');
let current;

function showVariant(key) {
  current = Object.hasOwn(variants, key) ? key : 'phaser';
  const variant = variants[current];
  document.querySelector('#engine-name').textContent = variant.name;
  document.querySelector('#engine-description').textContent = variant.description;
  document.querySelectorAll('[data-variant]').forEach(button => {
    button.setAttribute('aria-pressed', String(button.dataset.variant === current));
  });
  document.querySelectorAll('[data-discovery]').forEach(item => item.classList.remove('found'));
  message.textContent = 'Toque no chão para passear. O que você consegue encontrar?';
  loading.textContent = 'Preparando o parque...';
  loading.hidden = false;
  frame.title = `Parque de dinossauros em ${variant.name}`;
  frame.src = variant.src;
  const url = new URL(location.href);
  url.searchParams.set('variant', current);
  history.replaceState(null, '', url);
}

document.querySelectorAll('[data-variant]').forEach(button => {
  button.addEventListener('click', () => showVariant(button.dataset.variant));
});
document.querySelector('#restart').addEventListener('click', () => showVariant(current));
window.addEventListener('popstate', () => showVariant(new URLSearchParams(location.search).get('variant')));
window.addEventListener('message', event => {
  if (event.source !== frame.contentWindow || event.origin !== location.origin) return;
  const data = event.data;
  if (data?.type === 'park-ready') loading.hidden = true;
  if (data?.type === 'park-error') {
    loading.hidden = false;
    loading.textContent = data.message;
  }
  if (data?.type === 'park-discovery' && ['flowers', 'tracks', 'fruit'].includes(data.id)) {
    document.querySelector(`[data-discovery="${data.id}"]`).classList.add('found');
    message.textContent = data.message;
  }
});
showVariant(new URLSearchParams(location.search).get('variant'));
