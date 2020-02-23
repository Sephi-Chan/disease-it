import Push from '../../socket';
import styles from '../../styles';


export default class MainMenu extends Phaser.Scene {
  constructor () {
    super('main_menu');
  }


  init(state) {
    this.state = state;
  }


  create() {
    this.add.text(0, 80, 'Disease it!', styles.title);

    this.add
      .text(0, 240, 'Play now', styles.bigButton)
      .setInteractive()
      .on('pointerover', function() { this.setColor('#ff0'); })
      .on('pointerout', function() { this.setColor('#fff'); })
      .on('pointerup', this.playButtonClicked, this);
  }


  playButtonClicked() {
    const scene = this;

    Push.player
      .push('open_lobby', {})
      .receive('ok', function(response) {
        window.history.pushState({}, '', '/' + response.game_id);
        scene.scene.start('lobby', Object.assign(scene.state, {gameId: response.game_id}));
      });
  }
}
