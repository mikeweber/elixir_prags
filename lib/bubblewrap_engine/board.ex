defmodule BubblewrapEngine.Board do
  require BubblewrapEngine.{Bubble, Coordinate}
  alias BubblewrapEngine.{Bubble, Coordinate}

  @enforce_keys [:max_players, :players, :popped_bubbles]
  defstruct [:max_players, :players, :popped_bubbles]

  def new(max_players, starting_players \\ []) do
    {:ok, %__MODULE__{ max_players: max_players, players: MapSet.new(starting_players), popped_bubbles: %{} }}
  end

  def add_player(%__MODULE__{ players: current_players, max_players: max_players } = board, player) do
    if is_full?(current_players, max_players) do
      {:full, board}
    else
      {:ok, append_player(board, player)}
    end
  end

  defp is_full?(players, max_players) do
    (players |> MapSet.size) >= max_players
  end
  defp append_player(%__MODULE__{ players: players } = board, player) do
    %{ board | players: players |> MapSet.put(player) }
  end

  def remove_player(%__MODULE__{ players: players } = board, player) do
    {:ok, %{ board | players: players |> MapSet.delete(player) }}
  end

  def pop(%__MODULE__{ popped_bubbles: bubbles } = board, player, %Coordinate{} = coord) do
    bubble =
      board
      |> get_bubble(coord)
      |> Bubble.set_owner(player)

    {:ok, %{ board | popped_bubbles: bubbles |> Map.put(coord |> to_atom, bubble) }, board |> game_status}
  end

  def game_status(%__MODULE__{} = board) do
    if still_playing?(board) do
      :keep_playing
    else
      :game_over
    end
  end

  def still_playing?(%__MODULE__{} = board) do
    Coordinate.board_range
    |> Enum.any?(fn row ->
      Coordinate.board_range
      |> Enum.any?(fn col ->
        {:ok, coord} = Coordinate.new(row, col)
        with {:ok, %Bubble{ owner_id: nil } = board} <- board |> get_bubble(coord)
        do
          true
        else
          {:ok, _bubble} -> false
        end
      end)
    end)
  end

  def get_bubble(%__MODULE__{ popped_bubbles: bubbles }, coord) do
    {:ok, bubbles[coord |> to_atom] || %Bubble{ coordinates: coord}}
  end

  def to_atom(%Coordinate{ row: row, col: col }) do
    "#{row}x#{col}" |> String.to_atom
  end
end
