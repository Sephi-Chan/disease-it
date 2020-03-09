import css from '../css/app.css';
import 'phoenix_html'
import 'phaser';
import React from 'react';
import { render } from 'react-dom';

import Home from './home';
import Lobby from './lobby';
import Game from './game';
import BackgroundMusic from './background_music';
import Push from './push';
import _ from './prefetch';


class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = { gameId: null, game: props.game };
    this.openLobbyClicked = this.openLobbyClicked.bind(this);
    this.disablingPhaseStarted = this.disablingPhaseStarted.bind(this);
  }


  render() {
    return <React.Fragment>
      {this.getScene(this.state.gameId || this.props.gameId, this.state.game)}
      <BackgroundMusic />
    </React.Fragment>;
  }


  getScene(gameId, game) {
    if (game) {
      return <Game {...this.props} game={game} />;
    }
    else if (gameId) {
      return <Lobby {...this.props} gameId={gameId} disablingPhaseStarted={this.disablingPhaseStarted} />;
    }
    else {
      return <Home {...this.props} openLobbyClicked={this.openLobbyClicked} />;
    }
  }


  openLobbyClicked() {
    Push.player
      .push('open_lobby', {})
      .receive('ok', function(response) {
        window.history.pushState({}, '', '/g/' + response.game_id);
        this.setState({ gameId: response.game_id });
      }.bind(this));
  }


  disablingPhaseStarted(game) {
    this.setState({ game });
  }
}


window.initialize = function(playerId, playerToken, gameId, game) {
  Push.initialize(playerId, playerToken);
  render(<App playerId={playerId} playerToken={playerToken} gameId={gameId} game={game} />, document.getElementById('game'));
};
