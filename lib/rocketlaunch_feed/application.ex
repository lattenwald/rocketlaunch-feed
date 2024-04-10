defmodule RocketlaunchFeed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:rocketlaunch_feed, :port, 4093)

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: RocketlaunchFeed.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: RocketlaunchFeed.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
