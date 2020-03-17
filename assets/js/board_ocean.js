import React from 'react';
import { scale, hexagonWidth, distanceBetweenOriginsX, distanceBetweenOriginsY, tileImageWidth, tileImageHeight, tileOriginX, tileOriginY } from './map';


export default class Ocean extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      existingTiles: props.tiles.reduce(function(acc, { x,  y }) {
        acc[x + '_' + y] = true;
        return acc;
      }, {})
    };
  }


  shouldComponentUpdate () {
    return false;
  }


  render() {
    return <React.Fragment>
      {this.shorelines()}
      {this.waves()}
    </React.Fragment>
  }


  waves() {
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


  shorelines() {
    return this.props.tiles.map((function({ x, y }){
      return this.shorelinesForTile(x, y).map((function([[x, y], direction]) {
        const key = 'shoreline_' + x + '_' + y;
        return <Shoreline key={key} x={x} y={y} direction={direction} originX={this.props.originX} originY={this.props.originY} />;
      }).bind(this));
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
      return !this.state.existingTiles[x + '_' + y];
    }).bind(this));
  }
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
