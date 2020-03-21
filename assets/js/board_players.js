import React from 'react';
import { diseases } from './diseases';
import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY, playerIconImageWidth, badgeHitboxTopShift } from './map';
import { parseTile } from './utils';


export default function Players(props) {
  const playersByTile = props.game.players.reduce(function(acc, playerId){
    const tile = props.game[playerId].path[0];
    if (acc[tile] == undefined) acc[tile] = [];
    acc[tile].push(playerId);
    return acc;
  }, {});

  return props.game.players.map(function(playerId, index) {
    const player = props.game[playerId];
    const tile = player.path[0];
    const [x, y] = parseTile(tile);
    const otherPlayersOnTile = playersByTile[tile].filter(playerId => (playerId != props.playerId));
    const indexOnTile = otherPlayersOnTile.indexOf(playerId);
    const iSelf = props.playerId == playerId;
    const classes = [
      'player',
      iSelf ? 'self' : null,
      (props.game.gonePlayers || []).includes(playerId) ? 'gone' : null,
      iSelf ? null : `other-player-${indexOnTile + 1}-of-${otherPlayersOnTile.length}`
    ].join(' ');
    const srcSuffix = iSelf ? '_self' : '';
    const style = {
      left: Math.round(props.originX + (distanceBetweenOriginsX * (x - y) * scale) - (playerIconImageWidth / 2 * scale)),
      top: Math.round(props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (badgeHitboxTopShift * scale) - 15),
      width: Math.round(playerIconImageWidth * scale),
      zIndex: 210000000 + (iSelf ? 100 : 0)
    }

    return <img key={playerId} src={`/images/icons/icon_${diseases[index].id}${srcSuffix}.png`} className={classes} style={style} draggable='false' />;
  })
}
