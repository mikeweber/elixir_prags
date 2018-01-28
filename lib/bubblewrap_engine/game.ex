defmodule BubblewrapEngine.Game do
  alias BubblewrapEngine.{Board, Coordinate, Rules}
  use GenServer

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def init(max_players) do
    board = Board.new(max_players)
    {:ok, %{ board: board, rules: Rules.new(max_players) }}
  end

  # GenServer calls
  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def start_game(game) do
    GenServer.call(game, :start_game)
  end

  def pop_bubble(game, player, row, col) do
    GenServer.call(game, {:pop, player, row, col})
  end

  # Handlers
  def handle_call({:add_player, name}, _from, %{ rules: rules } = state) do
    with {:ok, rules} <- Rules.check(rules, {:player_joins, name})
    do
      state
      |> append_player(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end
  def handle_call(:start_game, _from, %{ rules: rules, players: players } = state) do
    with {:ok, rules} <- Rules.check(rules, {:begin, players})
    do
      state
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end
  def handle_call({:pop, player, row, col}, _from, %{ rules: rules, board: board } = state) do
    with {:ok, rules} <- Rules.check(rules, {:make_move, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, board, game_status} <- Board.pop(board, player, coordinate),
         {:ok, rules} <- Rules.check(rules, {game_status})
    do
      state
      |> update_board(board)
      |> update_rules(rules)
      |> reply_success({:ok, board, game_status})
    else
      :error ->
        {:reply, :error, state}
      {:error, :invalid_coordinate} ->
        {:reply, {:error, :invalid_coordinate}, state}
    end
  end
  #TODO
  # Know when the game is over and handle that, too

  defp append_player(%{ board: board } = state, name) do
    %{ state | board: board |> Board.add_player(name |> String.to_atom) }
  end

  defp pop(%{ board: board } = state, player, coordinate) do
    %{ state | board: board |> Board.pop(player, coordinate) }
  end

  def determine_game_status(%{ board: board, rules: rules } = state) do

  end

  defp update_board(state, board), do: %{ state | board: board }

  defp update_rules(state, rules), do: %{ state | rules: rules }

  defp reply_success(state, reply), do: {:reply, reply, state}
end
