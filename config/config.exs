import Config

config :diggers, event_stores: [Diggers.EventStore]

import_config "#{Mix.env()}.exs"
