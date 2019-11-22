defmodule Factories.Task do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      def task_factory do
        %Master.Task{}
      end
    end
  end
end
