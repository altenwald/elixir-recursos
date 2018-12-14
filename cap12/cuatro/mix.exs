defmodule Cuatro.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cuatro,
      version: "2.0.0",
      elixir: "~> 1.7",
      elixirc_paths: ["lib"],
      start_permanent: true,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Cuatro.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:cowboy, "~> 2.5"},
      {:distillery, "~> 2.0"}
    ]
  end

  defp aliases do
    ["release.copy": &release_copy/1]
  end

  def release_copy(_) do
    File.mkdir "releases/#{project()[:version]}"
    "_build/dev/rel/cuatro/releases/*/*.tar.gz"
    |> Path.wildcard()
    |> Enum.each(fn(file) ->
                   [dir, f] = file
                              |> Path.split()
                              |> Enum.reverse()
                              |> Enum.slice(0, 2)
                              |> Enum.reverse()
                   target = "releases/#{dir}"
                   File.mkdir_p! target
                   File.cp! file, Path.join(target, f)
                 end)
  end
end
