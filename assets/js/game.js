import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import Push from './push';


export default class Game extends React.Component {
  constructor(props) {
    console.log(props);

    super(props);
  }


  componentDidMount() {
    Push.game = Push.socket.channel('game:' + this.props.gameId, {});
    Push.game.join();
  }


  render() {
    return <div className='container game'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>
      {this.getPhaseScene(this.props.game)}
    </div>;
  }


  getPhaseScene(game) {
    if (game.phase == "disabling") {
      return <DisablingPhase {...this.props} game={game} />
    }
    else if (game.phase == "exploration") {
      return <ExplorationPhase {...this.props} game={game} />
    }
  }
}


class DisablingPhase extends React.Component {
  constructor(props) {
    super(props);
    this.onTileDisabling = this.onTileDisabling.bind(this);
  }


  render() {
    return <React.Fragment>
      <p id="disabling-instructions">
        Chaque joueur dispose d'un plateau de jeu.
        Pour <span>corser la partie</span>, chaque joueur va désactiver trois cases sur chaque plateau.
        Les plateaux seront ensuite distribués <span>aléatoirement</span> !
        <br /><br />
        <span>Cliquez</span> sur 3 cases à désactiver.
      </p>
      <Board width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 100} originY={900/2 - 30} game={this.props.game} onTileDisabling={this.onTileDisabling} />
    </React.Fragment>;
  }


  onTileDisabling(tile) {
    Push.game.push('player_disables_tile', { tile: tile.x + '_' + tile.y });
  }
}


function ExplorationPhase(props) {
  console.log("ExplorationPhase", props);
  return <div>Exploration phase…</div>;
}
