# defmodule Diggers.GameSocketPusher do
#   use Commanded.Event.Handler,
#     application: Diggers.CommandedApplication,
#     name: "GameSocketPusher",
#     consistency: :strong,
#     start_from: :current


#   def handle(event = %Diggers.PlayerJoinedLobby{}, _metadata) do
#     DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_joined", %{})
#     :ok
#   end


#   def handle(event = %Diggers.PlayerLeftLobby{}, _metadata) do
#     DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "player_left", %{})
#     :ok
#   end


#   def handle(event = %Diggers.DisablingPhaseStarted{}, _metadata) do
#     DiggersWeb.Endpoint.broadcast!("game:#{event.game_id}", "disabling_phase_started", %{})
#     :ok
#   end
# end
