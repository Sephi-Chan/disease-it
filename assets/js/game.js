import React from 'react';
import DisablingPhase from './disabling_phase';
import ExplorationPhase from './exploration_phase';
import Push from './push';
import camelCase from './camelcaser';


export default class Game extends React.Component {
  constructor(props) {
    super(props);
    this.state = { game: props.game };
    this.updateGame = this.updateGame.bind(this);
    this.updateGameWithWarning = this.updateGameWithWarning.bind(this);
  }


  componentDidMount() {
    Push.game = Push.socket.channel('game:' + this.props.game.gameId, {});
    Push.game.on('player_disabled_tile', this.updateGame);
    Push.game.on('next_disabling_round_started', this.updateGameWithWarning);
    Push.game.on('exploration_phase_started', this.updateGameWithWarning);
    Push.game.on('dices_rolled', this.updateGameWithWarning);
    Push.game.join();
  }


  render() {
    return <div className='container game'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>
      {this.getPhaseScene(this.state.game)}
    </div>;
  }


  getPhaseScene(game) {
    const playerBoardIndex = this.state.game[this.props.playerId].boardIndex;
    const disabledTilesByPlayer = this.state.game.disabledTiles[playerBoardIndex];

    if (game.phase == 'disabling') {
      return <DisablingPhase {...this.props} game={game} disabledTilesByPlayer={disabledTilesByPlayer} />
    }
    else if (game.phase == 'exploration') {
      return <ExplorationPhase {...this.props} game={game} disabledTilesByPlayer={disabledTilesByPlayer} updateGame={this.updateGame} />
    }
  }


  updateGame(game) {
    this.setState({ game: camelCase(game) });
  }


  updateGameWithWarning(game) {
    window.sounds.horn.play();
    this.updateGame(game)
  }
}
