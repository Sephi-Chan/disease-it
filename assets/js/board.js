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


function remap(value, min1, max1, min2, max2) {
  return (value - min1) * (max2 - min2) / (max1 - min1) + min2;
}


export default class Board extends React.Component {
  constructor(props) {
    super(props);
    this.buildState(props);
  }


  render() {
    return <div id='map'>
      {this.tiles()}
      {this.shorelines()}
      {this.items()}
      {this.player()}
    </div>
  }


  tiles() {
    return this.state.tiles.map((function(tile){
      const key = tile.x + '_' + tile.y;
      const isActive = this.isBadgeActive(tile.x, tile.y);

      return <React.Fragment key={key}>
        <Tile {...tile} originX={this.state.originX} originY={this.state.originY} />
        <Badge {...tile} originX={this.state.originX} originY={this.state.originY} isActive={isActive} onTileDisabling={this.props.onTileDisabling} />
      </React.Fragment>;
    }).bind(this));
  }


  isBadgeActive(x, y) {
    if (this.props.game && this.props.game.phase == 'disabling') {
      const playerDisabledAllHisTiles = this.props.game[this.props.playerId].tilesToDisable == 0;
      const hasNoItemOnTile = this.props.items.filter(item => item.x == x && item.y == y).length == 0;
      const isNotDisabled = this.props.disabledTilesByPlayer.indexOf(x + '_' + y) == -1;
      const noNeighbourIsDisabled = this.neighboursOf(x, y).map(tile => this.props.disabledTilesByPlayer.indexOf(tile) != -1).filter(Boolean).length == 0;
      return !playerDisabledAllHisTiles && hasNoItemOnTile && isNotDisabled && noNeighbourIsDisabled;
    }
    else if (this.props.game && this.props.game.phase == 'exploration') {
      const boardIndex = this.props.game[this.props.playerId].boardIndex;
      const disabledTiles = this.props.game.disabledTiles[boardIndex];
      return disabledTiles.indexOf(x + '_' + y) == -1;
    }
    else {
      return true;
    }
  }


  neighboursOf(x, y) {
    return [
      (x + 1) + "_" + (y + 1),
      (x + 1) + "_" + y,
      x + "_" + (y - 1),
      (x - 1) + "_" + (y - 1),
      (x - 1) + "_" + y,
      x + "_" + (y + 1)
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
      return <Item key={key} {...item} originX={this.state.originX} originY={this.state.originY} />;
    }).bind(this));
  }


  player() {
    if (!(this.props.game && (this.props.game.phase == "disabling" || this.props.game.phase == "exploration"))) return;

    const player = this.props.game[this.props.playerId];
    const [x, y] = player.path[0].split("_").map(i => parseInt(i));
    const style = {
      left: Math.round(this.props.originX + (distanceBetweenOriginsX * (x - y) * scale) - (playerIconImageWidth / 2 * scale)),
      top: Math.round(this.props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (badgeHitboxTopShift * scale) - 15),
      width: Math.round(playerIconImageWidth * scale),
      zIndex: 210000000,
    }

    return <img src={'/images/icons/icon_player.png'} style={style} draggable='false' />;
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
      zIndex: 200000000,
    };

    return <div className={classes} style={style} onClick={this.props.isActive ? this.badgeClicked : null}>
      <img src={'/images/icons/icon_' + this.props.diceRolls[0] + '.png'}  draggable='false' style={imageStyle} />
    </div>;
  }


  badgeClicked() {
    this.props.onTileDisabling({ x: this.props.x, y: this.props.y })
  }
}


function Item({ x, y, item, offsetX, offsetY, originX, originY }) {
  const classes = [ 'item', item ].join(' ')
  const style = {
    left: Math.round(originX + (distanceBetweenOriginsX * (x - y) * scale) - (itemImageWidth/2*scale*itemScale) + (offsetX * itemScale * scale)),
    top: Math.round(originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) - (itemImageWidth/2*scale*itemScale) + (offsetY * itemScale * scale)),
    width: Math.round(itemImageWidth * itemScale * scale),
    zIndex: 100000000
  };

  return <img src={'/images/items/item_' + item + '.png'} style={style} draggable='false' className={classes} />
}
