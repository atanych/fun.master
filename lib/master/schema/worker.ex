defmodule Master.Worker do
  @moduledoc false
  use Master.Schema
  import EctoEnum, only: [defenum: 2]
  defenum StatusEnum, new: 0, provisioning: 1, ready: 2, busy: 3

  schema "workers" do
    field :ip, :string
    field :status, StatusEnum, default: :new
    has_many :tasks, Master.Task
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:ip, :status])
  end
end
