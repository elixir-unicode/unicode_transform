defmodule Unicode.Transform.BuiltinTest do
  use ExUnit.Case, async: true

  alias Unicode.Transform.Builtin

  doctest Unicode.Transform.Builtin

  # Precomposed "A with diaeresis" (U+00C4) and its NFD decomposition.
  @composed <<0x00C4::utf8>>
  @decomposed <<?A, 0x0308::utf8>>

  describe "builtin?/1" do
    test "recognises built-in names case-insensitively" do
      assert Builtin.builtin?("NFC")
      assert Builtin.builtin?("any-upper")
      refute Builtin.builtin?("Latin-ASCII")
    end
  end

  describe "apply/2" do
    test "normalizes with NFD and NFC" do
      assert Builtin.apply(@composed, "NFD") == @decomposed
      assert Builtin.apply(@decomposed, "NFC") == @composed
    end

    test "applies case and identity operations" do
      assert Builtin.apply("hello", "Upper") == "HELLO"
      assert Builtin.apply("HELLO", "Lower") == "hello"
      assert Builtin.apply("anything", "Null") == "anything"
      assert Builtin.apply("anything", "Remove") == ""
    end

    test "title-cases multi-word strings" do
      assert Builtin.apply("hello world foo", "Title") == "Hello World Foo"
    end

    test "title-cases an empty string" do
      assert Builtin.apply("", "Title") == ""
    end

    test "raises for an unknown built-in transform" do
      assert_raise ArgumentError, fn -> Builtin.apply("x", "Bogus") end
    end
  end

  describe "case_transform?/1" do
    test "identifies case transforms" do
      assert Builtin.case_transform?("Upper")
      assert Builtin.case_transform?("Any-Title")
      refute Builtin.case_transform?("NFC")
    end
  end

  describe "inverse/1" do
    test "returns the inverse for each invertible built-in" do
      assert Builtin.inverse("NFC") == "NFD"
      assert Builtin.inverse("NFD") == "NFC"
      assert Builtin.inverse("NFKC") == "NFKD"
      assert Builtin.inverse("NFKD") == "NFKC"
      assert Builtin.inverse("Lower") == "Upper"
      assert Builtin.inverse("Upper") == "Lower"
      assert Builtin.inverse("Title") == "Lower"
      assert Builtin.inverse("Null") == "Null"
    end

    test "returns nil when no inverse exists" do
      assert Builtin.inverse("Remove") == nil
      assert Builtin.inverse("Latin-ASCII") == nil
    end
  end
end
