defmodule AlgumaTest do
  use ExUnit.Case
  doctest Alguma

  test "greets the world" do
    assert Alguma.hello() == :world
  end
end
