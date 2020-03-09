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
    Diggers.GamesStore.lobby_opened(event.game_id, event.player_id)
    :ok
  end


  def handle(event = %Diggers.LobbyClosed{}, _metadata) do
    Diggers.GamesStore.lobby_closed(event.game_id)
    :ok
  end


  def handle(event = %Diggers.PlayerJoinedLobby{}, _metadata) do
    game = Diggers.GamesStore.player_joined(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_joined_lobby", game)
    :ok
  end


  def handle(event = %Diggers.PlayerLeftLobby{}, _metadata) do
    game = Diggers.GamesStore.player_left(event.game_id, event.player_id)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_left_lobby", game)
    :ok
  end


  def handle(event = %Diggers.DisablingPhaseStarted{}, _metadata) do
    game = Diggers.GamesStore.disabling_phase_started(event.game_id, event.players_boards)
    DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "disabling_phase_started", game)
    :ok
  end


  def handle(event = %Diggers.PlayerDisabledTile{}, _metadata) do
    Diggers.GamesStore.player_disabled_tile(event.game_id, event.player_id, event.tile)
    :ok
  end


  def handle(event = %Diggers.NextDisablingRoundStarted{}, _metadata) do
    Diggers.GamesStore.next_disabling_round_started(event.game_id, event.players_boards)
    :ok
  end


  def handle(event = %Diggers.ExplorationPhaseStarted{}, _metadata) do
    Diggers.GamesStore.exploration_phase_started(event.game_id)
    :ok
  end


  def handle(event = %Diggers.DicesRolled{}, _metadata) do
    Diggers.GamesStore.dices_rolled(event.game_id, event.dices_rolls)
    :ok
  end
end
