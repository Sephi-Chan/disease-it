defmodule Diggers.GameReadModelBuilder do
  use Commanded.Event.Handler,
    application: Diggers.CommandedApplication,
    name: "GameReadModelBuilder",
    consistency: :strong,
    start_from: :origin


  def init do
    :ok
  end


  def handle(event = %Diggers.LobbyOpened{}, _metadata) do
    lobby = Diggers.GamesStore.lobby_opened(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("general", "lobby_opened", lobby)
    :ok
  end


  def handle(event = %Diggers.LobbyClosed{}, _metadata) do
    Diggers.GamesStore.lobby_closed(event.game_id)
    DiggersWeb.Endpoint.broadcast!("general", "lobby_closed", %{ game_id: event.game_id })
    :ok
  end


  def handle(event = %Diggers.PlayerJoinedLobby{}, _metadata) do
    game = Diggers.GamesStore.player_joined_lobby(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_joined_lobby", game)
    :ok
  end


  def handle(event = %Diggers.PlayerLeftLobby{}, _metadata) do
    game = Diggers.GamesStore.player_left_lobby(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_left_lobby", game)
    :ok
  end


  def handle(event = %Diggers.ExplorationPhaseStarted{}, _metadata) do
    game = Diggers.GamesStore.exploration_phase_started(event.game_id, event.board, event.disabled_tiles)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "exploration_phase_started", game)
    DiggersWeb.Endpoint.broadcast!("general", "exploration_phase_started", %{ game_id: game.game_id })
    :ok
  end


  def handle(event = %Diggers.DicesRolled{}, _metadata) do
    game = Diggers.GamesStore.dices_rolled(event.game_id, event.dices_rolls)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "dices_rolled", game)
    :ok
  end


  def handle(event = %Diggers.PlayerSuffocated{}, _metadata) do
    game = Diggers.GamesStore.player_suffocated(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_suffocated", game)
    :ok
  end


  def handle(event = %Diggers.PlayerDied{}, _metadata) do
    game = Diggers.GamesStore.player_died(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_died", game)
    :ok
  end


  def handle(event = %Diggers.PlayerMoved{}, _metadata) do
    game = Diggers.GamesStore.player_moved(event.game_id, event.player_id, event.tile)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_moved", %{game: game, playerId: event.player_id, tile: event.tile})
    :ok
  end


  def handle(event = %Diggers.PlayerLeft{}, _metadata) do
    game = Diggers.GamesStore.player_left(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_left", game)
    :ok
  end


  def handle(event = %Diggers.NextExplorationRoundStarted{}, _metadata) do
    game = Diggers.GamesStore.next_exploration_round_started(event.game_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "next_exploration_round_started", game)
    :ok
  end


  def handle(event = %Diggers.GameEnded{}, _metadata) do
    game = Diggers.GamesStore.game_ended(event.game_id, event.winners)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "game_ended", game)
    :ok
  end
end
