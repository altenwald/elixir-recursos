defmodule Cuatro.Websocket do
  require Logger
  alias Cuatro.Juego

  @jugador1 0
  @jugador2 1

  @jugador1_color "rojo"
  @jugador2_color "amarillo"

  @jugador1_simbolo "<td class='rojo'>&#9673;</td>"
  @jugador2_simbolo "<td class='amarillo'>&#9673;</td>"
  @nojugado_simbolo "<td class='vacio'>&#9673;</td>"

  @msg_ganador "<h1>¡¡¡ Ganaste !!!</h1>"
  @msg_perdedor "<h1>Perdiste :-(</h1>"
  @msg_empate "<h1>¡Empate!</h1>"

  def init(req, opts) do
    {:cowboy_websocket, req, opts}
  end

  def websocket_init(_opts) do
    {:ok, %{}}
  end

  def websocket_handle({:text, msg}, state) do
    msg
    |> Jason.decode!()
    |> process_data(state)
  end

  def websocket_handle(_any, state) do
    {:reply, {:text, "eh?"}, state}
  end

  def websocket_info({:send, data}, state) do
    {:reply, {:text, data}, state}
  end
  def websocket_info({:timeout, _ref, msg}, state) do
    {:reply, {:text, msg}, state}
  end

  def websocket_info(info, state) do
    Logger.info "info => #{inspect info}"
    {:ok, state}
  end

  def websocket_terminate(reason, _state) do
    Logger.info "reason => #{inspect reason}"
    :ok
  end

  defp send_to_all(juego, data) do
    data_json = Jason.encode!(data)
    juego
    |> Juego.jugadores()
    |> Enum.each(fn(jugador) ->
                   send(jugador, {:send, data_json})
                 end)
  end

  defp reply(data, state) do
    data_json = Jason.encode!(data)
    {:reply, {:text, data_json}, state}
  end

  defp process_data(%{"type" => "inserta", "pos" => pos},
                    state) do
    if Juego.existe?(state.juego) do
      case Juego.inserta(state.juego, pos) do
        {:gana, quien} ->
          html = muestra state.juego
          msg = %{"type" => "gana", "html" => html}
          [ganador, perdedor] = case quien do
            @jugador1 -> Juego.jugadores(state.juego)
            @jugador2 -> Juego.jugadores(state.juego)
                         |> Enum.reverse()
          end
          gana = Map.put(msg, "msg", @msg_ganador)
                 |> Jason.encode!()
          pierde = Map.put(msg, "msg", @msg_perdedor)
                   |> Jason.encode!()
          send ganador, {:send, gana}
          send perdedor, {:send, pierde}
          Juego.stop state.juego
        :lleno ->
          html = muestra state.juego
          msg = %{"type" => "gana", "html" => html,
                  "msg" => @msg_empate}
          send_to_all state.juego, msg
          Juego.stop state.juego
        :sigue ->
          html = muestra state.juego
          msg = %{"type" => "dibuja", "html" => html}
          send_to_all state.juego, msg
          quien = state.juego
                  |> Juego.quien_juega?()
                  |> color()
          turno = %{"type" => "turno", "quien" => quien}
          send_to_all state.juego, turno
        :col_llena ->
          :ok
        :turno_de_otro ->
          quien = state.juego
                  |> Juego.quien_juega?()
                  |> color()
          turno = %{"type" => "turno", "quien" => quien}
          send_to_all state.juego, turno
          :ok
      end
    end
    {:ok, state}
  end

  defp process_data(%{"type" => "muestra"}, state) do
    if Juego.existe?(state.juego) do
      html = muestra(state.juego)
      unless is_atom(html) do
        msg = %{"type" => "dibuja", "html" => html}
        send_to_all state.juego, msg
      end
    end
    {:ok, state}
  end

  defp process_data(%{"type" => "login", "juego" => juego},
                    state) do
    unless Juego.existe?(juego) do
      Juego.start_link juego
    end
    case Juego.inscribe_jugador(juego) do
      :partida_ocupada ->
        msg = %{"type" => "login", "result" => "busy"}
        reply msg, state
      jugador ->
        state = %{juego: juego}
        reply %{"type" => "login",
                "result" => "ok",
                "color" => color(jugador)}, state
    end
  end

  defp color(@jugador1), do: @jugador1_color
  defp color(@jugador2), do: @jugador2_color

  defp muestra(juego) do
    case Juego.muestra(juego) do
      atom when is_atom(atom) -> atom
      cols ->
        "<table id='juego'><tr>"
        |> add(for(i <- 0..(length(cols) - 1), do: th(i))
               |> Enum.join())
        |> add("</tr><tr>")
        |> add(cols
               |> Enum.map(&Enum.reverse/1)
               |> traspone()
               |> Enum.map(&traduce_simbolos/1)
               |> Enum.join("</tr><tr>"))
        |> add("</tr><tr>")
        |> add(for(i <- 0..(length(cols) - 1), do: boton(i))
               |> Enum.join())
        |> add("</tr></table>")
    end
  end

  defp add(str1, str2), do: str1 <> str2

  defp th(i) do
    "<th>#{i + 1}</th>"
  end

  defp boton(i) do
    "<td><button class='drop' id='drop_#{i}'>" <>
    "&uarr;</button></td>"
  end

  defp traspone([[]|_]), do: []
  defp traspone(matriz) do
    [ Enum.map(matriz, &hd/1) |
      traspone(Enum.map(matriz, &tl/1)) ]
  end

  defp simbolo(@jugador1), do: @jugador1_simbolo
  defp simbolo(@jugador2), do: @jugador2_simbolo
  defp simbolo(nil), do: @nojugado_simbolo

  defp traduce_simbolos(col) do
    col
    |> Enum.map(&simbolo/1)
    |> Enum.join()
  end
end
