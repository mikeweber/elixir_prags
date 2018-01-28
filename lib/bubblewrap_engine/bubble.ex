defmodule BubblewrapEngine.Bubble do
  require BubblewrapEngine.Coordinate
  alias __MODULE__
  @enforce_keys [:coordinates]
  defstruct [:coordinates, :owner_id]

  def new({:ok, coordinates = %BubblewrapEngine.Coordinate{}}), do: new(coordinates)
  def new(coordinates = %BubblewrapEngine.Coordinate{}) do
    {:ok, %Bubble{ coordinates: coordinates }}
  end

  def set_owner({:ok, bubble}, owner_id), do: set_owner(bubble, owner_id)
  def set_owner(bubble = %Bubble{ owner_id: nil }, owner_id) do
    %{ bubble | owner_id: owner_id }
  end
  def set_owner(bubble = %Bubble{}, _owner_id), do: bubble
end
