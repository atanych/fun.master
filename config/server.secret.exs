# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

# Configure your database
config :master, Master.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: "master-db",
  pool_size: "POSTGRES_POOL_SIZE" |> System.get_env("15") |> String.to_integer(),
  ownership_timeout: 300_000,
  timeout: 300_000
