defmodule BubblewrapEngineGameSupervisorTest do
  alias BubblewrapEngine.{Game, GameSupervisor}

  use ExUnit.Case
  doctest BubblewrapEngine.GameSupervisor

  test "integration test" do
    name = "game"
    {:ok, _game} = GameSupervisor.start_game(name, 2)
    via = Game.via_tuple(name)
    current_state = :sys.get_state(via)
    assert current_state.board.players == MapSet.new()

    :ok = Game.add_player(via, "red")
    :ok = Game.add_player(via, "blue")
    current_state = :sys.get_state(via)
    assert current_state.board.players == MapSet.new([:red, :blue])

    :error = Game.add_player(via, "green")

    Game.start_game(via)
    current_state = :sys.get_state(via)
    assert current_state.rules.state == :playing

    Game.pop_bubble(via, :red, 0, 0)
    current_state = :sys.get_state(via)
    assert (current_state.board.popped_bubbles |> Map.keys) == [:"0x0"]
    assert current_state.board.popped_bubbles[:"0x0"].owner_id == :red

    Game.pop_bubble(via, :blue, 0, 0)
    current_state = :sys.get_state(via)
    assert (current_state.board.popped_bubbles |> Map.keys) == [:"0x0"]
    assert current_state.board.popped_bubbles[:"0x0"].owner_id == :red

    Game.pop_bubble(via, :blue, 0, 1)
    current_state = :sys.get_state(via)
    assert (current_state.board.popped_bubbles |> Map.keys) == [:"0x0", :"0x1"]
    assert current_state.board.popped_bubbles[:"0x1"].owner_id == :blue
  end
end
