# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :master,
  ecto_repos: [Master.Repo]

# Configures the endpoint
config :master, MasterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8cEzG8qlq4CXfo15dXNzc+vLEx0bhHmr1T1dzJTbW3fcntxLboNpW0iDQ3NmlvKB",
  render_errors: [view: MasterWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Master.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
