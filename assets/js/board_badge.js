import React from 'react';
import { scale, distanceBetweenOriginsX, distanceBetweenOriginsY, badgeHitboxTopShift, badgeHitboxWidth, badgeHitboxHeight, badgeImageWidth } from './map';


export default class Badge extends React.Component {
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
      zIndex: this.props.zIndex + 220000000,
    };

    return <div className={classes} style={style} onClick={this.props.isActive ? this.badgeClicked : null}>
      <img src={'/images/icons/icon_' + this.props.diceRolls[0] + '.png'}  draggable='false' style={imageStyle} />
    </div>;
  }


  badgeClicked() {
    this.props.onBadgeClick({ x: this.props.x, y: this.props.y });
  }
}
