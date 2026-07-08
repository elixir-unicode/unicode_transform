defmodule Unicode.Transform.PatternTest do
  use ExUnit.Case, async: true

  alias Unicode.Transform.Pattern

  describe "to_regex_source/1" do
    test "expands \\u and \\U escape sequences to literals" do
      assert Pattern.to_regex_source("\\u0041") == "A"
      assert Pattern.to_regex_source("\\U00000041") == "A"
    end

    test "converts $n backreferences into regex backreferences" do
      assert Pattern.to_regex_source("$1") == "\\1"
    end

    test "handles escaped brackets inside a character class" do
      source = Pattern.to_regex_source("[a\\[b]")
      assert is_binary(source)
      assert {:ok, _regex} = Regex.compile(source, "u")
    end

    test "escapes an unparseable set rather than crashing" do
      assert is_binary(Pattern.to_regex_source("["))
    end
  end

  describe "compile/1" do
    test "compiles a literal pattern into a regex" do
      assert {:ok, regex} = Pattern.compile("abc")
      assert Regex.match?(regex, "abc")
    end
  end

  describe "apply_backreferences/2" do
    test "substitutes numbered captures" do
      assert Pattern.apply_backreferences("$1-$2", ["a", "b"]) == "a-b"
    end

    test "expands \\u escapes in the replacement" do
      assert Pattern.apply_backreferences("\\u0041", []) == "A"
    end

    test "treats an escaped character as a literal" do
      assert Pattern.apply_backreferences("\\n", []) == "n"
    end

    test "unwraps a quoted literal" do
      assert Pattern.apply_backreferences("'lit'", []) == "lit"
    end

    test "keeps a lone dollar sign that is not followed by a digit" do
      assert Pattern.apply_backreferences("$x", []) == "$x"
    end

    test "skips syntactic spaces" do
      assert Pattern.apply_backreferences("$1 x", ["AA"]) == "AAx"
    end
  end
end
