defmodule BubblewrapEngine.Rules do
  alias __MODULE__
  defstruct state: :initialized, max_players: 0, num_players: 0, players: []

  @colors ["red", "orange", "yellow", "green", "blue"]

  def new(max_players, num_players \\ 0), do: %Rules{ max_players: max_players, num_players: num_players }

  # Initialized
  def check(%Rules{ state: :initialized, num_players: num_players, max_players: max_players } = rules, {:player_joins, name}) when num_players + 1 == max_players and name in @colors do
    {:ok, %{ rules | num_players: num_players + 1, state: :beginning_game }}
  end
  def check(%Rules{ state: :initialized, num_players: num_players, max_players: max_players } = rules, {:player_joins, name}) when num_players < max_players and name in @colors do
    {:ok, %{ rules | num_players: num_players + 1 }}
  end

  # Beginning Game
  def check(%Rules{ state: :beginning_game } = rules, {:begin, players}) do
    {:ok, %{ rules | state: :playing, players: (players |> MapSet.to_list) }}
  end

  # Playing the Game
  def check(%Rules{ state: :playing, players: players } = rules, {:make_move, player}) do
    if players |> is_playing?(player) do
      {:ok, rules}
    else
      :error
    end
  end

  def check(%Rules{ state: :playing } = rules, :keep_playing) do
    {:ok, rules}
  end

  # Finish the game
  def check(%Rules{ state: :playing } = rules, :game_over) do
    {:ok, %{ rules | state: :done }}
  end

  # Fall through for errors
  def check(_state, _action), do: :error

  defp is_playing?(players, player) do
    players |> Enum.find(&(&1 == player))
  end
end
