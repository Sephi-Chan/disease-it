import Config

config :diggers, Diggers.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "diggers",
  password: "diggers",
  database: "diggers_eventstore_dev",
  hostname: "localhost",
  pool_size: 10

config :mix_test_watch,
  clear: true
