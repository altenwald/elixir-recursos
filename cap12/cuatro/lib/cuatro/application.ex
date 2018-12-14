defmodule Cuatro.Application do
  use Application

  require Logger

  @port 1234
  @family :inet

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    port = Application.get_env(:cuatro, :port, @port)
    family = Application.get_env(:cuatro, :family, @family)

    children = [
      supervisor(Registry, [:unique, Cuatro.Registry]),
      worker(Cuatro.Http, [port, family])
    ]

    Logger.info "[app] iniciada aplicación"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cuatro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
