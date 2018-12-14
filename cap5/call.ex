defmodule Call do
  defmacro __using__([]) do
    quote do
      import Call
      use GenServer

      def start_link() do
        GenServer.start_link(__MODULE__, [], [name: __MODULE__])
      end

      def stop() do
        GenServer.stop(__MODULE__)
      end
    end
  end

  defmacro persist(args) do
    quote do
      import Record
      defrecord :state, [unquote_splicing(args)]

      def init([]) do
        {:ok, state()}
      end
    end
  end

  defmacro api(name, args, state, do: code) do
    quote do
      def unquote(name)(unquote_splicing(args)) do
        GenServer.call(__MODULE__, {unquote(name), unquote_splicing(args)})
      end
      def handle_call({unquote(name), unquote_splicing(args)}, _from, var!(state)) do
        unquote(code)
      end
    end
  end
end
