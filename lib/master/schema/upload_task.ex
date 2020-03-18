defmodule Master.UploadTask do
  @moduledoc false
  use Master.Schema
  import EctoEnum, only: [defenum: 2]
  defenum StatusEnum, new: 0, in_progress: 1, uploaded: 2, committed: 3, failed: 4

  schema "upload_tasks" do
    field :movie_uuid, Ecto.UUID
    field :url, :string
    field :cdn_info, :map
    field :status, StatusEnum, default: :new
    belongs_to :server, Master.Server
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:movie_uuid, :url, :status, :server_id, :cdn_info])
  end
end
