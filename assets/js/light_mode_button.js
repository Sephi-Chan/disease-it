import React from 'react';


export default class extends React.Component {
  constructor(props) {
    super(props);

    this.state = { hd: true };
    this.toggle = this.toggle.bind(this);
  }


  render() {
    return <img src="/images/icons/icon_hd.png" id="toggle-hd-button"
      onClick={this.toggle} className={this.state.hd ? "active" : "muted"} />;
  }


  toggle() {
    if (this.state.hd) {
      this.setState({hd: false});
      document.body.classList.add("light");
    }
    else {
       this.setState({hd: true });
      document.body.classList.remove("light");
    }
  }
}
