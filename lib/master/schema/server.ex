defmodule Server do
  @moduledoc false
  use Master.Schema

  schema "servers" do
    field :name, :string
    field :total_space, :integer
    field :available_space, :integer
    field :range_from, :float, virtual: true
    field :range_to, :float, virtual: true
    has_many :tasks, Schema.Task
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:name, :total_space, :available_space])
  end
end
