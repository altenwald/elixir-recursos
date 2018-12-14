defmodule Prueba do
  def init, do: loop()
  def loop do
    receive do
      any -> IO.puts("original: #{inspect any}")
    end
    __MODULE__.loop()
  end
end
