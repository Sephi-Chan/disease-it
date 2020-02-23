import {playerChannel} from '../../socket';

export default class PickDisease extends Phaser.Scene {
  constructor () {
    super('pick_disease');
  }


  preload() {
    this.load.audio('mouse_over', '/audio/mouse_over.mp3');
  }

  create() {
    const scene = this;
    this.add.text(0, 80, 'Disease it!', { fontFamily: 'Georgia', fontSize: '72px', align: 'center', fixedWidth: 800});

    this.add.text(0, 240, 'What disease would you like to be?', { fontFamily: 'Georgia', fontSize: '26px', align: 'center', fixedWidth: 800});

    [ 'Influenza', 'Plague', 'Leprosy', 'Smallpox' ].reduce(function(height, disease) {
      scene.add
        .text(800/2-200/2, height, disease, { fontFamily: 'Georgia', fontSize: '26px', align: 'center', fixedWidth: 200})
        .setInteractive()
        .on('pointerup', function() { scene.diseaseButtonClicked(disease); })
        .on('pointerover', function () { scene.sound.play('mouse_over'); this.setColor('#ff0'); })
        .on('pointerout', function () { this.setColor('#fff'); });
      return height + 40;
    }, 300);
  }


  diseaseButtonClicked(disease) {
    playerChannel
      .push("open_lobby", {disease})
      .receive("ok", function(response) { window.history.pushState({}, "", "/".concat(response.game_id)) });

    this.scene.start('lobby');
  }
}
