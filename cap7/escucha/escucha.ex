defmodule Escucha do
  def escucha do
    receive do
      {desde, mensaje} ->
        IO.puts("recibido: #{inspect mensaje}")
        Process.send(desde, :ok, [])
        escucha()
      :stop ->
        IO.puts("proceso terminado")
      after 5000 ->
        IO.puts("dime algo!")
        escucha()
    end
  end

  def para(pid) do
    Process.send(pid, :stop, [])
  end

  def dime(pid, algo) do
    Process.send(pid, {self(), algo}, [])
    receive do
      :ok -> :ok
    end
    :ok
  end

  def init do
    spawn(Escucha, :escucha, [])
  end
end
