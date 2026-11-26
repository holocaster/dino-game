import { validCoopFinish } from './race-report.mjs?v=0.34.4';

const KEY = 'dino-race-rewards';

export const STICKERS = [
  { id: 'first-lap', name: 'Primeira volta', hint: 'Complete uma volta', earned: () => true },
  { id: 'forest', name: 'Explorador da floresta', hint: 'Corra na floresta', earned: r => r.track === 'forest' },
  { id: 'beach', name: 'Explorador da praia', hint: 'Corra na praia', earned: r => r.track === 'beach' },
  { id: 'valley', name: 'Explorador do vale', hint: 'Corra no vale', earned: r => r.track === 'valley' },
  { id: 'basket', name: 'Cesta cheia', hint: 'Pegue 10 frutinhas numa corrida', earned: r => r.fruit >= 10 },
  { id: 'golden', name: 'Brilho dourado', hint: 'Pegue uma fruta dourada', earned: r => r.golden > 0 },
  { id: 'calm', name: 'Passeio tranquilo', hint: 'Dê uma volta sozinho', earned: r => r.rival === 'none' },
  { id: 'first-place', name: 'Chegou primeiro', hint: 'Chegue antes de um amigo', earned: r => r.rival !== 'none' && ['player', 'both'].includes(r.winner) },
  { id: 'speedy', name: 'Mais veloz que o Rapidinho', hint: 'Vença o Rapidinho', earned: r => r.rival === 'speedy' && r.winner === 'player' },
];

export const COLORS = [
  { id: 'natural', name: 'Natural', swatch: '#df9865', needs: 0 },
  { id: 'sunset', name: 'Pôr do sol', swatch: '#f07a5c', needs: 2 },
  { id: 'ocean', name: 'Oceano', swatch: '#64a2ee', needs: 4 },
  { id: 'candy', name: 'Algodão-doce', swatch: '#f08cd2', needs: 6 },
];

export function award(owned, result) {
  if (result.mode === 'coop' && !validCoopFinish(result)) return [];
  return STICKERS.filter(sticker => !owned.includes(sticker.id)
    && (result.mode !== 'coop' || !['calm', 'first-place', 'speedy'].includes(sticker.id))
    && sticker.earned(result)).map(sticker => sticker.id);
}

export function prizeText(previous, earned) {
  const names = earned.map(id => STICKERS.find(sticker => sticker.id === id).name);
  const colors = COLORS.filter(color => !unlocked(color, previous) && unlocked(color, [...previous, ...earned])).map(color => color.name);
  return [
    names.length ? `${names.length > 1 ? 'Novos adesivos' : 'Novo adesivo'}: ${names.join(', ')}!` : '',
    colors.length ? `${colors.length > 1 ? 'Novas cores liberadas' : 'Nova cor liberada'}: ${colors.join(' e ')}.` : '',
  ].filter(Boolean).join(' ');
}

export function unlocked(color, owned) {
  return owned.length >= color.needs;
}

export function loadRewards(storage) {
  try {
    const data = JSON.parse(storage.getItem(KEY) ?? '{}');
    const stickers = Array.isArray(data.stickers) ? STICKERS.map(s => s.id).filter(id => data.stickers.includes(id)) : [];
    const color = COLORS.find(c => c.id === data.color && unlocked(c, stickers))?.id ?? 'natural';
    return { stickers, color };
  } catch {
    return { stickers: [], color: 'natural' };
  }
}

export function saveRewards(storage, rewards) {
  try {
    storage.setItem(KEY, JSON.stringify(rewards));
  } catch {}
}
