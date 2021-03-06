defmodule BubblewrapEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: BubblewrapEngine.Worker.start_link(arg)
      # {BubblewrapEngine.Worker, arg},
      {Registry, keys: :unique, name: Registry.Game},
      BubblewrapEngine.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    :ets.new(:game_state, [:public, :named_table])
    opts = [strategy: :one_for_one, name: BubblewrapEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
