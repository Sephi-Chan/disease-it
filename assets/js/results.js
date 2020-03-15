import React from 'react';
import { tiles, items } from './map';
import Board from './board';
import { diseases } from './diseases';


export default class Results extends React.Component {
  constructor(props) {
    super(props);
  }


  render() {
    return <React.Fragment>
      <div className='instructions-container medium'>
        {this.paragraphs(this.props.playerId)}
        {this.scores(this.props.playerId)}
      </div>
      <Board {...this.props} width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} />
    </React.Fragment>;
  }


  scores(currentPlayerId) {
    return <table>
      <tbody>
        {this.props.game.winners.map(function({playerId, score}) {
          const indexInGame = this.props.game.players.indexOf(playerId)
          return <tr key={playerId} className={playerId == currentPlayerId ? 'self' : null}>
            <td>{diseases[indexInGame]}</td>
            <td>{score} points</td>
          </tr>;
        }.bind(this))}
      </tbody>
    </table>;
  }


  paragraphs(playerId) {
    const winnerIds = this.props.game.winners.map((winner) => winner.playerId);

    if (winnerIds.indexOf(playerId) == -1) {
      return this.youWereBeaten();
    }
    else {
      if (winnerIds.length == 1) { return this.youAreTheOnlyWinner(); }
      else {
        if (winnerIds[0] == playerId) { return this.youAreTheBestAmongOthers(); }
        else { return this.youExitedTheIsland(); }
      }
    }
  }


  youWereBeaten() {
    return <React.Fragment>
      <p>Vous n'avez <span>pas réussi</span> à quitter l'île… Vous êtes une maladie <span>médiocre</span>.</p>
      <p>Vous étiez <span>destiné</span> à de grandes choses. Quelle <span>déception</span>…</p>
      <p>Aujourd'hui, <span>personne</span> ne vous craint : vous êtes aussi <span>inoffensif</span> qu'un bébé chauve-souris.</p>
    </React.Fragment>;
  }


  youAreTheOnlyWinner() {
    return <React.Fragment>
      <p>Félicitations ! Vous êtes <span>l'unique maladie</span> a avoir quitté l'île !</p>
      <p>Il ne fait aucun doute que vous entrerez dans l'<span>Histoire</span> ! Peut-être même <span>emporterez-vous</span> des civilisations entières !</p>
      <p>Sans mentir, si votre <span>létalité</span> se rapporte à votre <span>contagiosité</span>, vous êtes le phénix des hôtes de cette île.</p>
    </React.Fragment>;
  }


  youExitedTheIsland() {
    return <React.Fragment>
      <p>Ce n'est <span>pas si mal</span>, vous avez au moins quitté l'île…</p>
      <p>N'allez pas vous <span>emballer</span> pour autant : les <span>autres maladies</span> s'en sont bien mieux tirées !</p>
      <p>Je doute vous voir apparaître dans les <span>livres d'Histoire</span>, mais sait-on jamais…</p>
    </React.Fragment>;
  }


  youAreTheBestAmongOthers() {
    return <React.Fragment>
      <p>Bravo ! Vous êtes la <span>meilleure maladie</span> de votre génération !</p>
      <p>Ne vous reposez-pas sur vos lauriers pour autant ! Les <span>autres maladies</span> vous talonnent !</p>
      <p>Mais vous êtes encore là ? Allez, allez ! Remettez-vous <span>au travail</span> ! Il reste des tas de populations à <span>décimer</span> !!</p>
    </React.Fragment>;
  }
}
