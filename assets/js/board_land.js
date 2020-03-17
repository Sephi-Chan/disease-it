import React from 'react';
import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY, tileOriginX, tileOriginY, tileImageWidth, tileImageHeight } from './map';


const itemScale = 4/5;
const itemImageWidth = 134;


export default class Land extends React.Component {
  constructor(props) {
    super(props);
  }


  shouldComponentUpdate () {
    return false;
  }


  render() {
    return <React.Fragment>
      {this.tiles()}
      {this.items()}
    </React.Fragment>
  }


  tiles() {
    return this.props.tiles.map((function(tile){
      const key = 'tile_' + tile.x + '_' + 'tile_y' + tile.y;
      return <Tile key={key} {...tile} originX={this.props.originX} originY={this.props.originY} />
    }).bind(this));
  }


  items() {
    return this.props.items.map((function(item){
      const key = 'item_' + item.x + '_' + item.y + '_' + item.offsetX + '_' + item.offsetY;
      return <Item key={key} {...item} originX={this.props.originX} originY={this.props.originY} />;
    }).bind(this));
  }
};


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
