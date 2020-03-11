import camelcaseKeys from 'camelcase-keys';

export default function(game) {
  return camelcaseKeys(game, { deep: true, exclude: game.players });
}
