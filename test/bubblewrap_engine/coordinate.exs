defmodule BubblewrapEngineCoordinateTest do
  alias BubblewrapEngine.Coordinate

  use ExUnit.Case
  doctest BubblewrapEngine.Coordinate

  test "creates a new coordinate" do
    {:ok, coord} = Coordinate.new(0, 0)
    assert coord == %Coordinate{ row: 0, col: 0 }
    {:ok, coord} = Coordinate.new(9, 9)
    assert coord == %Coordinate{ row: 9, col: 9 }
    {:ok, coord} = Coordinate.new(7, 3)
    assert coord == %Coordinate{ row: 7, col: 3 }
  end

  test "does not create out of range coordinates" do
    {:error, reason} = Coordinate.new(-1, 0)
    assert reason == :invalid_coordinate
    {:error, reason} = Coordinate.new(9, 10)
    assert reason == :invalid_coordinate
    {:error, reason} = Coordinate.new(-7, 13)
    assert reason == :invalid_coordinate
  end
end
