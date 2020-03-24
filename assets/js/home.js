import React from 'react';
import Board from './board';
import { tiles, items } from './map';
import camelCase from './camelcaser';
import Push from './push';


export default class Home extends React.Component {
  constructor(props) {
    super(props);
    this.state = { games: [] };
    this.lobbyOpened = this.lobbyOpened.bind(this);
    this.lobbyClosed = this.lobbyClosed.bind(this);
    this.explorationPhaseStarted = this.explorationPhaseStarted.bind(this);
    this.generalChannelJoined = this.generalChannelJoined.bind(this);
  }


  componentDidMount() {
    this.channel = Push.socket.channel('general');
    this.channel.on('lobby_opened', this.lobbyOpened)
    this.channel.on('lobby_closed', this.lobbyClosed)
    this.channel.on('exploration_phase_started', this.explorationPhaseStarted)
    this.channel.join().receive('ok', this.generalChannelJoined);
  }


  componentWillUnmount() {
    this.channel.leave();
  }


  render() {
    return <div className='container home'>
      <h1><a href='/'><img src='/images/ui/disease-it.png' alt='Disease it' /></a></h1>

      <div className='instructions-container tallest'>
        <p><span>Disease it</span> est un jeu <span>multijoueur</span> jouable dans le navigateur.
        Chaque joueur y incarne une maladie et cherche à <span>contaminer le plus d'humains possible</span> avant de rallier le port pour s'étendre.</p>

        <div className="button enabled" onClick={this.props.openLobbyClicked}>Créer une partie</div>

        {this.publicGames()}
      </div>

      <Board width={1440} height={900} tiles={tiles} items={items} originX={1440/2 + 50} originY={900/2 - 30} />
    </div>;
  }


  publicGames() {
    if (this.state.games.length == 0) return;

    return <React.Fragment>
      <p>Vous pouvez également <span>rejoindre</span> une partie existante…</p>
      <ul className="public-games">
        {this.state.games.map(function(game){
          return <PublicLobbyItem key={game.gameId} game={game} publicLobbyClicked={this.props.publicLobbyClicked} />;
        }.bind(this))}
      </ul>
      </React.Fragment>;
  }


  generalChannelJoined(games) {
    this.setState(camelCase(games));
  }


  lobbyOpened(lobby) {
    const games = this.state.games.concat(camelCase(lobby));
    this.setState({ games });
  }


  lobbyClosed(lobby) {
    const games = this.state.games.filter(function(game) { return game.gameId != lobby.game_id });
    this.setState({ games });
  }


  explorationPhaseStarted(lobby) {
    const games = this.state.games.filter(function(game) { return game.gameId != lobby.game_id });
    this.setState({ games });
  }
}


class PublicLobbyItem extends React.Component {
  constructor(props) {
    super(props);
    this.clicked = this.clicked.bind(this);
  }


  render() {
    return <li className="public-game" onClick={this.clicked}>{this.props.game.gameId}</li>;
  }


  clicked() {
    this.props.publicLobbyClicked(this.props.game.gameId)
  }
}
