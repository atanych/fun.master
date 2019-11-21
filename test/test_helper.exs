ExUnit.start(capture_log: true)
Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.Sandbox.mode(Master.Repo, :manual)
