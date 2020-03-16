import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import Push from './push';
import { diseases } from './diseases';


export default class DisablingPhase extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showInstructions: true };
    this.onTileDisabling = this.onTileDisabling.bind(this);
    this.dismissInstructions = this.dismissInstructions.bind(this);
  }


  render() {
    return <React.Fragment>
      {this.instructions()}
      {this.helpMessages()}
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} onBadgeClick={this.onTileDisabling} />
    </React.Fragment>;
  }


  onTileDisabling({ x, y }) {
    Push.game.push('player_disables_tile', { tile: x + '_' + y });
  }


  dismissInstructions() {
    this.setState({ showInstructions: false });
  }


  instructions() {
    if (this.state.showInstructions) return this.fullInstructions();
    else return this.shortInstructions();
  }


  shortInstructions() {
    return <div className='instructions-container tiny'>
      {this.remainingDisablingsShortParagraph(this.props.playerId, this.props.game[this.props.playerId], this.props.game)}
    </div>;
  }


  helpMessages() {
    return <React.Fragment>
      <p className='help-message origin'><span>Vous êtes ici…</span></p>
      <p className='help-message destination'><span>Votre objectif est ici…</span></p>
    </React.Fragment>;
  }


  fullInstructions() {
    const classes = ['instructions-container', 'disabling', this.props.game.players.length > 2 ? 'tallest' : 'tall' ].join(' ');
    return <div className={classes}>
      <img src='/images/icons/icon_close.png' className='close' onClick={this.dismissInstructions} />

      <p>Chaque joueur dispose de <span>son propre plateau</span> de jeu.</p>
      <p>Lors de cette première phrase, les plateaux de jeux vont <span>tourner</span> d'un joueur à l'autre, et chacun va <span>bloquer des cases</span> sur le plateau qu'il a en main.</p>
      <p>L'opération recommence jusqu'à ce que chaque plateau soit passé par chaque joueur. Les plateaux sont alors distribués <span>aléatoirement</span> et la partie peut commmencer !</p>
      <p>La case de <span>départ</span> et les cases contenant un <span>bâtiment</span> ne peuvent pas être bloquées. Deux <span>cases adjacentes</span> ne peuvent pas être bloquées.</p>

      {this.remainingDisablingsTable(this.props.playerId, this.props.game)}
    </div>;
  }


  remainingDisablingsTable(currentPlayerId, game) {
    return <table>
      <tbody>
        {game.players.map(function(playerId, index) {
          const player = game[playerId];
          return <tr key={playerId} className={playerId == currentPlayerId ? 'self' : null}>
            <td>{diseases[index]}</td>
            <td>
              {player.tilesToDisable == 0 && <React.Fragment><span>En attente</span> de vos adversaires…</React.Fragment>}
              {player.tilesToDisable == 1 && <React.Fragment>1 case à bloquer sur le plateau #{player.boardIndex + 1}</React.Fragment>}
              {player.tilesToDisable > 1 && <React.Fragment>{player.tilesToDisable} cases à bloquer sur le plateau #{player.boardIndex + 1}</React.Fragment>}
            </td>
          </tr>;
        })}
      </tbody>
    </table>;
  }


  remainingDisablingsShortParagraph(currentPlayerId, currentPlayer, game) {
    const readyPlayerIds = game.players.filter(function(playerId) { return game[playerId].tilesToDisable == 0 });
    const idsWithName = readyPlayerIds.map(function(playerId){ const indexInGame = game.players.indexOf(playerId); return [playerId, diseases[indexInGame] ]; });
    const namesElements = idsWithName.map(function([playerId, name]) { return playerId == currentPlayerId ? <span className='self' key={name}>{name}</span> : name; });

    if (readyPlayerIds.length == 0) {
      if (currentPlayer.tilesToDisable > 1) return <p>Bloquez {currentPlayer.tilesToDisable} cases.</p>;
      else if (currentPlayer.tilesToDisable == 1) return <p>Bloquez une dernière case.</p>;
    }
    else if (readyPlayerIds.length == 1) {
      if (readyPlayerIds[0] == currentPlayerId) return <p><span>Vous</span> êtes prêt.</p>;
      else return <p>{namesElements} est prêt.</p>;
    }
    else {
      return <p>{intersperse(namesElements, ', ')} sont prêts.</p>;
    }
  }
}


function intersperse(array, separator) {
  if (array.length === 0) return [];
  return array.slice(1).reduce(function(xs, x, i) {
    return xs.concat([separator, x]);
  }, [array[0]]);
}
