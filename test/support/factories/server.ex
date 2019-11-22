defmodule Factories.Server do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      def server_factory do
        %Master.Server{}
      end
    end
  end
end
