defmodule AlgumaElixirTest do
  use ExUnit.Case
  doctest AlgumaElixir

  test "greets the world" do
    assert AlgumaElixir.hello() == :world
  end
end
