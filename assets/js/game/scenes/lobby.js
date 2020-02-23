import Push from '../../socket';
import styles from '../../styles';


export default class Lobby extends Phaser.Scene {
  constructor () {
    super('lobby');
  }


  init(data) {
    const scene = this;
    this.data = data;
    this.game = null;
    this.playerFrames = {};

    Push.game = Push.socket.channel('game:' + this.data.gameId, {});
    Push.game.join().receive('ok', function() { fetchGame(scene.updateGame.bind(scene)); });
    Push.game.on('player_joined', function() { fetchGame(scene.updateGame.bind(scene)); });
    Push.game.on('player_left', function() { fetchGame(scene.updateGame.bind(scene)); });

    this.add.text(0, 80, 'Disease it!', styles.title);
    this.add.text(0, 240, 'Just give the link of the page to your friends!', styles.paragraph);

    [0, 1, 2, 3].reduce(function(height, index) {
      scene.playerFrames[index] = scene.add.text(800/2-200/2, height, '', styles.list);
      return height + 40;
    }, 300);

    this.startButton = this.add.text(800/2-200/2, 500, 'Start game!', styles.bigButton)
      .setInteractive()
      .on('pointerover', function() { this.setColor('#ff0'); })
      .on('pointerout', function() { this.setColor('#fff'); })
      .on('pointerup', scene.startButtonClicked, scene)
      .setVisible(false);
  }


  updateGame(game) {
    const scene = this;
    scene.game = game;

    [0, 1, 2, 3].map(function(index) {
      const label = game.players[index] ? game.players[index] : 'Slot ' + (index + 1);
      scene.playerFrames[index].setText(label);

      const color = game.players[index] == scene.data.playerId ? '#ff0' : '#fff';
      scene.playerFrames[index].setColor(color);
    });

    const visible = scene.data.playerId == scene.game.players[0] && scene.game.players.length >= 2;
    scene.startButton.setVisible(visible);
  }


  startButtonClicked() {
    Push.game
      .push('start_disabling', {})
      .receive('ok', function(response) {
        // scene.scene.start('lobby', Object.assign(scene.state, {gameId: response.game_id}));
      });
  }
}



function fetchGame(callback) {
  Push.game.push('fetch', {}).receive('ok', callback);
}
