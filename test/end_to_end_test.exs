defmodule Unicode.Transform.EndToEndTest do
  use ExUnit.Case, async: true

  describe "script transliteration" do
    test "transliterates Greek to Latin" do
      assert {:ok, result} = Unicode.Transform.transform("αβγδ", from: :greek, to: :latin)
      assert result == "abgd"
    end

    test "transliterates accented Greek without crashing" do
      assert {:ok, result} = Unicode.Transform.transform("αὐτός", from: :greek, to: :latin)
      assert is_binary(result)
    end

    test "transliterates Cyrillic to Latin" do
      assert {:ok, "Moskva"} = Unicode.Transform.transform("Москва", from: :cyrillic, to: :latin)
    end

    test "runs a script transform in the reverse direction" do
      assert {:ok, result} =
               Unicode.Transform.transform("hello", transform: "Greek-Latin", direction: :reverse)

      assert is_binary(result)
    end
  end

  describe "direct transform ids" do
    test "applies a locale transform" do
      assert {:ok, result} = Unicode.Transform.transform("café", transform: "de-ASCII")
      assert is_binary(result)
    end

    test "returns an error for an unknown transform id" do
      assert {:error, {:unknown_transform, "Nope-Xyz"}} =
               Unicode.Transform.transform("x", transform: "Nope-Xyz")
    end
  end

  describe "detection" do
    test "detects scripts and chains transforms with from: :detect" do
      assert {:ok, result} = Unicode.Transform.transform("αβγ Москва", from: :detect, to: :latin)
      assert is_binary(result)
    end
  end

  describe "transform!/2" do
    test "returns the string directly" do
      assert Unicode.Transform.transform!("hello", to: :upper) == "HELLO"
    end

    test "raises on error" do
      assert_raise ArgumentError, fn ->
        Unicode.Transform.transform!("x", transform: "Nope-Xyz")
      end
    end
  end
end
