defmodule Cuatro.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cuatro,
      version: "1.0.0",
      elixir: "~> 1.7",
      elixirc_paths: ["lib"],
      start_permanent: true,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Cuatro.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    []
  end
end
