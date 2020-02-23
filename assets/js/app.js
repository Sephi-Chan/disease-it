import 'phoenix_html'
import 'phaser';
import MainMenu from './game/scenes/main_menu';
import Lobby from './game/scenes/lobby';
import Push from './socket';


window.initialize = function(playerId, playerToken, gameId) {
  gameId = gameId == '' ? null : gameId;

  Push.initialize(playerId, playerToken);

  window.state = {
    playerId: playerId,
    gameId: gameId
  };

  window.game = new Phaser.Game({
    width: 800,
    height: 600
  });

  game.scene.add("main_menu", MainMenu, false, {});
  game.scene.add("lobby", Lobby, false, {});

  if (gameId) {
    game.scene.start("lobby", state);
  }
  else {
    game.scene.start("main_menu", state);
  }
};
