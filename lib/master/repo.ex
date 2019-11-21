defmodule Master.Repo do
  use Ecto.Repo,
    otp_app: :master,
    adapter: Ecto.Adapters.Postgres
end
