defmodule BubblewrapEngineRulesTest do
  alias BubblewrapEngine.Rules

  use ExUnit.Case
  doctest BubblewrapEngine.Rules

  test "can add a new player as long as there's room" do
    rules = %{ Rules.new(5) | num_players: 3 }
    {:ok, %{ state: :initialized, num_players: 4 }} = rules |> Rules.check({:player_joins, "red"})
  end

  test "only allows certain colors as names" do
    rules = %Rules{ max_players: 2 }

    {:ok, %{ state: :initialized }} = rules |> Rules.check({:player_joins, "red"})
    {:ok, %{ state: :initialized }} = rules |> Rules.check({:player_joins, "orange"})
    {:ok, %{ state: :initialized }} = rules |> Rules.check({:player_joins, "yellow"})
    {:ok, %{ state: :initialized }} = rules |> Rules.check({:player_joins, "green"})
    {:ok, %{ state: :initialized }} = rules |> Rules.check({:player_joins, "blue"})

    :error = rules |> Rules.check({:player_joins, "periwinkle"})
  end

  test "transitions to :beginning_game" do
    rules = %{ Rules.new(5) | num_players: 4 }
    {:ok, %{ state: :beginning_game, num_players: 5 }} = rules |> Rules.check({:player_joins, "red"})
  end

  test "cannot add a player to a full game" do
    rules = %{ Rules.new(5) | num_players: 5 }
    assert :error == rules |> Rules.check({:player_joins, "red"})
  end

  test "can transition from :beginning_game to :playing" do
    rules = %{ Rules.new(5) | num_players: 5, state: :beginning_game }
    {:ok, %Rules{ state: :playing, players: [:orange, :red] } } = rules |> Rules.check({:begin, MapSet.new([:red, :orange])})
  end

  test "can make a move" do
    rules = %{ Rules.new(5) | state: :playing, players: [:red, :orange] }
    {:ok, %Rules{ state: :playing } } = rules |> Rules.check({:make_move, :red})
  end

  test "can keep playing" do
    rules = %{ Rules.new(5) | state: :playing, players: [:red, :orange] }
    {:ok, %Rules{ state: :playing } } = rules |> Rules.check(:keep_playing)
  end

  test "cannot make a move with a player who isn't playing" do
    rules = %{ Rules.new(5) | state: :playing, players: [:red, :orange] }
    assert :error == rules |> Rules.check({:make_move, :periwinkle})
  end

  test "can end the game" do
    rules = %{ Rules.new(5) | state: :playing }
    {:ok, %Rules{ state: :done } } = rules |> Rules.check(:game_over)
  end
end
