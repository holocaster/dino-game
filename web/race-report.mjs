const inRange = (value, min, max) => Number.isFinite(value) && value >= min && value <= max;
const count = value => Number.isSafeInteger(value) && inRange(value, 0, 10000);
const species = value => ['triceratops', 'trex', 'raptor'].includes(value);

function validPlayers(data) {
  return Array.isArray(data.players) && data.players.length === (data.mode === 'coop' ? 2 : 1)
    && data.players.every(player => player && typeof player === 'object' && species(player.species)
      && inRange(player.progress, 0, 1) && Number.isInteger(player.lap) && inRange(player.lap, 1, data.laps)
      && count(player.fruit) && count(player.golden) && player.golden <= player.fruit
      && inRange(player.speed, 0.01, 1000) && inRange(player.baseSpeed, 0.01, 1000)
      && typeof player.finished === 'boolean' && player.finished === (player.progress === 1)
      && (player.progress < 1 || player.lap === data.laps))
    && data.players[0].species === data.dino && data.players[0].progress === data.progress
    && data.players[0].lap === data.lap && data.players[0].speed === data.speed && data.players[0].baseSpeed === data.baseSpeed
    && (data.mode !== 'coop' || data.players[1].progress === data.rivalProgress && data.players[1].speed === data.rivalSpeed)
    && data.fruit === data.players.reduce((total, player) => total + player.fruit, 0)
    && data.golden === data.players.reduce((total, player) => total + player.golden, 0);
}

export function validCoopFinish(data) {
  return data?.mode === 'coop' && data.stage === 'finished'
    && ['forest', 'beach', 'valley', 'volcano'].includes(data.track) && data.laps === (data.track === 'valley' ? 3 : 1)
    && validPlayers(data)
    && data.players.every(player => player.finished);
}

export function validRaceReport(data) {
  return data?.type === 'park-race' && ['competitive', 'solo', 'coop'].includes(data.mode)
    && ['ready', 'countdown', 'racing', 'finished'].includes(data.stage)
    && ['forest', 'beach', 'valley', 'volcano'].includes(data.track)
    && ['sleepy', 'playful', 'speedy', 'none'].includes(data.rival)
    && ['', 'player', 'rival', 'both'].includes(data.winner)
    && (data.mode === 'competitive' ? data.rival !== 'none' : data.rival === 'none')
    && (data.mode !== 'coop' || data.winner === '' && data.rivalDistracted === false)
    && typeof data.paused === 'boolean' && typeof data.rivalDistracted === 'boolean'
    && inRange(data.progress, 0, 1) && inRange(data.rivalProgress, 0, 1)
    && Number.isInteger(data.countdown) && inRange(data.countdown, 0, 3)
    && count(data.fruit) && count(data.golden) && count(data.streak) && count(data.arrows)
    && Number.isInteger(data.speedLevel) && inRange(data.speedLevel, 0, 3)
    && data.laps === (data.track === 'valley' ? 3 : 1) && Number.isInteger(data.lap) && inRange(data.lap, 1, data.laps)
    && [data.speed, data.baseSpeed, data.rivalSpeed].every(value => inRange(value, 0.01, 1000))
    && [data.boostLeft, data.recoveryBoostLeft, data.rivalRecoveryBoostLeft].every(value => inRange(value, 0, 6))
    && [data.lateral, data.rivalLateral].every(value => inRange(value, -3, 3))
    && ['', 'player', 'rival'].includes(data.recoveryTarget)
    && validPlayers(data)
    && (data.stage !== 'finished' || (data.mode === 'coop' ? validCoopFinish(data) : data.progress === 1));
}
