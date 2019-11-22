defmodule Master.Server do
  @moduledoc false
  use Master.Schema

  schema "servers" do
    field :name, :string
    field :total_space, :integer, default: 0
    field :available_space, :integer, default: 0
    field :reserved_space, :integer, default: 0
    has_many :tasks, Master.Task
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:name, :total_space, :available_space, :reserved_space])
  end
end
