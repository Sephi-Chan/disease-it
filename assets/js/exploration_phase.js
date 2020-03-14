import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import Push from './push';


export default class ExplorationPhase extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showInstructions: true };
    this.dismissInstructions = this.dismissInstructions.bind(this);
    this.onTileClick = this.onTileClick.bind(this);
  }


  render() {
    const player = this.props.game[this.props.playerId];
    const isGone = this.props.game.gonePlayers.indexOf(this.props.playerId) != -1;
    console.log(this.props.game);
    console.log(player);


    return <React.Fragment>
      {this.state.showInstructions && this.instructionsContainer(player, isGone)}
      {this.rolledDices()}
      {this.lifes()}
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} onBadgeClick={this.onTileClick} />
      {isGone || this.diceRoller()}
    </React.Fragment>;
  }


  onTileClick({ x, y }) {
    Push.game.push('player_moves', { tile: x + '_' + y });
  }


  dismissInstructions() {
    this.setState({ showInstructions: false });
  }


  instructionsContainer(player, isGone) {
    if (player.path.length == 1 && player.currentRound == null) {
      return <div className='instructions-container tall'>
        <img src='/images/icons/icon_close.png' className='close' onClick={this.dismissInstructions} />

        <p>Vous êtes représenté sur le plateau n°{player.boardIndex + 1} par <span>une icône de crâne</span>.</p>
        <p>Vous devez <span>contaminer le plus d'humains possible</span> en passant par <span>les villages, campements, moulins</span>, etc. avant de <span>quitter l'île</span> par bâteau.</p>
        <p>En début de tour, un joueur <span>jette les dés</span> : chaque joueur peut <span>se déplacer sur une case adjacente</span> qui porte l'un des nombres indiqués par les dés. Si aucune case n'est disponible : vous perdez un point de létalité !</p>
        <p>Ne perdez pas de temps : vous ne pouvez pas voir les autres joueurs et <span>les premiers arrivés</span> seront récompensés !</p>
        <p>À chaque fois qu'un joueur atteint le port, <span>un dé de moins</span> est lancé en début de tour, resserrant un peu plus l'étau sur les joueurs restants !</p>
      </div>;
    }
    else if (isGone) {
      return <div className='instructions-container tiny'>
        <p>Vous avez atteint <span>le port</span> ! Félicitations !</p>
      </div>
    }
    else if (player.currentRound != null) {
      return <div className='instructions-container tiny'>
        <p><span>En attente</span> de vos adversaires…</p>
      </div>
    }
  }


  diceRoller() {
    if (this.props.game.dicesRolls) return;
    return <img src='/images/ui/dices.png' id='throw-dices-button' className='throw-dices-button animated' onClick={this.rollDicesClicked} />;
  }


  rollDicesClicked() {
    Push.game.push('player_rolls_dices', {});
  }


  lifes() {
    return <div className='lifes'>
      {[1, 2, 3, 4, 5].map(function(index) {
        const classes = ['life', this.props.game[this.props.playerId].lifes < index ? 'lost' : null].join(' ');
        return <img key={'life-' + index} src='/images/icons/icon_life.png' className={classes} width='64' />;
      }.bind(this))}
    </div>
  }


  rolledDices() {
    if (!this.props.game.dicesRolls) return;

    return <div className='rolled-dices'>
      {[0, 1, 2, 3].map(function(index) {
        if (this.props.game.dicesRolls[index]) {
          return <img key={'dice-' + index} src={'/images/icons/icon_' + this.props.game.dicesRolls[index] + '.png'} className='dice' width='64' />;
        }
        else {
          return <img key={'dice-' + index} src='/images/icons/icon_bang.png' className='dice disabled' width='64' />;
        }
      }.bind(this))}
    </div>
  }
}
