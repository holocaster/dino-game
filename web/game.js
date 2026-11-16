import { SteeringInputs, keyDirection } from './controls.mjs?v=0.28.0';
import { validRaceReport } from './race-report.mjs?v=0.28.0';
import { ParkAudio } from './audio.mjs?v=0.28.0';
import { loadAppearances, saveAppearances } from './appearance.mjs?v=0.28.0';
import { STICKERS, COLORS, award, unlocked, prizeText, loadRewards, saveRewards } from './rewards.mjs?v=0.28.0';

const frame = document.querySelector('#game');
const welcome = document.querySelector('#welcome');
const play = document.querySelector('#play');
const restart = document.querySelector('#restart');
const pause = document.querySelector('#pause');
const message = document.querySelector('#message');
const soundButton = document.querySelector('#sound');
const panel = document.querySelector('#race-panel');
const panelAction = document.querySelector('#panel-action');
const countdown = document.querySelector('#countdown');
const park = document.querySelector('.park');
const streakBadge = document.querySelector('#streak');
const lapCount = document.querySelector('#lap-count');
const lapBanner = document.querySelector('#lap-banner');
let shownLap = 1;
const controls = [...document.querySelectorAll('[data-direction]')];
const choices = [...document.querySelectorAll('.choices')];
let sound = null;
let muted = false;
let environment = { lake: 0, grove: 0 };
let started = false;
let state = null;
let storage = null;
try { storage = window.localStorage; } catch {}
const rewards = loadRewards(storage);
const appearances = loadAppearances(storage, rewards);
for (const [index, suffix] of ['', '2'].entries()) {
  document.querySelector(`[name="dino${suffix}"][value="${appearances[index].species}"]`).checked = true;
  document.querySelector(`[name="accessory${suffix}"][value="${appearances[index].accessory}"]`).checked = true;
}

function sendAppearance(slot) {
  const { species, color, accessory } = appearances[slot - 1];
  command(`appearance:${slot}:${species}:${color}:${accessory}`);
}
let prize = '';

function renderRewards() {
  document.querySelector('#sticker-count').textContent = `${rewards.stickers.length}/${STICKERS.length}`;
  const list = document.querySelector('#sticker-list');
  list.replaceChildren(...STICKERS.map(sticker => {
    const item = document.createElement('li');
    const owned = rewards.stickers.includes(sticker.id);
    item.className = owned ? 'owned' : '';
    item.textContent = owned ? sticker.name : sticker.hint;
    item.setAttribute('aria-label', owned ? `Adesivo ${sticker.name}` : `Adesivo por ganhar: ${sticker.hint}`);
    return item;
  }));
  for (const [index, suffix] of ['', '2'].entries()) {
    const colors = document.querySelector(`#color${suffix}-choices`);
    for (const label of colors.querySelectorAll('label')) label.remove();
    for (const color of COLORS) {
      const label = document.createElement('label');
      label.className = 'choice';
      const input = document.createElement('input');
      Object.assign(input, { type: 'radio', name: `color${suffix}`, value: color.id, checked: color.id === appearances[index].color, disabled: !unlocked(color, rewards.stickers) });
      input.addEventListener('change', () => {
        appearances[index].color = color.id;
        if (index === 0) rewards.color = color.id;
        saveRewards(storage, rewards);
        saveAppearances(storage, appearances, rewards);
        sendAppearance(index + 1);
      });
      const swatch = document.createElement('span');
      swatch.className = 'swatch';
      swatch.style.background = color.swatch;
      const name = document.createElement('strong');
      name.textContent = color.name;
      const hint = document.createElement('span');
      hint.textContent = input.disabled ? `Junte ${color.needs} adesivos` : 'Liberada';
      label.append(input, swatch, name, hint);
      colors.append(label);
    }
  }
}
renderRewards();

function command(value) {
  if (typeof frame.contentWindow?.parkCommand === 'function') frame.contentWindow.parkCommand(value);
}

function updateSoundButton() {
  soundButton.setAttribute('aria-pressed', String(muted));
  soundButton.setAttribute('aria-label', muted ? 'Ativar som' : 'Silenciar som');
  soundButton.title = muted ? 'Som desligado' : 'Som ligado';
  soundButton.querySelector('use').setAttribute('href', muted ? '#sound-off' : '#sound-on');
}

function audioFailed() {
  muted = true;
  sound?.setMuted(true);
  updateSoundButton();
  soundButton.title = 'Toque para tentar ativar o som';
}

function resumeAudio() {
  try {
    sound ??= new ParkAudio(new AudioContext());
    sound.setMuted(muted);
    sound.setPaused(Boolean(state?.paused));
    sound.environment(environment);
    sound.context.resume().catch(audioFailed);
  } catch {
    audioFailed();
  }
}

const inputs = new SteeringInputs(command);

function releaseDirections() {
  for (const button of controls) button.classList.remove('held');
  inputs.clear();
}

function steer(source, slot, direction, pressed) {
  if (pressed && (!started || state?.paused || state?.stage !== 'racing')) return;
  inputs.set(source, slot, direction, pressed);
  for (const button of controls) button.classList.toggle('held', inputs.held(Number(button.dataset.player), button.dataset.direction));
}

function pauseRace() {
  if (!started) return;
  releaseDirections();
  command('pause');
}

function restartRace() {
  releaseDirections();
  sound?.reset();
  command('restart');
  resumeAudio();
  frame.focus();
}

function streakText(count) {
  return count >= 4 ? 'Super rápido!' : `${count} seguidas!`;
}

function showBadge(badge, text, duration = 1500) {
  badge.textContent = text;
  badge.hidden = false;
  badge.classList.remove('pop');
  void badge.offsetWidth;
  badge.classList.add('pop');
  clearTimeout(badge.timer);
  badge.timer = setTimeout(() => { badge.hidden = true; }, duration);
}

function renderRace(data) {
  const previous = state;
  state = data;
  const level = started && data.stage === 'racing' && !data.paused ? data.speedLevel : 0;
  if (level > Number(park.dataset.speed ?? 0)) sound?.play('whoosh');
  park.dataset.speed = level;
  sound?.speed(level);
  if (!started) return;
  const arrow = data.stage === 'racing' && data.arrows > (previous?.arrows ?? 0);
  document.querySelector('#race-hud').hidden = false;
  document.querySelector('#lap-title').textContent = data.laps > 1 ? 'TRÊS VOLTAS' : 'UMA VOLTA';
  lapCount.hidden = !(data.laps > 1);
  lapCount.textContent = `Volta ${data.lap}/${data.laps}`;
  if (data.stage !== 'racing') shownLap = 1;
  const newLap = data.stage === 'racing' && data.lap > shownLap;
  const lastLap = newLap && data.lap === data.laps;
  if (newLap) {
    shownLap = data.lap;
    lapBanner.classList.toggle('last', lastLap);
    showBadge(lapBanner, lastLap ? 'Última volta!' : `Volta ${data.lap}/${data.laps}`, lastLap ? 2500 : 1800);
    sound?.play(lastLap ? 'last-lap' : 'lap');
  }
  document.querySelector('#player-progress').value = data.progress;
  document.querySelector('#friend-progress').value = data.rivalProgress;
  const coop = data.mode === 'coop';
  document.querySelector('#friend-lap').hidden = data.mode === 'solo';
  document.querySelector('#player-label').textContent = coop ? `J1 · ${data.players[0].finished ? 'Aguardando' : `Volta ${data.players[0].lap}/${data.laps}`}` : 'Você';
  document.querySelector('#friend-label').textContent = coop ? `J2 · ${data.players[1].finished ? 'Aguardando' : `Volta ${data.players[1].lap}/${data.laps}`}` : 'Amigo';
  document.querySelector('#fruit-count').textContent = data.fruit;
  document.querySelector('#speed').textContent = data.recoveryBoostLeft > 0 ? 'Impulso dourado!' : `Ritmo +${Math.max(0, Math.round((data.speed / data.baseSpeed - 1) * 100))}%`;
  countdown.hidden = data.stage !== 'countdown' || data.paused;
  if (data.stage !== 'racing' || data.paused) streakBadge.hidden = lapBanner.hidden = true;
  else if (arrow) showBadge(streakBadge, data.streak >= 2 ? `Impulso! ${streakText(data.streak)}` : 'Impulso!');
  else if (data.streak >= 2 && data.streak > (previous?.streak ?? 0)) showBadge(streakBadge, streakText(data.streak));
  countdown.textContent = data.countdown;
  pause.disabled = data.stage === 'finished';
  pause.setAttribute('aria-label', data.paused ? 'Continuar corrida' : 'Pausar corrida');
  pause.querySelector('use').setAttribute('href', data.paused ? '#play-icon' : '#pause-icon');
  const finished = data.stage === 'finished';
  park.toggleAttribute('data-finished', finished);
  if (finished && previous && previous.stage !== 'finished') {
    const earned = award(rewards.stickers, data);
    prize = prizeText(rewards.stickers, earned);
    rewards.stickers = STICKERS.map(s => s.id).filter(id => rewards.stickers.includes(id) || earned.includes(id));
    saveRewards(storage, rewards);
    renderRewards();
  }
  if (arrow) sound?.play('whoosh');
  const solo = data.mode === 'solo';
  panel.hidden = !data.paused && !finished;
  if (!panel.hidden) {
    document.querySelector('#panel-title').textContent = finished
      ? (coop ? 'A dupla chegou!' : solo ? (data.laps > 1 ? 'Passeio de três voltas completo!' : 'Volta tranquila completa!') : data.winner === 'player' ? 'Você chegou primeiro!' : data.winner === 'both' ? 'Chegaram juntinhos!' : 'Seu amigo chegou primeiro!')
      : 'Uma pequena pausa';
    document.querySelector('#panel-message').textContent = finished
      ? [`O filhote recebeu ${data.fruit} frutinhas e está comemorando!`, prize].filter(Boolean).join(' ')
      : 'Seus dinos esperam por você.';
    panelAction.textContent = finished ? 'Correr de novo' : 'Continuar';
    if (previous && !previous.paused && previous.stage !== 'finished') {
      releaseDirections();
      panelAction.focus();
    }
  }
  for (const button of controls) button.disabled = data.paused || data.stage !== 'racing';
  sound?.setPaused(data.paused);
  if (!previous || previous.stage !== data.stage || previous.paused !== data.paused || previous.countdown !== data.countdown || previous.fruit !== data.fruit || previous.recoveryTarget !== data.recoveryTarget || (previous.recoveryBoostLeft > 0) !== (data.recoveryBoostLeft > 0) || (previous.rivalRecoveryBoostLeft > 0) !== (data.rivalRecoveryBoostLeft > 0) || previous.rivalDistracted !== data.rivalDistracted || newLap || arrow || (coop && previous.players?.some(player => player.finished) !== data.players.some(player => player.finished))) {
    message.textContent = data.paused ? 'Corrida pausada.'
      : data.stage === 'countdown' ? `Prepare-se... ${data.countdown}!`
      : finished ? `${data.laps > 1 ? 'Três voltas completas!' : 'Uma volta completa!'} ${solo ? 'Que passeio gostoso.' : 'Os dois dinos merecem comemorar.'}`
      : newLap ? (lastLap ? 'Última volta!' : `Volta ${data.lap} de ${data.laps}!`)
      : coop && data.players.some(player => player.finished) ? 'Um jogador aguarda na chegada. Vamos juntos!'
      : data.rivalDistracted ? 'Seu amigo parou para olhar um passarinho!'
      : data.recoveryBoostLeft > 0 ? 'Impulso dourado! Vamos alcançar o amigo!'
      : data.rivalRecoveryBoostLeft > 0 ? 'Seu amigo ganhou um impulso dourado!'
      : data.recoveryTarget === 'player' ? 'Uma fruta dourada para você alcançar o amigo!'
      : data.recoveryTarget === 'rival' ? 'Uma fruta dourada para seu amigo alcançar você!'
      : arrow ? 'Seta de impulso! Seu dino ficou mais rápido.'
      : data.fruit > (previous?.fruit ?? 0) && data.streak >= 2 ? `${streakText(data.streak)} Continue pegando frutinhas.`
      : data.fruit > (previous?.fruit ?? 0) ? 'Uma frutinha! Seu dino ficou mais rápido.'
      : 'Vamos! Pegue as frutinhas pelo caminho.';
  }
}

play.addEventListener('click', () => {
  started = true;
  welcome.hidden = true;
  delete park.dataset.preview;
  restart.disabled = false;
  pause.disabled = false;
  frame.tabIndex = 0;
  resumeAudio();
  command('start');
  frame.focus();
});

for (const [index, suffix] of ['', '2'].entries()) {
  for (const input of document.querySelectorAll(`[name="dino${suffix}"], [name="accessory${suffix}"]`)) {
    input.addEventListener('change', () => {
      appearances[index].species = document.querySelector(`[name="dino${suffix}"]:checked`).value;
      appearances[index].accessory = document.querySelector(`[name="accessory${suffix}"]:checked`).value;
      saveAppearances(storage, appearances, rewards);
      sendAppearance(index + 1);
    });
  }
}

function configureRace() {
  releaseDirections();
  const track = document.querySelector('[name="track"]:checked').value;
  const rival = document.querySelector('[name="rival"]:checked').value;
  const coop = rival === 'coop';
  document.body.dataset.mode = coop ? 'coop' : rival === 'none' ? 'solo' : 'competitive';
  document.querySelector('#partner-appearance').hidden = !coop;
  document.querySelector('[data-slot="2"]').hidden = !coop;
  document.querySelector('#control-hint').textContent = coop ? 'Jogador 1: A/D. Jogador 2: setas. Juntem as frutinhas!' : 'Segure as setas para mudar de lado e pegar frutas.';
  frame.title = coop ? 'Corrida em dupla: jogador 1 usa A/D; jogador 2 usa as setas' : 'Corrida: use as setas esquerda e direita para pegar frutas';
  play.disabled = true;
  for (const group of choices) group.disabled = true;
  play.querySelector('span').textContent = 'Preparando a pista...';
  document.querySelector('#load-status').textContent = 'Seus dinos já estão chegando.';
  command(coop ? `select-coop:${appearances[0].species}:${appearances[1].species}:${track}` : `select:${appearances[0].species}:${track}:${rival}`);
}

for (const input of document.querySelectorAll('[name="track"], [name="rival"]')) input.addEventListener('change', configureRace);

document.querySelector('#choose-again').addEventListener('click', () => {
  releaseDirections();
  sound?.reset();
  sound?.setPaused(true);
  started = false;
  command('menu');
  panel.hidden = true;
  welcome.hidden = false;
  park.dataset.preview = 'true';
  delete park.dataset.finished;
  countdown.hidden = true;
  document.querySelector('#race-hud').hidden = true;
  lapCount.hidden = true;
  streakBadge.hidden = lapBanner.hidden = true;
  restart.disabled = true;
  pause.disabled = true;
  for (const button of controls) button.disabled = true;
  message.textContent = 'Escolha seu dino e uma nova pista.';
  document.querySelector('[name="dino"]:checked').focus();
});

restart.addEventListener('click', restartRace);
pause.addEventListener('click', () => {
  if (state?.paused) {
    command('resume');
    resumeAudio();
    frame.focus();
  } else pauseRace();
});
panelAction.addEventListener('click', () => {
  if (state?.stage === 'finished') restartRace();
  else {
    command('resume');
    resumeAudio();
    frame.focus();
  }
});

soundButton.addEventListener('click', () => {
  muted = !muted;
  sound?.setMuted(muted);
  updateSoundButton();
  if (started && !muted) resumeAudio();
});

for (const button of controls) {
  const slot = Number(button.dataset.player);
  const direction = button.dataset.direction;
  button.addEventListener('pointerdown', event => {
    if (button.disabled) return;
    event.preventDefault();
    button.setPointerCapture(event.pointerId);
    steer(`pointer:${event.pointerId}`, slot, direction, true);
  });
  for (const type of ['pointerup', 'pointercancel', 'lostpointercapture']) {
    button.addEventListener(type, event => steer(`pointer:${event.pointerId}`, slot, direction, false));
  }
  for (const type of ['keydown', 'keyup']) {
    button.addEventListener(type, event => {
      if (event.key === ' ' || event.key === 'Enter') {
        event.preventDefault();
        if (event.repeat) return;
        steer(`button:${slot}:${direction}:${event.key}`, slot, direction, type === 'keydown');
      }
    });
  }
  button.addEventListener('blur', () => {
    for (const key of [' ', 'Enter']) steer(`button:${slot}:${direction}:${key}`, slot, direction, false);
  });
}

for (const type of ['keydown', 'keyup']) {
  window.addEventListener(type, event => {
    if (!started) return;
    const direction = keyDirection(event.key, state?.mode);
    if (direction) {
      event.preventDefault();
      if (event.repeat) return;
      steer(`key:${event.code || event.key.toLowerCase()}`, ...direction, type === 'keydown');
    } else if (event.key === 'Escape' && type === 'keydown' && !event.repeat) {
      if (state?.paused) command('resume');
      else pauseRace();
    }
  });
}

window.addEventListener('blur', () => {
  releaseDirections();
  setTimeout(() => { if (!document.hasFocus()) pauseRace(); }, 0);
});
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    releaseDirections();
    pauseRace();
    sound?.context.suspend().catch(audioFailed);
  }
});

window.addEventListener('message', event => {
  if (event.source !== frame.contentWindow || event.origin !== location.origin) return;
  const data = event.data;
  if (data?.type === 'park-ambience') {
    environment = { lake: data.lake, grove: data.grove };
    sound?.environment(environment);
  }
  if (data?.type === 'park-sound' && started && typeof data.name === 'string') sound?.play(data.name);
  if (data?.type === 'park-ready') {
    sendAppearance(1);
    sendAppearance(2);
    play.disabled = false;
    for (const group of choices) group.disabled = false;
    play.querySelector('span').textContent = 'Vamos correr';
    document.querySelector('#load-status').textContent = 'Toque ou clique para começar.';
  }
  if (data?.type === 'park-error') {
    document.querySelector('#load-status').textContent = 'Não foi possível abrir a corrida. Tente um navegador com WebGL 2.';
    play.disabled = true;
  }
  if (data?.type === 'park-blur') {
    if (!document.hasFocus()) pauseRace();
  }
  if (validRaceReport(data)) renderRace(data);
});
