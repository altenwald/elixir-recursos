defmodule Hash do
  def get(pid, key) do
    Process.send(pid, {:get, self(), key})
    receive do
      any -> any
    end
  end

  def set(pid, key, value) do
    Process.send(pid, {:set, key, value})
  end

  def init(node_name) do
    IO.puts("iniciado")
    spawn(node_name, fn ->
      Keyword.new()
      |> Keyword.put("hi", "hola")
      |> Keyword.put("bye", "adios")
      |> loop()
    end)
  end

  def loop(data) do
    receive do
      {:get, from, key} ->
        Process.send(from, data[key], [])
        loop(data)
      {:set, key, value} ->
        loop(Keyword.put(data, key, value))
      :stop ->
        :ok
    end
  end
end
