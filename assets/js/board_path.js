import React from 'react';
import { parseTile } from './utils';
import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY } from './map';


const pathDirections = {
  '-1_0': ['up-right', 0, -65],
  '-1_-1': ['up', 0, -110],
  '1_1': ['up', -10, -10], // down
  '0_1': ['down-right', 0, -10],
  '1_0': ['up-right', -177, 0], // down-left
  '0_-1': ['down-right', -177, -75] // up-left
};


export default function Path(props) {
  const path = props.player.path.reverse();
  const followedPaths = {};

  return path.map(function(tile, index){
    const nextTile = path[index + 1];

    if (nextTile && !followedPaths[`${tile}_${nextTile}`]) {
      const id = `${tile}_${nextTile}`;
      const [nX, nY] = nextTile ? parseTile(nextTile) : [ null, null ];
      const [x, y] = parseTile(tile);
      const dX = x - nX;
      const dY = y - nY;
      const [imageDirection, shiftX, shiftY] = pathDirections[`${dX}_${dY}`];
      const style = {
        left: Math.round(props.originX + (distanceBetweenOriginsX * (x - y) * scale) + shiftX),
        top: Math.round(props.originY - (distanceBetweenOriginsY / 2 * (x + y) * scale) + shiftY),
        zIndex: 20000000
      };
      followedPaths[id] = true;
      followedPaths[`${nextTile}_${tile}`] = true;

      return <img key={`step_${id}`} src={`/images/paths/path-${imageDirection}.png`} style={style} className="path" draggable='false' />;
    }
    else {
      return null;
    }
  }.bind(this));
}
