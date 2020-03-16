import React from 'react';

const scale = 3/4;
const itemScale = 4/5;
const tileImageWidth = 380;
const tileImageHeight = 380;
const tileOriginX = 190;
const tileOriginY = 290;
const hexagonWidth = 340;
const hexagonHeight = 135;
const distanceBetweenOriginsX = hexagonWidth * 2/3;
const distanceBetweenOriginsY = hexagonHeight;
const badgeImageWidth = 50;
const badgeHitboxWidth = 200;
const badgeHitboxHeight = 100;
const badgeHitboxTopShift = 55;
const itemImageWidth = 134;
const playerIconImageWidth = 100;
const plagueDoctorImageWidth = 100;


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
      {this.tiles(playerTile, tilesWithItems, disabledTiles, neighbourTiles)}
      {this.shorelines()}
      {this.items()}
      {this.player()}
      {this.plagueDoctors(disabledTiles)}
      {this.ocean()}
    </div>
  }


  tiles(playerTile, tilesWithItems, disabledTiles, neighbourTiles) {
    return this.state.tiles.map((function(tile){
      const key = tile.x + '_' + tile.y;
      const isVisible = disabledTiles[key] == undefined && playerTile != key;
      const isActive = isVisible && this.isBadgeActive(key, tile.diceRolls, tilesWithItems, disabledTiles, neighbourTiles);

      return <React.Fragment key={key}>
        <Tile {...tile} originX={this.state.originX} originY={this.state.originY} />
        {isVisible && <Badge {...tile} originX={this.state.originX} originY={this.state.originY} isActive={isActive} onBadgeClick={this.props.onBadgeClick} />}
      </React.Fragment>;
    }).bind(this));
  }


  ocean() {
    return <div className="waves">
      <img src="/images/tiles/tile_ocean_1.png" width={hexagonWidth * scale} className="wave wave-1" style={{left: -40, top: 390 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_2.png" width={hexagonWidth * scale} className="wave wave-2" style={{left: 20, top: 640 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_15.png" width={hexagonWidth * scale} className="wave wave-4" style={{left: 300, top: 670 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_6.png" width={hexagonWidth * scale} className="wave wave-3" style={{left: 645, top: 670 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_17.png" width={hexagonWidth * scale} className="wave wave-2" style={{left: 990, top: 665 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_0.png" width={hexagonWidth * scale} className="wave wave-1" style={{left: 1200, top: 600 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_1.png" width={hexagonWidth * scale} className="wave wave-1" style={{left: 1225, top: 375 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_8.png" width={hexagonWidth * scale} className="wave wave-3" style={{left: 1230, top: 60 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_8.png" width={hexagonWidth * scale} className="wave wave-4" style={{left: 1110, top: -100 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_6.png" width={hexagonWidth * scale} className="wave wave-2" style={{left: 900, top: -160 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_10.png" width={hexagonWidth * scale} className="wave wave-4" style={{left: 620, top: -130 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_0.png" width={hexagonWidth * scale} className="wave wave-1" style={{left: 450, top: -60 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_6.png" width={hexagonWidth * scale} className="wave wave-2" style={{left: 360, top: 55 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_17.png" width={hexagonWidth * scale} className="wave wave-3" style={{left: 145, top: 125 }} draggable="false" />
      <img src="/images/tiles/tile_ocean_15.png" width={hexagonWidth * scale} className="wave wave-1" style={{left: -55, top: 190 }} draggable="false" />
    </div>
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


  shorelines() {
    return this.state.tiles.map((function({ x, y }){
      return this.shorelinesForTile(x, y).map((function([[x, y], direction]) {
        const key = 'shoreline_' + x + '_' + y;
        return <Shoreline key={key} x={x} y={y} direction={direction} originX={this.state.originX} originY={this.state.originY} />;
      }).bind(this));
    }).bind(this));
  }


  items() {
    return this.props.items.map((function(item){
      const key = 'item_' + item.x + '_' + item.y + '_' + item.offsetX + '_' + item.offsetY;
      const alreadyVisited = this.props.game && this.props.game[this.props.playerId].path.includes(item.x + '_' + item.y);
      return <Item key={key} {...item} originX={this.state.originX} originY={this.state.originY} alreadyVisited={alreadyVisited} />;
    }).bind(this));
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


  plagueDoctors(disabledTiles) {
    return this.state.tiles.map(function({ x, y, zIndex }) {
      if (disabledTiles[x + '_' + y]) {
        const key = 'plague_doctor_' + x + '_' + y;
        const style = {
          left: Math.round(this.props.originX + (distanceBetweenOriginsX * (x - y) * scale) - (plagueDoctorImageWidth / 2 * scale)),
          top: Math.round(this.props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (90 * scale)),
          width: Math.round(plagueDoctorImageWidth * scale),
          zIndex: zIndex + 300
        }
        return <img key={key} src={'/images/items/item_plague_doctor.png'} style={style} draggable='false' />;
      }
      else return null;
    }.bind(this));
  }


  buildState(props) {
    this.state = {
      tiles: props.tiles,
      originX: props.originX, originY: props.originY,
      minX: 0, maxX: 0,
      minY: 0, maxY: 0,
      maxZIndex: 0,
      tileIndexes: {}
    };

    this.state.tiles.map((function({ x, y }){
      if (x < this.state.minX) this.state.minX = x;
      if (x > this.state.maxX) this.state.maxX = x;
      if (y < this.state.minY) this.state.minY = y;
      if (y > this.state.maxY) this.state.maxY = y;
      this.state.tileIndexes[x + '_' + y] = true;
    }).bind(this));

    this.state.tiles.map((function(tile){
      const scoreY = Math.round(remap(tile.y, this.state.maxY, this.state.minY, 1, 1000));
      const scoreX = Math.round(remap(tile.x, this.state.minX, this.state.maxX, 1, 1000));
      tile.zIndex = scoreY * 10000 - scoreX;
      if (tile.zIndex > this.state.maxZIndex) this.state.maxZIndex = tile.zIndex;
    }).bind(this));
  }


  shorelinesForTile(x, y) {
    return [
      [ [ (x + 1), (y + 1) ], 'south' ],
      [ [ (x + 1), y ], 'south_west' ],
      [ [ x, (y - 1) ], 'north_west' ],
      [ [ (x - 1), (y - 1) ], 'north' ],
      [ [ (x - 1), y ], 'north_east' ],
      [ [ x, (y + 1) ], 'south_east' ]
    ].filter((function([[x, y], direction]) {
      return !this.state.tileIndexes[x + '_' + y];
    }).bind(this));
  }
}


function Tile({ x, y, terrain, zIndex, originX, originY }) {
  const style = {
    left: Math.round(originX - (tileOriginX * scale) + (distanceBetweenOriginsX * (x - y) * scale)),
    top: Math.round(originY - (tileOriginY * scale) - (distanceBetweenOriginsY / 2 * (x + y) * scale)),
    width: Math.round(tileImageWidth * scale),
    height: Math.round(tileImageHeight * scale),
    zIndex: zIndex
  }

  return <img src={'/images/tiles/tile_' + terrain + '.png'} style={style} draggable='false' />;
}


function Shoreline({ x, y, direction, originX, originY }) {
  const classes = [ 'shoreline', direction ].join(' ');
  const style = {
    left: Math.round(originX - (tileOriginX * scale) + (distanceBetweenOriginsX * (x - y) * scale)),
    top: Math.round(originY - (tileOriginY * scale) - (distanceBetweenOriginsY / 2 * (x + y) * scale)),
    width: Math.round(tileImageWidth * scale),
    height: Math.round(tileImageHeight * scale)
  };

  return <img src={'/images/shorelines/shoreline_' + direction + '.png'} style={style} draggable='false' className={classes} />
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


function Item({ x, y, item, offsetX, offsetY, originX, originY, alreadyVisited }) {
  const classes = [ 'item', item, alreadyVisited ? 'visited' : null ].join(' ')
  const style = {
    left: Math.round(originX + (distanceBetweenOriginsX * (x - y) * scale) - (itemImageWidth/2*scale*itemScale) + (offsetX * itemScale * scale)),
    top: Math.round(originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (itemImageWidth/2*scale*itemScale) + (offsetY * itemScale * scale)),
    width: Math.round(itemImageWidth * itemScale * scale),
    zIndex: 205000000
  };

  return <img src={'/images/items/item_' + item + '.png'} style={style} draggable='false' className={classes} />
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
