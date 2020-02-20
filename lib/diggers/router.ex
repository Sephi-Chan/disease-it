defmodule Diggers.Router do
  use Commanded.Commands.Router


  dispatch([
    Diggers.PlayerOpensLobby,
    Diggers.PlayerJoinsLobby,
    Diggers.PlayerLeavesLobby,
    Diggers.PlayerStartsGame,
    Diggers.PlayerDisablesTile,
    Diggers.PlayerRollsDices,
    Diggers.PlayerMoves
  ], to: Diggers.Game, identity: :game_id)
end
