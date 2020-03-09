import React from 'react';
import Push from './push';


const diseases = [ 'Peste', 'Choléra', 'Lèpre', 'Variole' ];


export default class Lobby extends React.Component {
  constructor(props) {
    super(props);
    this.state = { gameId: null, phase: null, players: [] };
    this.startButtonClicked = this.startButtonClicked.bind(this);
    this.updateGame = this.updateGame.bind(this);
  }


  componentDidMount() {
    Push.game = Push.socket.channel('game:' + this.props.gameId, {});
    Push.game.join().receive('ok', this.updateGame);
    Push.game.on('player_joined_lobby', this.updateGame);
    Push.game.on('player_left_lobby', this.updateGame);
    Push.game.on('disabling_phase_started', this.updateGame);
  }


  render() {
    const isLeader = this.state.players[0] == this.props.playerId;

    return <div className='container lobby'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>

      <p id='share-message'>
        <span>Partagez</span> l'adresse de cette page avec vos amis pour qu'ils puissent se joindre à la partie.
        {isLeader && <React.Fragment><span> Lancez</span> ensuite la partie.</React.Fragment>}
      </p>

      <div id='slots'>
        {this.slot(0)}
        {this.slot(1)}
        {this.slot(2)}
        {this.slot(3)}
        {this.startButton()}
      </div>

      <p id='goal-message'>
        Vous incarnez <span>une maladie</span> et vous devez <span>infecter</span> le plus d'humains possible avant
        de <span>quitter l'île par bateau</span> pour vous répandre à travers le monde…
      </p>
    </div>;
  }


  startButton() {
    const classes = [ 'button', this.isButtonEnabled() ? 'enabled' : null ].join(' ');
    return <div id='start-game' className={classes} onClick={this.startButtonClicked}></div>;
  }


  isButtonEnabled() {
    const isLeader = this.state.players[0] == this.props.playerId;
    const hasEnoughPlayers = this.state.players.length >= 2

    return isLeader && hasEnoughPlayers;
  }


  startButtonClicked() {
    window.sounds.horn.play();
    Push.game.push('start_disabling_phase', {});
  }


  slot(index) {
    const isEmpty = !this.state.players[index]
    const isSelf = this.props.playerId == this.state.players[index];
    const classes = [ 'slot', isEmpty ? 'empty' : null, isSelf ? 'self' : null ].join(' ');
    return <div id={`slot-${index + 1}`} className={classes}>{diseases[index]}</div>
  }


  updateGame(game) {
    if (game.phase == 'disabling') {
      this.props.disablingPhaseStarted(game);
    }
    else {
      this.setState({ players: game.players });
    }
  }
}
