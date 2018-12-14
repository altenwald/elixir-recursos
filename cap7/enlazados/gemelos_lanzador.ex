defmodule GemelosLanzador do
  def lanza do
    lanzador_pid = Lanzador.init()
    zipi = spawn(GemelosLanzador, :zipi, [0])
    Lanzador.agrega(lanzador_pid, zipi)
    Process.sleep(500)
    zape = spawn(GemelosLanzador, :zape, [0])
    Lanzador.agrega(lanzador_pid, zape)
    lanzador_pid
  end

  def zipi(a) do
    IO.puts("zipi - #{a}")
    Process.sleep(1000)
    zipi(a + 1)
  end

  def zape(a) do
    IO.puts("zape - #{a}")
    Process.sleep(1000)
    zape(a + 1)
  end
end
