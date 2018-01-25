defmodule BubblewrapEngineBubbleTest do
  alias BubblewrapEngine.Coordinate
  alias BubblewrapEngine.Bubble

  use ExUnit.Case
  doctest BubblewrapEngine.Bubble

  test "creates a new Bubble" do
    {:ok, coord} = Coordinate.new(0, 0)
    {:ok, bubble} = Bubble.new(coord)
    assert bubble.coordinates == coord
  end

  test "assigns an owner to a bubble" do
    {:ok, bubble} =
      Coordinate.new(0, 0)
      |> Bubble.new

    assert bubble.owner_id == nil

    bubble =
      bubble
      |> Bubble.set_owner(1)

    assert bubble.owner_id == 1
  end
end

