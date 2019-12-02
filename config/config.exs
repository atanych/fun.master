# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :master, ecto_repos: [Master.Repo]

config :master,
  self_name: System.get_env("SELF_NAME"),
  workers: [origin_path: "/home/origin", transcode_path: "/home/transcode", scripts_path: "/home/scripts"]

config :master, Servers.ChangeReserved, default_reserve: 10
config :master, Servers.GetSpace, min_disk_space: 15

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

config :master, :ops,
  docker: [
    username: System.get_env("DOCKER_USER"),
    password: System.get_env("DOCKER_PASS"),
    image_repository: "forfunfun/fun.master",
    file: "config/Dockerfile"
  ],
  build_info: [
    file_name: "tmp/build_info.json"
  ],
  check_restart_timeout: 30,
  available_environments: ["staging", "uat", "prod", "stable"],
  auto_build_branches: ["develop", "dev", "master", "release", "hotfix"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
logger_file = "deps/ext/lib/ext/logger/config.exs"
if File.exists?(logger_file), do: import_config("../#{logger_file}")

case Mix.env() do
  :test -> import_config "test.exs"
  :dev -> import_config "dev.exs"
  _ -> import_config "server.exs"
end
