use Mix.Config

# Configure your database
config :master, Master.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: "postgres",
  database: "fun_master_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :master, MasterWeb.Endpoint,
  http: [port: 4_002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
