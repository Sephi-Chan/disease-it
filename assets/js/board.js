import React from 'react';
import Ocean from './board_ocean';
import Land from './board_land';
import PlagueDoctors from './board_plague_doctors';
import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY, playerIconImageWidth, badgeHitboxTopShift, badgeHitboxWidth, badgeHitboxHeight, badgeImageWidth } from './map';


function remap(value, min1, max1, min2, max2) {
  return (value - min1) * (max2 - min2) / (max1 - min1) + min2;
}


export default class Board extends React.Component {
  constructor(props) {
    super(props);
    this.buildState(props);
  }


  render() {
    const player = this.props.game ? this.props.game[this.props.playerId] : null;
    const playerTile = player ? player.path[0] : null;
    const tilesWithItems = objectFromArray(this.props.items.map(({x, y}) => x + '_' + y));
    const disabledTiles = objectFromArray(this.props.game ? this.props.game.disabledTiles[player.boardIndex] : []);
    const neighbourTiles = player ? this.neighboursOf(player.path[0]) : [];

    return <div id='map' className={this.props.game ? this.props.game.phase : null}>
      {this.badges(playerTile, tilesWithItems, disabledTiles, neighbourTiles)}
      {this.player()}
      <PlagueDoctors tiles={this.props.tiles} disabledTiles={disabledTiles} originX={this.state.originX} originY={this.state.originY} phase={this.props.game ? this.props.game.phase : null} />
      <Land items={this.props.items} tiles={this.props.tiles} originX={this.state.originX} originY={this.state.originY} />
      <Ocean tiles={this.state.tiles} originX={this.state.originX} originY={this.state.originY} />
      {player && this.path(player)}
    </div>
  }


  path(player) {
    const path = player.path.reverse();
    const followedPaths = {};

    return path.map(function(tile, index){
      const nextTile = path[index + 1];

      if (nextTile && !followedPaths[tile + '_' + nextTile]) {
        const [nX, nY] = nextTile ? parseTile(nextTile) : [ null, null ];
        const [x, y] = parseTile(tile);
        const dX = x - nX;
        const dY = y - nY;
        const [direction, imageDirection, shiftX, shiftY] = pathDirection(dX, dY);
        const key = 'step_' + index;
        const style = {
          left: Math.round(this.props.originX + (distanceBetweenOriginsX * (x - y) * scale) + shiftX),
          top: Math.round(this.props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) + shiftY),
          zIndex: 20000000
        };
        followedPaths[tile + '_' + nextTile] = true;
        followedPaths[nextTile + '_' + tile] = true;

        return <img key={key} src={'/images/paths/path-' + imageDirection + '.png'} style={style} className="path" draggable='false' />;
      }
      else {
        return null;
      }
    }.bind(this));
  }


  badges(playerTile, tilesWithItems, disabledTiles, neighbourTiles) {
    return this.state.tiles.map((function(tile){
      const key = tile.x + '_' + tile.y;
      const isVisible = disabledTiles[key] == undefined && playerTile != key;
      const isActive = isVisible && this.isBadgeActive(key, tile.diceRolls, tilesWithItems, disabledTiles, neighbourTiles);

      if (isVisible) return <Badge key={key} {...tile} originX={this.state.originX} originY={this.state.originY} isActive={isActive} onBadgeClick={this.props.onBadgeClick} />
      else return null;
    }).bind(this));
  }


  isBadgeActive(tile, acceptedRolls, tilesWithItems, disabledTiles, neighbourTiles) {
    if (this.props.game && this.props.game.phase == 'disabling') {
      if (this.props.game[this.props.playerId].tilesToDisable == 0) return false;
      if (tilesWithItems[tile]) return false;
      if (disabledTiles[tile]) return false;
      return this.neighboursOf(tile).map(neighbour => disabledTiles[neighbour]).filter(Boolean).length == 0;
    }
    else if (this.props.game && this.props.game.phase == 'exploration') {
      if (this.props.game.gonePlayers.includes(this.props.playerId)) return false;
      if (this.props.game[this.props.playerId].currentRound != null) return false;
      return neighbourTiles.filter(tile => !disabledTiles[tile]).indexOf(tile) != -1
        && (this.props.game.dicesRolls || []).indexOf(acceptedRolls[0]) != -1;
    }
    else {
      return true;
    }
  }


  neighboursOf(tile) {
    const [x, y] = tile.split('_').map(i => parseInt(i));

    return [
      (x + 1) + '_' + (y + 1),
      (x + 1) + '_' + y,
      x + '_' + (y - 1),
      (x - 1) + '_' + (y - 1),
      (x - 1) + '_' + y,
      x + '_' + (y + 1)
    ];
  }


  player() {
    if (!this.props.game || this.props.game.phase == 'lobby') return null;

    const player = this.props.game[this.props.playerId];
    const classes = [ 'player', (this.props.game.gonePlayers || []).indexOf(this.props.playerId) != -1 ? 'gone leaving' : null ].join(' ');
    const [x, y] = parseTile(player.path[0]);
    const style = {
      left: Math.round(this.props.originX + (distanceBetweenOriginsX * (x - y) * scale) - (playerIconImageWidth / 2 * scale)),
      top: Math.round(this.props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (badgeHitboxTopShift * scale) - 15),
      width: Math.round(playerIconImageWidth * scale),
      zIndex: 210000000
    }

    return <img src={'/images/icons/icon_player.png'} className={classes} style={style} draggable='false' />;
  }


  buildState(props) {
    this.state = {
      tiles: props.tiles,
      originX: props.originX, originY: props.originY,
      minX: 0, maxX: 0,
      minY: 0, maxY: 0,
      maxZIndex: 0,
      existingTiles: {}
    };

    this.state.tiles.map((function({ x, y }){
      if (x < this.state.minX) this.state.minX = x;
      if (x > this.state.maxX) this.state.maxX = x;
      if (y < this.state.minY) this.state.minY = y;
      if (y > this.state.maxY) this.state.maxY = y;
      this.state.existingTiles[x + '_' + y] = true;
    }).bind(this));

    this.state.tiles.map((function(tile){
      const scoreY = Math.round(remap(tile.y, this.state.maxY, this.state.minY, 1, 1000));
      const scoreX = Math.round(remap(tile.x, this.state.minX, this.state.maxX, 1, 1000));
      tile.zIndex = scoreY * 10000 - scoreX;
      if (tile.zIndex > this.state.maxZIndex) this.state.maxZIndex = tile.zIndex;
    }).bind(this));
  }
}


class Badge extends React.Component {
  constructor(props) {
    super(props);
    this.badgeClicked = this.badgeClicked.bind(this);
  }


  render() {
    const imageStyle = {
      width: Math.round(badgeImageWidth * scale),
      marginLeft: -badgeImageWidth / 2 * scale
    };
    const classes = [ 'badge', this.props.isActive ? 'active' : null ].join(' ')
    const style = {
      left: Math.round(this.props.originX + (distanceBetweenOriginsX * (this.props.x - this.props.y) * scale) - (badgeHitboxWidth / 2 * scale)),
      top: Math.round(this.props.originY - (distanceBetweenOriginsY / 2 * (this.props.x + this.props.y) * scale) - (badgeHitboxTopShift * scale)),
      width: Math.round(badgeHitboxWidth * scale),
      height: Math.round(badgeHitboxHeight * scale),
      zIndex: this.props.zIndex + 250000000,
    };

    return <div className={classes} style={style} onClick={this.props.isActive ? this.badgeClicked : null}>
      <img src={'/images/icons/icon_' + this.props.diceRolls[0] + '.png'}  draggable='false' style={imageStyle} />
    </div>;
  }


  badgeClicked() {
    this.props.onBadgeClick({ x: this.props.x, y: this.props.y });
  }
}


function parseTile(tileAsString) {
  return tileAsString.split('_').map(i => parseInt(i));
}


function objectFromArray(array) {
  return array.reduce(function(acc, item) {
    acc[item] = true;
    return acc;
  }, {});
}


function pathDirection(x, y) {
  if (x == -1 && y == 0) return ['up-right', 'up-right', 0, -65];
  if (x == -1 && y == -1) return ['up', 'up', 0, -110];
  if (x == 1 && y == 1) return ['down', 'up', -10, -10];
  if (x == 0 && y == 1) return ['down-right', 'down-right', 0, -10];
  if (x == 1 && y == 0) return ['down-left', 'up-right', -177, 0];
  if (x == 0 && y == -1) return ['up-left', 'down-right', -177, -75];
}
