import React from 'react';
import map from './map';

import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY, plagueDoctorImageWidth } from './map';


export default class PlagueDoctors extends React.Component {
  constructor(props) {
    super(props);
  }


  shouldComponentUpdate () {
    return this.props.phase == 'disabling';
  }


  render() {
    return this.props.tiles.map(function({ x, y, zIndex }) {
      if (this.props.disabledTiles[x + '_' + y]) {
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
}
