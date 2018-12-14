defmodule Gemelos do
  def lanza do
    spawn(Gemelos, :crea, [])
    :ok
  end

  def crea do
    spawn_link(Gemelos, :zipi, [0])
    Process.sleep(500)
    zape(0)
  end

  def zipi(a) do
    IO.puts("zipi - #{a}")
    Process.sleep(1000)
    zipi(a + 1)
  end

  def zape(a) do
    IO.puts("zape - #{a}")
    Process.sleep(1000)
    case a do
      a when a < 5 -> :ok
    end
    zape(a + 1)
  end
end
