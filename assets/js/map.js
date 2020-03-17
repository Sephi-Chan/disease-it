const tiles = [
  { x: 3,  y: 2,  terrain: 'forest_11',    diceRolls: [1] },
  { x: 3,  y: 1,  terrain: 'grassland_1',  diceRolls: [6] },
  { x: 2,  y: 1,  terrain: 'mountain_12',  diceRolls: [5] },
  { x: 2,  y: 2,  terrain: 'grassland_1',  diceRolls: [3] },
  { x: -2, y: -3, terrain: 'grassland_1',  diceRolls: [1] },
  { x: -4, y: -3, terrain: 'mountain_9',   diceRolls: [6] },
  { x: -4, y: -2, terrain: 'forest_16',    diceRolls: [2] },
  { x: -4, y: -1, terrain: 'grassland_16', diceRolls: [1] },
  { x: -3, y: -3, terrain: 'forest_17',    diceRolls: [4] },
  { x: 0,  y: -2, terrain: 'forest_17',    diceRolls: [6] },
  { x: -2, y: -2, terrain: 'grassland_16', diceRolls: [6] },
  { x: -1, y: -2, terrain: 'forest_11',    diceRolls: [2] },
  { x: -3, y: -1, terrain: 'forest_19',    diceRolls: [3] },
  { x: -2, y: -1, terrain: 'mountain_2',   diceRolls: [4] },
  { x: -1, y: -1, terrain: 'mountain_5',   diceRolls: [5] },
  { x: 0,  y: -1, terrain: 'forest_11',    diceRolls: [4] },
  { x: 1,  y: -1, terrain: 'grassland_4',  diceRolls: [1] },
  { x: 1,  y: 0,  terrain: 'grassland_4',  diceRolls: [5] },
  { x: -2, y: 0,  terrain: 'forest_11',    diceRolls: [4] },
  { x: -1, y: 0,  terrain: 'grassland_1',  diceRolls: [4] },
  { x: 0,  y: 0,  terrain: 'forest_11',    diceRolls: [5] },
  { x: -3, y: -2, terrain: 'grassland_10', diceRolls: [5] },
  { x: -2, y: 1,  terrain: 'grassland_10', diceRolls: [2] },
  { x: -1, y: 1,  terrain: 'grassland_19', diceRolls: [5] },
  { x: 0,  y: 1,  terrain: 'grassland_10', diceRolls: [2] },
  { x: 1,  y: 1,  terrain: 'grassland_16', diceRolls: [3] },
  { x: 2,  y: 0,  terrain: 'grassland_14', diceRolls: [4] },
  { x: 2,  y: -1, terrain: 'forest_16',    diceRolls: [3] },
  { x: -1, y: -3, terrain: 'grassland_16', diceRolls: [2] },
  { x: -3, y: -4, terrain: 'grassland_1',  diceRolls: [3] },
  { x: -2, y: -4, terrain: 'mountain_6',   diceRolls: [6] },
  { x: -1, y: -4, terrain: 'grassland_14', diceRolls: [1] },
  { x: 1,  y: -2, terrain: 'grassland_16', diceRolls: [3] }
];

const items = [
  { item: 'tower', x: 2, y: 2, offsetX: -140, offsetY: -40 },
  { item: 'church', x: -2, y: -3, offsetX: -30, offsetY: 10 },
  { item: 'castle', x: 3, y: 1, offsetX: 150, offsetY: -70 },
  { item: 'tents', x: 1, y: -1, offsetX: 90, offsetY: -40 },
  { item: 'ship', x: 3, y: 1, offsetX: 270, offsetY: -110 },
  { item: 'ship', x: 3, y: 1, offsetX: 320, offsetY: -60 },
  { item: 'city', x: 0, y: 1, offsetX: -100, offsetY: -40 },
  { item: 'fortified_city', x: -2, y: -2, offsetX: -100, offsetY: -70 },
  { item: 'mill', x: -2, y: 1, offsetX: 60, offsetY: -20 },
  { item: 'sunk_ship', x: -4, y: -1, offsetX: -130, offsetY: 50 },
];


const scale = 3/4;
const hexagonWidth = 340;
const hexagonHeight = 135;
const distanceBetweenOriginsX = hexagonWidth * 2/3;
const distanceBetweenOriginsY = hexagonHeight;
const badgeImageWidth = 50;
const badgeHitboxWidth = 200;
const badgeHitboxHeight = 100;
const badgeHitboxTopShift = 55;
const playerIconImageWidth = 100;
const tileImageWidth = 380;
const tileImageHeight = 380;
const tileOriginX = 190;
const tileOriginY = 290;
const plagueDoctorImageWidth = 100;


export {
  tiles,
  items,
  scale,
  hexagonWidth,
  hexagonHeight,
  distanceBetweenOriginsX,
  distanceBetweenOriginsY,
  badgeImageWidth,
  badgeHitboxWidth,
  badgeHitboxHeight,
  badgeHitboxTopShift,
  playerIconImageWidth,
  tileImageWidth,
  tileImageHeight,
  tileOriginX,
  tileOriginY,
  plagueDoctorImageWidth
};
