import Config

config :diggers, event_stores: [Diggers.EventStore]


config :task_after, global_name: TaskAfter


config :commanded, default_consistency: :strong


# Configures the endpoint
config :diggers, DiggersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MrizF8i/7P8CgeuHvs5UtapOIAnoCe82ZEk7+v1IBEN6mtuNoIsSDNSjUj8M+n+0",
  render_errors: [view: DiggersWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Diggers.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "sB7a1Nx0"]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


import_config "#{Mix.env()}.exs"
