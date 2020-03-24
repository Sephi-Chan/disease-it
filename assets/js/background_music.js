import React from 'react';


export default class extends React.Component {
  constructor(props) {
    super(props);

    const acceptsMusic = [ 'yes', null ].includes(localStorage.getItem('accept_music'));
    const audio = new Audio('/audio/spiky-whimsical-fantasy-the-docks.mp3');
    audio.loop = true;
    audio.autoplay = acceptsMusic;

    this.state = { audio, acceptsMusic };
    this.toggle = this.toggle.bind(this);
  }


  componentDidMount() {
    this.state.audio.addEventListener('play', function() {
      this.setState();
    }.bind(this));
  }


  render() {
    if (this.state.acceptsMusic) this.state.audio.play();
    const classes = this.state.audio.paused ? 'muted' : 'active';
    return <img id='toggle-music-button' src='/images/icons/icon_sound.png' onClick={this.toggle} className={classes} />;
  }


  toggle() {
    if (this.state.audio.paused) {
      this.state.audio.play();
      this.setState({ acceptsMusic: true });
      localStorage.setItem('accept_music', 'yes');
    }
    else {
      this.state.audio.pause();
      this.setState({ acceptsMusic: false });
      localStorage.setItem('accept_music', 'no');
    }
  }
}
