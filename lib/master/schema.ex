defmodule Master.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      require IEx

      import EctoEnum, only: [defenum: 2]
      import Ecto.{Changeset, Query}

      @type t :: %__MODULE__{}
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
