import React from 'react';
import DisablingPhase from './disabling_phase';
import ExplorationPhase from './exploration_phase';
import GameOver from './game_over';
import Results from './results';
import Push from './push';
import camelCase from './camelcaser';
import { items } from './map';


export default class Game extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      game: props.game,
      itemPerTile: objectFromArray(items.map(({x, y}) => x + '_' + y))
    };
    this.updateGame = this.updateGame.bind(this);
    this.nextDisablingRoundStarted = this.nextDisablingRoundStarted.bind(this);
    this.explorationPhaseStarted = this.explorationPhaseStarted.bind(this);
    this.diceRolled = this.diceRolled.bind(this);
    this.nextExplorationRoundStarted = this.nextExplorationRoundStarted.bind(this);
    this.playerMoved = this.playerMoved.bind(this);
    this.playerLeft = this.playerLeft.bind(this);
    this.playerSuffocated = this.playerSuffocated.bind(this);
    this.playerDied = this.playerDied.bind(this);
    this.gameEnded = this.gameEnded.bind(this);
  }


  componentDidMount() {
    Push.game = Push.socket.channel('game:' + this.props.game.gameId, {});
    Push.game.on('player_disabled_tile', this.updateGame);
    Push.game.on('next_disabling_round_started', this.nextDisablingRoundStarted);
    Push.game.on('exploration_phase_started', this.explorationPhaseStarted);
    Push.game.on('dices_rolled', this.diceRolled);
    Push.game.on('player_moved', this.playerMoved);
    Push.game.on('next_exploration_round_started', this.nextExplorationRoundStarted);
    Push.game.on('player_left', this.playerLeft);
    Push.game.on('player_suffocated', this.playerSuffocated);
    Push.game.on('player_died', this.playerDied);
    Push.game.on('game_ended', this.gameEnded);
    Push.game.join();
  }


  render() {
    return <div className='container game'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>
      {this.getPhaseScene(this.state.game)}
    </div>;
  }


  getPhaseScene(game) {
    if (game.phase == 'disabling') {
      return <DisablingPhase {...this.props} game={game} />
    }
    else if (game.phase == 'exploration') {
      return <ExplorationPhase {...this.props} game={game} updateGame={this.updateGame} />
    }
    else if (game.phase == 'results') {
      if (game.winners.length == 0) {
        return <GameOver {...this.props} game={game} />
      }
      else {
        return <Results {...this.props} game={game} />
      }
    }
  }


  updateGame(game) {
    this.setState({ game: camelCase(game) });
  }


  diceRolled(game) {
    window.sounds.dicesRoll.play();
    this.updateGame(game);
  }


  playerMoved({tile, playerId, game}) {
    const tileHasItem = !!this.state.itemPerTile[tile];
    const tileWasVisited = this.state.game[playerId].path.includes(tile);
    if (tileHasItem && !tileWasVisited) window.sounds.crowdPanic.play();
    this.updateGame(game);
  }


  playerSuffocated(game) {
    this.updateGame(game);
  }


  playerLeft(game) {
    window.sounds.shipBell.play();
    this.updateGame(game);
  }


  playerDied(game) {
    this.updateGame(game);
  }


  gameEnded(game) {
    this.updateGame(game);
  }


  nextDisablingRoundStarted(game) {
    window.sounds.horn.play();
    this.updateGame(game);
  }


  explorationPhaseStarted(game) {
    window.sounds.horn.play();
    this.updateGame(game);
  }


  nextExplorationRoundStarted(game) {
    window.sounds.horn.play();
    this.updateGame(game);
  }
}


function objectFromArray(array) {
  return array.reduce(function(acc, item) {
    acc[item] = true;
    return acc;
  }, {});
}
