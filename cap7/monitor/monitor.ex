defmodule Monitor do
  def init do
    spawn(fn -> loop([]) end)
    |> Process.register(:monitor)
    :ok
  end

  def loop(state) do
    receive do
      {:monitor, from, name, fun} ->
        pid = lanza(name, fun)
        send from, {:ok, name}
        loop(Keyword.put(state, pid, [name, fun]))
      {:DOWN, _ref, :process, pid, _reason} ->
        [name, fun] = state[pid]
        new_pid = lanza(name, fun)
        IO.puts("reavivando hijo en #{inspect new_pid}")
        state
        |> Keyword.delete(pid)
        |> Keyword.put(new_pid, [name, fun])
    end
  end

  def lanza(name, fun) do
    pid = spawn_monitor(fun)
    Process.register pid, name
    Process.monitor pid
    pid
  end

  def agrega(name, fun) do
    send :monitor, {:monitor, self(), name, fun}
    receive do
      {:ok, pid} -> pid
    end
  end
end
