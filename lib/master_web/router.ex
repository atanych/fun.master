defmodule MasterWeb.Router do
  use MasterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MasterWeb do
    pipe_through :api
  end
end
