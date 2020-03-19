defmodule Master.Deploy do
  @moduledoc false
  use Master.Schema
  import EctoEnum, only: [defenum: 2]
  defenum StatusEnum, not_started: 0, in_progress: 1

  schema "deploy" do
    field :status, StatusEnum, default: :not_started
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:status])
  end
end
