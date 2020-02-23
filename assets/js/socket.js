import { Socket } from "phoenix";

const Push = {};

Push.initialize = function(playerId, playerToken) {
  Push.socket = new Socket("/socket", {params: {token: playerToken}});
  Push.socket.connect();

  Push.player = Push.socket.channel("player:" + playerId, {});
  Push.player.join();
}

export default Push;
