import css from '../css/app.css';
import 'phoenix_html'
import 'phaser';
import React from 'react';
import { render } from 'react-dom';

import camelCase from './camelcaser';
import Home from './home';
import Lobby from './lobby';
import Game from './game';
import LightModeButton from './light_mode_button';
import BackgroundMusic from './background_music';
import Push from './push';
import _ from './prefetch';


class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = { gameId: null, game: props.game };
    this.openLobbyClicked = this.openLobbyClicked.bind(this);
    this.explorationPhaseStarted = this.explorationPhaseStarted.bind(this);
  }


  render() {
    return <React.Fragment>
      {this.getScene(this.state.gameId || this.props.gameId, this.state.game)}
      <div id="bottom-bar">
        <a href="https://sephi-chan.itch.io/disease-it">itch.io</a> · <a href="https://github.com/Sephi-Chan/disease-it">github</a>
      </div>
      <LightModeButton />
      <BackgroundMusic />
    </React.Fragment>;
  }


  getScene(gameId, game) {
    if (game && game.phase != "lobby") {
      return <Game {...this.props} game={game} />;
    }
    else if (gameId) {
      return <Lobby {...this.props} gameId={gameId} updateGame={this.explorationPhaseStarted} />;
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


  explorationPhaseStarted(game) {
    this.setState({ game });
  }
}


window.initialize = function(playerId, playerToken, gameId, game) {
  Push.initialize(playerId, playerToken);

  render(<App playerId={playerId}
    playerToken={playerToken}
    gameId={gameId}
    game={game && camelCase(game)} />,
    document.getElementById('game'));
};
