defmodule Cuatro do
  require Logger
  alias Cuatro.Juego

  @jugador1 0
  @jugador2 1

  @jugador1_simbolo IO.ANSI.format(["[", :red_background,
                                    "O", :black_background,
                                    "]"])
  @jugador2_simbolo IO.ANSI.format(["[", :yellow_background,
                                    :black, "O", :white,
                                    :black_background, "]"])
  @nojugado_simbolo IO.ANSI.format(["[ ]"])

  @jugador1_color "rojo"
  @jugador2_color "amarillo"

  @msg_ganador "¡¡¡ Ganaste !!!"
  @msg_perdedor "Perdiste :-("

  defp muestra_a_todos do
    Juego.jugadores()
    |> Enum.each(fn(jugador) ->
                   info = Process.info(jugador)
                   muestra(info[:group_leader])
                 end)
  end

  defp muestra_a(jugador, msg) do
    leader = Process.info(jugador)[:group_leader]
    IO.puts(leader, msg)
  end

  @doc """
       Realiza el movimiento y retorna el estado, si ha
       ganado muestra el tablero y detiene el juego.
       """
  def mueve(col) do
    case Juego.inserta(col) do
      {:gana, quien} ->
        [ganador, perdedor] = case quien do
          @jugador1 -> Juego.jugadores()
          @jugador2 -> Enum.reverse Juego.jugadores()
        end
        muestra_a_todos()
        muestra_a ganador, @msg_ganador
        muestra_a perdedor, @msg_perdedor
        Juego.stop
      :esperando_jugadores ->
        IO.puts "esperando jugadores, inscríbase!"
      :sigue ->
        muestra_a_todos()
      :turno_de_otro ->
        IO.puts "es el turno del otro jugador... espere"
        :ok
      :col_llena ->
        IO.puts "columna llena, pruebe otra"
        :ok
    end
  end

  defp color(@jugador1), do: @jugador1_color
  defp color(@jugador2), do: @jugador2_color

  def inscribe_jugador() do
    case Juego.inscribe_jugador() do
      :partida_ocupada ->
        IO.puts "error: partida ocupada"
      jugador ->
        IO.puts "jugando como #{color(jugador)}"
    end
  end

  defp simbolo(@jugador1), do: @jugador1_simbolo
  defp simbolo(@jugador2), do: @jugador2_simbolo
  defp simbolo(nil), do: @nojugado_simbolo

  defp traduce_simbolos(col) do
    col
    |> Enum.map(&simbolo/1)
    |> Enum.join()
  end

  defp traspone([[]|_]), do: []
  defp traspone(matriz) do
    [ Enum.map(matriz, &hd/1) |
      traspone(Enum.map(matriz, &tl/1)) ]
  end

  @doc "Muestra el tablero"
  def muestra(device \\ :stdio) do
    cols = Juego.muestra()
    imprime = &(IO.puts(device, &1))

    cols
    |> Enum.map(&Enum.reverse/1)
    |> traspone()
    |> Enum.map(&traduce_simbolos/1)
    |> Enum.join("\n")
    |> imprime.()

    for(i <- 0..(length(cols) - 1),
      do: if(i<10, do: " #{i} ", else: "#{i} "))
    |> Enum.join()
    |> imprime.()
  end

end
