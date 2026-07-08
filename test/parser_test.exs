defmodule Unicode.Transform.ParserTest do
  use ExUnit.Case, async: true

  alias Unicode.Transform.Parser
  alias Unicode.Transform.Rule.{Comment, Conversion, Definition, Filter, Transform}

  describe "parse_rule/1" do
    test "returns nil for blank lines" do
      assert Parser.parse_rule("") == nil
      assert Parser.parse_rule("   ") == nil
    end

    test "parses comments" do
      assert %Comment{text: "a note"} = Parser.parse_rule("# a note")
    end

    test "parses variable definitions" do
      assert %Definition{variable: "vowel", value: "[aeiou]"} =
               Parser.parse_rule("$vowel = [aeiou] ;")
    end

    test "treats a malformed definition as a comment" do
      assert %Comment{text: "$1bad = x"} = Parser.parse_rule("$1bad = x")
    end

    test "parses forward, backward and dual conversions" do
      assert %Conversion{direction: :forward} = Parser.parse_rule("a → b ;")
      assert %Conversion{direction: :backward} = Parser.parse_rule("a ← b ;")
      assert %Conversion{direction: :both} = Parser.parse_rule("a ↔ b ;")
    end

    test "parses filter directives" do
      assert %Filter{direction: :forward} = Parser.parse_rule(":: [a-z] ;")
      assert %Filter{direction: :inverse} = Parser.parse_rule(":: ([a-z]) ;")
    end

    test "parses a simple transform directive" do
      assert %Transform{forward: "Latin-Greek", backward: "Latin-Greek"} =
               Parser.parse_rule(":: Latin-Greek ;")
    end

    test "falls back to a whole-content transform when the directive is not a strict pair" do
      assert %Transform{forward: "name (a b)"} = Parser.parse_rule(":: name (a b) ;")
    end
  end

  describe "parse/1" do
    test "splits multiple rules and ignores empty segments" do
      rules = Parser.parse(";  ; a → b ;")
      assert [%Conversion{direction: :forward}] = rules
    end

    test "parses a braced revisit on the right-hand side" do
      assert [%Conversion{right: %{revisit: "b", after_context: "y"}}] =
               Parser.parse("x → { a | b } y ;")
    end

    test "keeps escaped brackets inside a character class intact" do
      assert [%Conversion{left: %{text: "[a\\[b\\]c]"}}] =
               Parser.parse("[a\\[b\\]c] → z ;")
    end

    test "treats an arrow that only appears inside a character class as a comment" do
      assert [%Comment{}] = Parser.parse("[a → b]")
    end
  end
end
