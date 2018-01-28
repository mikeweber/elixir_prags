defmodule BubblewrapEngineBoardTest do
  alias BubblewrapEngine.{Board, Bubble, Coordinate}

  use ExUnit.Case
  doctest BubblewrapEngine.Board

  test "creates a new Board" do
    {:ok, %Board{ max_players: 5 }} = Board.new(5)
  end

  test "can add a player" do
    {:ok, board} = Board.new(5, [:red])
    {:ok, %Board{ players: players }} = board |> Board.add_player(:red)
    assert MapSet.equal?(players, MapSet.new([:red]))
  end

  test "cannot add a duplicate player" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow])
    {:ok, %Board{ players: players }} = board |> Board.add_player(:yellow)

    assert MapSet.equal?(players, MapSet.new([:red, :orange, :yellow]))
  end

  test "cannot add a player when the board is full" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:full, %Board{ players: players }} = board |> Board.add_player(:violet)

    assert MapSet.equal?(players, MapSet.new([:red, :orange, :yellow, :green, :blue]))
  end

  test "can add a player that fills the board" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green])
    {:ok, %Board{ players: players }} = board |> Board.add_player(:blue)

    assert MapSet.equal?(players, MapSet.new([:red, :orange, :yellow, :green, :blue]))
  end

  test "can remove a player" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:ok, %Board{ players: players }} = board |> Board.remove_player(:orange)

    assert MapSet.equal?(players, MapSet.new([:red, :yellow, :green, :blue]))
  end

  test "cannot remove a non-existent player" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:ok, %Board{ players: players }} = board |> Board.remove_player(:periwinkle)

    assert MapSet.equal?(players, MapSet.new([:red, :orange, :yellow, :green, :blue]))
  end

  test "can pop a bubble" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:ok, coord} = Coordinate.new(0, 0)
    {:ok, %Bubble{ owner_id: nil }} = board |> Board.get_bubble(coord)

    {:ok, board, :keep_playing} = board |> Board.pop(:red, coord)
    {:ok, %Bubble{ owner_id: :red }} = board |> Board.get_bubble(coord)
  end

  test "cannot re-pop a popped bubble" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:ok, coord} = Coordinate.new(0, 0)
    {:ok, %Bubble{ owner_id: nil }} = board |> Board.get_bubble(coord)

    {:ok, board, :keep_playing} = board |> Board.pop(:red, coord)
    {:ok, %Bubble{ owner_id: :red }} = board |> Board.get_bubble(coord)

    {:ok, board, :keep_playing} = board |> Board.pop(:blue, coord)
    {:ok, %Bubble{ owner_id: :red }} = board |> Board.get_bubble(coord)
  end

  test "it can pop multiple bubbles" do
    {:ok, board} = Board.new(5, [:red, :orange, :yellow, :green, :blue])
    {:ok, coord1} = Coordinate.new(0, 0)
    {:ok, board, :keep_playing} = board |> Board.pop(:red, coord1)
    {:ok, %Bubble{ owner_id: :red }} = board |> Board.get_bubble(coord1)

    {:ok, coord2} = Coordinate.new(0, 1)
    {:ok, board, :keep_playing} = board |> Board.pop(:orange, coord2)
    {:ok, %Bubble{ owner_id: :orange }} = board |> Board.get_bubble(coord2)
  end
end
