import { COLORS, unlocked } from './rewards.mjs?v=0.29.1';

const KEY = 'dino-race-appearances';
export const SPECIES = ['triceratops', 'trex', 'raptor'];
export const ACCESSORIES = ['none', 'cap', 'glasses'];

function validated(data, rewards) {
  return ['triceratops', 'trex'].map((species, slot) => {
    const appearance = data?.[slot];
    return {
      species: SPECIES.includes(appearance?.species) ? appearance.species : species,
      color: COLORS.find(color => color.id === appearance?.color && unlocked(color, rewards.stickers))?.id ?? 'natural',
      accessory: ACCESSORIES.includes(appearance?.accessory) ? appearance.accessory : 'none',
    };
  });
}

export function loadAppearances(storage, rewards) {
  let data;
  try {
    const saved = storage.getItem(KEY);
    data = saved === null ? [{ color: rewards.color }] : JSON.parse(saved);
  } catch {}
  return validated(data, rewards);
}

export function saveAppearances(storage, appearances, rewards) {
  try {
    storage.setItem(KEY, JSON.stringify(validated(appearances, rewards)));
  } catch {}
}
