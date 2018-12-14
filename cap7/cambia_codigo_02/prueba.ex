defmodule Prueba do
  def init, do: loop()

  def code_change do
    :code.purge __MODULE__
    :code.load_file __MODULE__
    __MODULE__.loop()
  end

  def loop do
    receive do
      :update ->
        __MODULE__.code_change()
      any ->
        IO.puts("cambio: #{inspect any}")
        loop()
    end
  end
end
