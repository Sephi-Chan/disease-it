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


  def player_joined(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_joined, game_id, player_id})
  end


  def player_left(game_id, player_id) do
    GenServer.call(Diggers.GamesStore, {:player_left, game_id, player_id})
  end


  def disabling_phase_started(game_id, players_boards) do
    GenServer.call(Diggers.GamesStore, {:disabling_phase_started, game_id, players_boards})
  end


  def player_disabled_tile(game_id, player_id, tile) do
    GenServer.call(Diggers.GamesStore, {:player_disabled_tile, game_id, player_id, tile})
  end


  def next_disabling_round_started(game_id, players_boards) do
    GenServer.call(Diggers.GamesStore, {:next_disabling_round_started, game_id, players_boards})
  end


  def exploration_phase_started(game_id) do
    GenServer.call(Diggers.GamesStore, {:exploration_phase_started, game_id})
  end


  def dices_rolled(game_id, dices_rolls) do
    GenServer.call(Diggers.GamesStore, {:dices_rolled, game_id, dices_rolls})
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


  def handle_call({:player_joined, game_id, player_id}, _from, state) do
    game_state = update_in(state[game_id], [:players], fn (players) -> players ++ [player_id] end)
    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_left, game_id, player_id}, _from, state) do
    game_state = update_in(state[game_id], [:players], fn (players) -> List.delete(players, player_id) end)
    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:disabling_phase_started, game_id, players_boards}, _from, state) do
    game_state = players_boards
      |> Enum.reduce(state[game_id], fn ({player_id, board_index}, acc) ->
        Map.put(acc, player_id, %{
          board_index: board_index,
          tiles_to_disable: 3,
          lifes: 5,
          path: ["0_0"]
        })
      end)
      |> put_in([:phase], "disabling")
      |> put_in([:disabled_tiles], Map.new(players_boards, fn ({_player_id, index}) -> {index, []} end))

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:player_disabled_tile, game_id, player_id, tile}, _from, state) do
    board_index = state[game_id][player_id].board_index

    game_state = state[game_id]
      |> update_in([:disabled_tiles, board_index], fn (tiles) -> tiles ++ [tile] end)
      |> update_in([player_id, :tiles_to_disable], fn (count) -> count - 1 end)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:next_disabling_round_started, game_id, players_boards}, _from, state) do
    game_state =
      Enum.reduce(players_boards, state[game_id], fn ({player_id, board_index}, acc) ->
        acc
          |> put_in([player_id, :tiles_to_disable], 3)
          |> put_in([player_id, :board_index], board_index)
      end)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:exploration_phase_started, game_id}, _from, state) do
    game_state = state[game_id]
      |> put_in([:phase], "exploration")

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end


  def handle_call({:dices_rolled, game_id, dices_rolls}, _from, state) do
    game_state = state[game_id]
      |> put_in([:dices_rolls], dices_rolls)

    {:reply, game_state, Map.put(state, game_id, game_state)}
  end
end
