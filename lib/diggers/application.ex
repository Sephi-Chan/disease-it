defmodule Diggers.Application do
  use Commanded.Application,
    otp_app: :diggers,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Diggers.EventStore
    ]

  router Diggers.Router
end
