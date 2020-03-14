defmodule Factories.UploadTask do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      def upload_task_factory do
        %Master.UploadTask{}
      end
    end
  end
end
