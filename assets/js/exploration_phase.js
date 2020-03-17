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
    this.rollDicesClicked = this.rollDicesClicked.bind(this);
  }


  render() {
    const player = this.props.game[this.props.playerId];
    const isGone = this.props.game.gonePlayers.includes(this.props.playerId);

    return <React.Fragment>
      {this.state.showInstructions && this.instructionsContainer(player, isGone)}
      {this.rolledDices()}
      {this.lifes()}
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} onBadgeClick={this.onTileClick} />
      {this.diceRoller(player)}
    </React.Fragment>;
  }


  onTileClick({ x, y }) {
    Push.game.push('player_moves', { tile: x + '_' + y });
  }


  dismissInstructions() {
    this.setState({ showInstructions: false });
  }


  someoneThrowDices() {
    if (this.isDiceThrower(this.props.game, this.props.playerId)) return <span>vous jettez les dés</span>;
    else return <span>les dés sont jetés</span>;
  }


  instructionsContainer(player, isGone) {
    if (player.path.length == 1 && player.currentRound == null) {
      return <div className='instructions-container tallest'>
        <img src='/images/icons/icon_close.png' className='close' onClick={this.dismissInstructions} />

        <p>Vous avez reçu le plateau #{player.boardIndex + 1}. Vous êtes représenté par <span>un crâne</span>.</p>
        <p>Vote objectif est de <span>rejoindre le port</span>. Marquez des points en traversant le plus de <span>villages</span>, <span>campements</span>, <span>moulins</span>… possible en chemin.</p>
        <p>En début de tour, {this.someoneThrowDices()} : chaque joueur doit <span>se déplacer</span> sur une case adjacente qui porte un nombre indiqué par les dés. Si aucune case n'est disponible : vous <span>perdez</span> un point de mort ! Vous êtes <span>éliminé</span> quand vous n'en avez plus.</p>
        <p>Ne perdez pas de temps : vous ne pouvez pas voir les autres joueurs et <span>les premiers arrivés</span> au port seront récompensés !</p>
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


  isDiceThrower(game, currentPlayerId) {
    const stillPlayingPlayers = game.players
      .filter(playerId => !game.deadPlayers.includes(playerId))
      .filter(playerId => !game.gonePlayers.includes(playerId));

    return stillPlayingPlayers[0] == currentPlayerId;
  }


  diceRoller(player) {
    if (this.props.game.dicesRolls) return;
    if (!this.isDiceThrower(this.props.game, this.props.playerId)) return;
    const withInstructions = this.state.showInstructions && player.path.length == 1 && player.currentRound == null;
    return <img src='/images/ui/dices.png' id='throw-dices-button' className={withInstructions ? 'with-instructions' : null} onClick={this.rollDicesClicked} />;
  }


  rollDicesClicked() {
    this.setState({ showInstructions: false });
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
