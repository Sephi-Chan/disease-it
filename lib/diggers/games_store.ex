defmodule Diggers.GamesStore do
  use GenServer


  def start_link(_args) do
    GenServer.start_link(Diggers.GamesStore, [], name: Diggers.GamesStore)
  end


  def game_ids() do
    GenServer.call(Diggers.GamesStore, :game_ids)
  end


  def game(game_id) do
    GenServer.call(Diggers.GamesStore, {:game, game_id})
  end


  def lobby_opened(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:lobby_opened, game_id, player_id})
  end


  def lobby_closed(game_id) do
    GenServer.call(Diggers.GamesStore, {:lobby_closed, game_id})
  end


  def player_joined_lobby(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_joined_lobby, game_id, player_id})
  end


  def player_left_lobby(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_left_lobby, game_id, player_id})
  end


  def disabling_phase_started(game_id, players_boards, board) do
    GenServer.call(Diggers.GamesStore, {:disabling_phase_started, game_id, players_boards, board})
  end


  def player_disabled_tile(game_id, player_id, tile) do
    GenServer.call(Diggers.GamesStore, {:player_disabled_tile, game_id, player_id, tile})
  end


  def next_disabling_round_started(game_id, players_boards) do
    GenServer.call(Diggers.GamesStore, {:next_disabling_round_started, game_id, players_boards})
  end


  def exploration_phase_started(game_id, board) do
    GenServer.call(Diggers.GamesStore, {:exploration_phase_started, game_id, board})
  end


  def dices_rolled(game_id, dices_rolls) do
    GenServer.call(Diggers.GamesStore, {:dices_rolled, game_id, dices_rolls})
  end


  def player_suffocated(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_suffocated, game_id, player_id})
  end


  def player_died(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_died, game_id, player_id})
  end


  def player_moved(game_id, player_id, tile) do
    GenServer.call(Diggers.GamesStore, {:player_moved, game_id, player_id, tile})
  end


  def player_left(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_left, game_id, player_id})
  end


  def next_exploration_round_started(game_id) do
    GenServer.call(Diggers.GamesStore, {:next_exploration_round_started, game_id})
  end


  def game_ended(game_id, winners) do
    GenServer.call(Diggers.GamesStore, {:game_ended, game_id, winners})
  end


  def init(_args) do
    {:ok, %{}}
  end


  def handle_call(:game_ids, _from, state) do
    {:reply, Map.keys(state), state}
  end


  def handle_call({:game, game_id}, _from, state) do
    game_state = Map.get(state, game_id)
    {:reply, game_state, state}
  end


  def handle_call({:lobby_opened, game_id, player_id}, _from, state) do
    game_state = %{game_id: game_id, phase: "lobby", players: [player_id]}
    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:lobby_closed, game_id}, _from, state) do
    {:reply, :ok, Map.delete(state, game_id)}
  end


  def handle_call({:player_joined_lobby, game_id, player_id}, _from, state) do
    game_state = update_in(state[game_id], [:players], fn (players) -> players ++ [player_id] end)
    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_left_lobby, game_id, player_id}, _from, state) do
    game_state = update_in(state[game_id], [:players], fn (players) -> List.delete(players, player_id) end)
    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:exploration_phase_started, game_id, board}, _from, state) do
    game_state = state[game_id].players
      |> Enum.reduce(state[game_id], fn (player_id, acc) ->
        Map.put(acc, player_id, %{
          lifes: 5,
          current_round: nil,
          path: [Diggers.Tile.dump(Diggers.Board.start_tile(board))]
        })
      end)
      |> put_in([:board], board)
      |> put_in([:phase], "exploration")
      |> put_in([:gone_players], [])
      |> put_in([:dead_players], [])

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:dices_rolled, game_id, dices_rolls}, _from, state) do
    game_state = state[game_id]
      |> put_in([:dices_rolls], dices_rolls)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_suffocated, game_id, player_id}, _from, state) do
    game_state = state[game_id]
      |> update_in([player_id, :lifes], fn (lifes) -> lifes - 1 end)
      |> put_in([player_id, :current_round], "suffocated")

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_died, game_id, player_id}, _from, state) do
    game_state = state[game_id]
      |> put_in([player_id, :lifes], 0)
      |> update_in([:dead_players], fn (dead_players) -> [player_id|dead_players] end)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_moved, game_id, player_id, tile}, _from, state) do
    game_state = state[game_id]
      |> put_in([player_id, :current_round], tile)
      |> update_in([player_id, :path], fn (path) -> [tile|path] end)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_left, game_id, player_id}, _from, state) do
    game_state = state[game_id]
      |> update_in([:gone_players], fn (gone_players) -> [player_id|gone_players] end)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:next_exploration_round_started, game_id}, _from, state) do
    game_state = Enum.reduce(state[game_id].players, state[game_id], fn (player_id, game_state) ->
      put_in(game_state, [player_id, :current_round], nil)
    end)
      |> put_in([:dices_rolls], nil)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:game_ended, game_id, winners}, _from, state) do
    game_state = state[game_id]
      |> put_in([:winners], winners)
      |> put_in([:phase], "results")

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end
end
