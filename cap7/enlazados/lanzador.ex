defmodule Lanzador do
  def init do
    spawn(Lanzador, :loop, [])
  end

  def loop do
    receive
      {:link, pid} ->
        link(pid)
      :error ->
        throw(:error)
    end
    loop()
  end

  def agrega(lanzador, pid) do
    Process.send(lanzador, {:link, pid}, [])
  end
end
