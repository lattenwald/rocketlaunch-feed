defmodule RocketlaunchFeed.MixProject do
  use Mix.Project

  def project do
    [
      app: :rocketlaunch_feed,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RocketlaunchFeed.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug, "~> 1.15"},
      {:plug_cowboy, "~> 2.7"},
      {:httpoison, "~> 2.2"},
      {:poison, "~> 5.0"},
      {:timex, "~> 3.7"},
      {:xml_builder, "~> 2.2"},
      {:uuid, "~> 1.1"}
    ]
  end

  defp releases do
    [
      docker: [
        include_executables_for: [:unix],
        steps: [:assemble, :tar],
        path: "/app/release"
      ]
    ]
  end
end
