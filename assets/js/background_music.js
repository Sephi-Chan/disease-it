import React from 'react';


export default class extends React.Component {
  constructor(props) {
    super(props);

    const storedMusic = localStorage.getItem('music');
    const music = storedMusic == null ? true : storedMusic == 'yes';

    const audio = new Audio('/audio/spiky-whimsical-fantasy-the-docks.mp3');
    audio.loop = true;
    audio.autoplay = music;

    this.state = { audio: audio, muted: true };
    this.toggle = this.toggle.bind(this);
  }


  componentDidMount() {
    this.state.audio.addEventListener('play', function() {
      this.setState({ muted: false });
    }.bind(this));
  }


  render() {
    return <img id='toggle-music-button' src='/images/icons/icon_sound.png'
      onClick={this.toggle} className={this.state.audio.paused ? 'muted' : 'active'} />;
  }


  toggle() {
    if (this.state.audio.paused) {
      this.state.audio.play();
      this.setState({ muted: false });
      localStorage.setItem('music', 'yes');
    }
    else {
      this.state.audio.pause();
      this.setState({ muted: true });
      localStorage.setItem('music', 'no');
    }
  }
}
