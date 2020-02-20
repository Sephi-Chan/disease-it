import Config

config :diggers, Diggers.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "diggers",
  password: "diggers",
  database: "diggers_eventstore_test",
  hostname: "localhost",
  pool_size: 10

config :logger, level: :warn
