import React from 'react';


export default class extends React.Component {
  constructor(props) {
    super(props);

    const storedHd = localStorage.getItem('hd');
    const hd = storedHd == null ? true : storedHd == 'yes';
    this.state = { hd: hd };
    this.toggle = this.toggle.bind(this);
  }

  componentDidMount() {
    if (this.state.hd == false) document.body.classList.add('light');
  }


  render() {
    return <img src='/images/icons/icon_hd.png' id='toggle-hd-button'
      onClick={this.toggle} className={this.state.hd ? 'active' : 'muted'} />;
  }


  toggle() {
    if (this.state.hd) {
      this.setState({hd: false});
      document.body.classList.add('light');
      localStorage.setItem('hd', 'no');
    }
    else {
      this.setState({hd: true });
      document.body.classList.remove('light');
      localStorage.setItem('hd', 'yes');
    }
  }
}
