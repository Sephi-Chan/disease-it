import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import Push from './push';


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
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 100} originY={900/2 - 30} onTileDisabling={this.onTileDisabling} />
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
      {this.remainingDisablingsSentence()}
    </div>;
  }


  helpMessages() {
    return <React.Fragment>
      <p className='help-message origin'><span>Vous êtes ici…</span></p>
      <p className='help-message destination'><span>Votre objectif est ici…</span></p>
    </React.Fragment>;
  }


  fullInstructions() {
    return <div className='instructions-container medium'>
      <img src='/images/icons/icon_close.png' className='close' onClick={this.dismissInstructions} />

      <p>Chaque joueur dispose d'un plateau de jeu.</p>
      <p>
        Pour <span>corser la partie</span>, chaque joueur va rendre <span>trois cases inaccessible</span> sur chaque plateau.
        Les plateaux seront distribués <span>aléatoirement</span> aux joueurs en début de partie !
      </p>
      <p>
        La case de <span>départ</span> et les cases contenant un <span>lieu de vie humaine</span> ne peuvent pas être désactivées.
        Deux <span>cases adjacentes</span> ne peuvent pas être désactivées.
      </p>

      {this.remainingDisablingsSentence()}
    </div>;
  }


  remainingDisablingsSentence() {
    const player = this.props.game[this.props.playerId];

    if (player.tilesToDisable == 0) {
      return <p><span>En attente</span> de vos adversaires…</p>;
    }
    else if (player.tilesToDisable == 1) {
      return <p><span>Cliquez</span> sur la dernière case à désactiver.</p>;
    }
    else {
      if (this.state.showInstructions) {
        return <p><span>Désactivez</span> {player.tilesToDisable} cases sur le plateau n°{player.boardIndex + 1} en cliquant dessus.</p>;
      }
      else {
        return <p><span>Désactivez</span> {player.tilesToDisable} cases sur le plateau n°{player.boardIndex + 1}.</p>;
      }
    }
  }
}
