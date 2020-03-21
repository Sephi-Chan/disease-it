import React from 'react';
import Ocean from './board_ocean';
import Land from './board_land';
import Path from './board_path';
import Badge from './board_badge';
import PlagueDoctors from './board_plague_doctors';
import Players from './board_players';
import { remap, objectFromArray, parseTile } from './utils';


export default class Board extends React.Component {
  constructor(props) {
    super(props);
    this.buildState(props);
  }


  render() {
    const player = this.props.game ? this.props.game[this.props.playerId] : null;
    const playerTile = player ? player.path[0] : null;
    const disabledTiles = objectFromArray(this.props.game ? this.props.game.disabledTiles : []);
    const neighbourTiles = player ? this.neighboursOf(player.path[0]) : [];

    return <div id='map' className={this.props.game ? this.props.game.phase : null}>
      {this.badges(playerTile, disabledTiles, neighbourTiles)}
      {this.props.game && <Players game={this.props.game} originX={this.state.originX} originY={this.state.originY} playerId={this.props.playerId} />}
      <PlagueDoctors tiles={this.props.tiles} disabledTiles={disabledTiles} originX={this.state.originX} originY={this.state.originY} phase={this.props.game ? this.props.game.phase : null} />
      <Land items={this.props.items} tiles={this.props.tiles} originX={this.state.originX} originY={this.state.originY} />
      <Ocean tiles={this.state.tiles} originX={this.state.originX} originY={this.state.originY} />
      {player && <Path tiles={this.state.tiles} originX={this.state.originX} originY={this.state.originY} player={player} />}
    </div>
  }


  badges(playerTile, disabledTiles, neighbourTiles) {
    return this.state.tiles.map((function(tile){
      const key = tile.x + '_' + tile.y;
      const isVisible = disabledTiles[key] == undefined && playerTile != key;
      const isActive = isVisible && this.isBadgeActive(key, tile.diceRolls, disabledTiles, neighbourTiles);

      if (isVisible) return <Badge key={key} {...tile} originX={this.state.originX} originY={this.state.originY} isActive={isActive} onBadgeClick={this.props.onBadgeClick} />
      else return null;
    }).bind(this));
  }


  isBadgeActive(tile, acceptedRolls, disabledTiles, neighbourTiles) {
    if (this.props.game && this.props.game.phase == 'exploration') {
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
