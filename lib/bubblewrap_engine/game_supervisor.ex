defmodule BubblewrapEngine.GameSupervisor do
  use Supervisor

  alias BubblewrapEngine.Game

  def start_game(name, max_players) do
    Supervisor.start_child(__MODULE__, [name, max_players])
  end

  def stop_game(name) do
    clear_cache(name)
    Supervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([Game], strategy: :simple_one_for_one)
  end

  defp pid_from_name(name) do
    name
    |> Game.via_tuple
    |> GenServer.whereis
  end

  defp clear_cache(name) do
    :ets.delete(:game_state, name)
  end
end
