import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import Push from './push';


export default class ExplorationPhase extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showInstructions: true };
    this.dismissInstructions = this.dismissInstructions.bind(this);
  }


  render() {
    return <React.Fragment>
      {this.state.showInstructions && this.instructionsContainer()}
      {this.rolledDices()}
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 100} originY={900/2 - 30} />
      {this.diceRoller()}
    </React.Fragment>;
  }


  dismissInstructions() {
    this.setState({ showInstructions: false });
  }


  instructionsContainer() {
    const player = this.props.game[this.props.playerId];

    return <div className='instructions-container tall'>
      <img src='/images/icons/icon_close.png' className='close' onClick={this.dismissInstructions} />

      <p>Vous êtes représenté sur le plateau n°{player.boardIndex + 1} par <span>une icône de crâne</span>.</p>
      <p>Vous devez <span>contaminer le plus d'humains possibles </span> en passant par <span>les villages, campements, moulins</span>, etc. avant de <span>quitter l'île</span> par bâteau.</p>
      <p>En début de tour, un joueur <span>jette les dés</span> : chaque joueur peut <span>se déplacer sur une case adjacente</span> qui porte l'un des nombres indiqués par les dés. Si aucune case n'est disponible : vous perdez un point de létalité !</p>
      <p>Ne perdez pas de temps : vous ne pouvez pas voir les autres joueurs et <span>les premiers arrivés</span> seront récompensés !</p>
      <p>À chaque fois qu'un joueur atteint le port, <span>un dé de moins</span> est lancé en début de tour, resserrant un peu plus l'étau sur les joueurs restants !</p>
    </div>;
  }


  diceRoller() {
    if (this.state.showInstructions || this.props.game.dicesRolls) return;
    return <img src='/images/ui/dices.png' id="throw-dices-button" className='throw-dices-button animated' onClick={this.rollDicesClicked} />;
  }


  rollDicesClicked() {
    window.sounds.dices_roll.play();
    Push.game.push('player_rolls_dices', {});
  }


  rolledDices() {
    if (!this.props.game.dicesRolls) return;

    return <div className='rolled-dices' style={{position: 'absolute', right: 70, top: -20 }}>
      {[0, 1, 2, 3].map(function(index) {
        if (this.props.game.dicesRolls[index]) {
          return <img key={'dice-' + index} src={'/images/icons/icon_' + this.props.game.dicesRolls[index] + '.png'} className='dice' width='64' />;
        }
        else {
          return <img key={'dice-' + index} src='/images/icons/icon_bang.png' className='dice' id='dice-slot-1' width='64' />;
        }
      }.bind(this))}
    </div>
  }
}
