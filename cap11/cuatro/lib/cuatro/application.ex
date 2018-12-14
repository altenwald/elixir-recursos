defmodule Cuatro.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Cuatro.Juego, [])
    ]

    Logger.info "[app] iniciada aplicación"

    opts = [strategy: :one_for_one, name: Cuatro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
