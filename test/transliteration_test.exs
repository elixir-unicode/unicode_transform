defmodule TransliterationTest do
  use ExUnit.Case
  doctest Transliteration

  test "greets the world" do
    assert Transliteration.hello() == :world
  end
end
