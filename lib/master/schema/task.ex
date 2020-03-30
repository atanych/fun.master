defmodule Master.Task do
  @moduledoc false
  use Master.Schema
  import EctoEnum, only: [defenum: 2]

  defenum StatusEnum,
    new: 0,
    in_progress: 1,
    loading: 2,
    ready_to_tar: 3,
    file_not_found: 4,
    bad_file: 5,
    delete_before_restarting: 6,
    restarting: 7,
    done: 8

  schema "tasks" do
    field :movie_uuid, Ecto.UUID
    field :origin_url, :string
    field :status, StatusEnum, default: :new
    field :pid, :string
    field :url, :string
    field :origin_server_ip, :string
    belongs_to :server, Master.Server
    belongs_to :worker, Master.Worker
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [
      :movie_uuid,
      :origin_url,
      :status,
      :server_id,
      :worker_id,
      :pid,
      :url,
      :origin_server_ip,
      :updated_at,
      :inserted_at
    ])
  end
end
