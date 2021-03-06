import React from 'react';
import Push from './push';
import camelCase from './camelcaser';
import Board from './board';
import { tiles, items } from './map';
import { diseases, diseasesIcons } from './diseases';


export default class Lobby extends React.Component {
  constructor(props) {
    super(props);
    this.state = { gameId: null, phase: null, players: [] };
    this.startButtonClicked = this.startButtonClicked.bind(this);
    this.updateGame = this.updateGame.bind(this);
    this.explorationPhaseStarted = this.explorationPhaseStarted.bind(this);
  }


  componentDidMount() {
    Push.game = Push.socket.channel('game:' + this.props.gameId, {});
    Push.game.join().receive('ok', this.updateGame);
    Push.game.on('player_joined_lobby', this.updateGame);
    Push.game.on('player_left_lobby', this.updateGame);
    Push.game.on('exploration_phase_started', this.explorationPhaseStarted);
  }


  render() {
    const isLeader = this.state.players[0] == this.props.playerId;

    return <div className='container lobby'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>

      <div className='instructions-container tall'>
        <p>
          <span>Partagez</span> l'adresse de cette page avec vos amis pour qu'ils puissent se joindre à la partie.
          {isLeader
            ? <React.Fragment> <span>Lancez</span> ensuite la partie.</React.Fragment>
            : <React.Fragment> <span>Attendez</span> ensuite que l'hôte lance la partie.</React.Fragment>
          }
        </p>

        <div className='slots'>
          {this.slot(0)}
          {this.slot(1)}
          {this.slot(2)}
          {this.slot(3)}
        </div>

        {this.startGameButton()}
      </div>

      <Board width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} />
    </div>;
  }


  startGameButton() {
    const isLeader = this.state.players[0] == this.props.playerId;
    const hasEnoughPlayers = this.state.players.length >= 2
    const classes = [ 'button', hasEnoughPlayers && 'enabled' ].join(' ');
    return isLeader && <div className={classes} onClick={hasEnoughPlayers ? this.startButtonClicked : null}>Lancer la partie</div>
  }


  startButtonClicked() {
    Push.game.push('start_exploration_phase', {});
  }


  explorationPhaseStarted(game) {
    window.sounds.horn.play();
    this.props.updateGame(camelCase(game));
  }


  slot(index) {
    const isEmpty = !this.state.players[index]
    const isSelf = this.props.playerId == this.state.players[index];
    const classes = [ 'slot', isEmpty ? 'empty' : null, isSelf ? 'self' : null ].join(' ');
    const srcSuffix = isSelf ? '_self' : '';
    return <div className={classes}>
      <img src={`/images/icons/icon_${diseases[index].id}${srcSuffix}.png`} />
      {diseases[index].name}
    </div>;
  }


  updateGame(game) {
    this.setState({ players: game.players });
  }
}
