defmodule Unicode.TransformTest do
  use ExUnit.Case, async: true

  describe "built-in transforms" do
    test "Any-Upper transforms to uppercase" do
      assert {:ok, "HELLO WORLD"} = Unicode.Transform.transform("hello world", to: :upper)
    end

    test "Any-Lower transforms to lowercase" do
      assert {:ok, "hello world"} = Unicode.Transform.transform("HELLO WORLD", to: :lower)
    end

    test "Any-Title transforms to title case" do
      assert {:ok, "Hello World"} = Unicode.Transform.transform("hello world", to: :title)
    end

    test "Any-Null is identity" do
      assert {:ok, "hello"} = Unicode.Transform.transform("hello", to: :null)
    end

    test "Any-Remove removes all characters" do
      assert {:ok, ""} = Unicode.Transform.transform("hello", to: :remove)
    end

    test "NFC normalization" do
      input = "A\u0308"
      assert {:ok, "Ä"} = Unicode.Transform.transform(input, to: :nfc)
    end

    test "NFD normalization" do
      input = "Ä"
      {:ok, result} = Unicode.Transform.transform(input, to: :nfd)
      assert String.normalize(result, :nfd) == result
    end
  end

  describe "transform!/2" do
    test "returns result directly" do
      assert "A O U ss" = Unicode.Transform.transform!("Ä Ö Ü ß", from: :latin, to: :ascii)
    end

    test "raises for unknown transform" do
      assert_raise ArgumentError, fn ->
        Unicode.Transform.transform!("hello", transform: "NonExistent-Transform-XYZ")
      end
    end
  end

  describe "error handling" do
    test "returns error for unknown transform" do
      assert {:error, {:unknown_transform, _}} =
               Unicode.Transform.transform("hello", transform: "NonExistent-Transform-XYZ")
    end

    test "returns error when :to is missing" do
      assert {:error, {:missing_option, :to}} =
               Unicode.Transform.transform("hello", from: :any)
    end

    test "returns error for unknown transform from atoms" do
      assert {:error, {:unknown_transform, _}} =
               Unicode.Transform.transform("hello", from: :nonexistent, to: :also_nonexistent)
    end
  end

  describe "parser" do
    alias Unicode.Transform.Parser
    alias Unicode.Transform.Rule.{Comment, Conversion, Definition, Filter, Transform}

    test "parses comment" do
      rules = Parser.parse("# This is a comment")
      assert [%Comment{text: "This is a comment"}] = rules
    end

    test "parses filter rule" do
      rules = Parser.parse(":: [[:Latin:][:Common:]] ;")
      assert [%Filter{unicode_set: "[[:Latin:][:Common:]]", direction: :forward}] = rules
    end

    test "parses inverse filter rule" do
      rules = Parser.parse(":: ([[:Latin:]]) ;")
      assert [%Filter{unicode_set: "[[:Latin:]]", direction: :inverse}] = rules
    end

    test "parses transform rule" do
      rules = Parser.parse(":: NFD ;")
      assert [%Transform{forward: "NFD", backward: "NFD"}] = rules
    end

    test "parses transform with forward only" do
      rules = Parser.parse(":: NFD () ;")
      assert [%Transform{forward: "NFD", backward: nil}] = rules
    end

    test "parses transform with backward only" do
      rules = Parser.parse(":: (NFC) ;")
      assert [%Transform{forward: nil, backward: "NFC"}] = rules
    end

    test "parses transform with both directions" do
      rules = Parser.parse(":: NFD (NFC) ;")
      assert [%Transform{forward: "NFD", backward: "NFC"}] = rules
    end

    test "parses variable definition" do
      rules = Parser.parse("$vowel = [aeiou] ;")
      assert [%Definition{variable: "vowel", value: "[aeiou]"}] = rules
    end

    test "parses simple forward conversion" do
      rules = Parser.parse("Æ → AE ;")
      assert [%Conversion{direction: :forward, left: left, right: right}] = rules
      assert left.text == "Æ"
      assert right.text == "AE"
    end

    test "parses backward conversion" do
      rules = Parser.parse("AE ← Æ ;")
      assert [%Conversion{direction: :backward, left: left, right: right}] = rules
      assert left.text == "Æ"
      assert right.text == "AE"
    end

    test "parses dual conversion" do
      rules = Parser.parse("Æ ↔ AE ;")
      assert [%Conversion{direction: :both, left: left, right: right}] = rules
      assert left.text == "Æ"
      assert right.text == "AE"
    end

    test "parses conversion with before context" do
      rules = Parser.parse("[[:Latin:][0-9]] { [:Mn:]+ → ;")
      assert [%Conversion{direction: :forward, left: left, right: right}] = rules
      assert left.before_context == "[[:Latin:][0-9]]"
      assert left.text == "[:Mn:]+"
      assert right.text == ""
    end

    test "parses conversion with revisit" do
      rules = Parser.parse("a → b | c ;")
      assert [%Conversion{direction: :forward, left: left, right: right}] = rules
      assert left.text == "a"
      assert right.text == "b"
      assert right.revisit == "c"
    end

    test "parses multiple rules" do
      text = """
      :: [[:Latin:]] ;
      :: NFD ;
      Æ → AE ;
      ß → ss ;
      """

      rules = Parser.parse(text)
      assert length(rules) == 4
      assert %Filter{} = Enum.at(rules, 0)
      assert %Transform{} = Enum.at(rules, 1)
      assert %Conversion{} = Enum.at(rules, 2)
      assert %Conversion{} = Enum.at(rules, 3)
    end

    test "parses conversion with before and after context" do
      rules = Parser.parse("a { b } c → d ;")
      assert [%Conversion{left: left}] = rules
      assert left.before_context == "a"
      assert left.text == "b"
      assert left.after_context == "c"
    end
  end

  describe "Latin-ASCII transform" do
    test "transforms German special characters" do
      assert {:ok, "A O U ss"} = Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
    end

    test "transforms French accented text" do
      assert {:ok, "resume"} = Unicode.Transform.transform("résumé", from: :latin, to: :ascii)
    end

    test "transforms ligatures" do
      assert {:ok, "AE ae OE oe"} =
               Unicode.Transform.transform("Æ æ Œ œ", from: :latin, to: :ascii)
    end

    test "preserves ASCII text" do
      assert {:ok, "hello world"} =
               Unicode.Transform.transform("hello world", from: :latin, to: :ascii)
    end

    test "transforms Icelandic characters" do
      assert {:ok, "D d TH th"} = Unicode.Transform.transform("Ð ð Þ þ", from: :latin, to: :ascii)
    end

    test "transforms Polish characters" do
      assert {:ok, "L l"} = Unicode.Transform.transform("Ł ł", from: :latin, to: :ascii)
    end

    test "transforms empty string" do
      assert {:ok, ""} = Unicode.Transform.transform("", from: :latin, to: :ascii)
    end

    test "handles already ASCII text" do
      assert {:ok, "ABCdef123"} =
               Unicode.Transform.transform("ABCdef123", from: :latin, to: :ascii)
    end

    test "handles mixed content" do
      assert {:ok, "cafe resume"} =
               Unicode.Transform.transform("café résumé", from: :latin, to: :ascii)
    end
  end

  describe "de-ASCII transform" do
    test "transforms German umlauts with context-sensitive rules" do
      assert {:ok, "AE oe ue"} = Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
    end
  end

  describe "Hiragana-Katakana transform" do
    test "transforms hiragana to katakana" do
      {:ok, result} = Unicode.Transform.transform("あいうえお", from: :hiragana, to: :katakana)
      assert String.to_charlist(result) == [0x30A2, 0x30A4, 0x30A6, 0x30A8, 0x30AA]
    end

    test "inverse transforms katakana to hiragana" do
      {:ok, result} = Unicode.Transform.transform("アイウエオ", from: :katakana, to: :hiragana)
      assert String.to_charlist(result) == [0x3042, 0x3044, 0x3046, 0x3048, 0x304A]
    end

    test "round-trip preserves text" do
      original = "あいうえお"
      {:ok, katakana} = Unicode.Transform.transform(original, from: :hiragana, to: :katakana)
      {:ok, back} = Unicode.Transform.transform(katakana, from: :katakana, to: :hiragana)
      assert String.to_charlist(back) == String.to_charlist(original)
    end
  end

  describe "Greek-Latin transform" do
    test "transforms basic Greek letters" do
      {:ok, result} = Unicode.Transform.transform("αβγδ", from: :greek, to: :latin)
      assert result == "abgd"
    end

    test "transforms uppercase Greek" do
      {:ok, result} = Unicode.Transform.transform("ΑΒΓΔ", from: :greek, to: :latin)
      assert result == "ABGD"
    end

    test "transforms eta to e with macron" do
      {:ok, result} = Unicode.Transform.transform("η", from: :greek, to: :latin)
      assert String.to_charlist(result) == [0x0113]
    end

    test "transforms full Greek word" do
      {:ok, result} = Unicode.Transform.transform("Ελληνικά", from: :greek, to: :latin)
      expected_codepoints = [69, 108, 108, 275, 110, 105, 107, 225]
      assert String.to_charlist(result) == expected_codepoints
    end
  end

  describe "Any-Publishing transform" do
    test "transforms straight quotes to curly quotes" do
      {:ok, result} = Unicode.Transform.transform("Hello \"World\"", to: :publishing)
      assert String.contains?(result, "\u201C") or String.contains?(result, "\u201D")
    end
  end

  describe "available_transforms" do
    test "lists available transforms" do
      transforms = Unicode.Transform.available_transforms()
      assert is_list(transforms)
      assert "Latin-ASCII" in transforms
      assert "Greek-Latin" in transforms
      assert "Hiragana-Katakana" in transforms
    end
  end

  describe "Cyrillic-Latin transform" do
    test "transforms basic Cyrillic" do
      {:ok, result} = Unicode.Transform.transform("абвг", from: :cyrillic, to: :latin)
      assert result == "abvg"
    end

    test "reverse transforms Latin to Cyrillic" do
      {:ok, result} = Unicode.Transform.transform("hello", from: :latin, to: :cyrillic)
      assert is_binary(result)
      assert String.length(result) > 0
    end
  end

  describe "Arabic-Latin transform" do
    test "transforms basic Arabic" do
      {:ok, result} = Unicode.Transform.transform("عربي", from: :arabic, to: :latin)
      assert is_binary(result)
      assert String.length(result) > 0
    end
  end

  describe "Devanagari-Latin transform" do
    test "transforms Devanagari text" do
      {:ok, result} = Unicode.Transform.transform("नमस्ते", from: :devanagari, to: :latin)
      assert is_binary(result)
      assert result != "नमस्ते"
    end
  end

  describe "Bengali transforms" do
    test "Bengali-Latin" do
      {:ok, result} = Unicode.Transform.transform("বাংলা", from: :bengali, to: :latin)
      assert is_binary(result)
      assert result != "বাংলা"
    end

    test "Bengali-Devanagari" do
      {:ok, result} = Unicode.Transform.transform("বাংলা", from: :bengali, to: :devanagari)
      assert is_binary(result)
      assert result != "বাংলা"
    end

    test "Bengali-Gujarati" do
      {:ok, result} = Unicode.Transform.transform("বাংলা", from: :bengali, to: :gujarati)
      assert is_binary(result)
      assert result != "বাংলা"
    end

    test "Bengali-Tamil" do
      {:ok, result} = Unicode.Transform.transform("বাংলা", from: :bengali, to: :tamil)
      assert is_binary(result)
      assert result != "বাংলা"
    end

    test "Bengali-Telugu" do
      {:ok, result} = Unicode.Transform.transform("বাংলা", from: :bengali, to: :telugu)
      assert is_binary(result)
      assert result != "বাংলা"
    end
  end

  describe "Devanagari cross-script transforms" do
    test "Devanagari-Bengali" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :bengali)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Gujarati" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :gujarati)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Kannada" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :kannada)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Malayalam" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :malayalam)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Oriya" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :oriya)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Tamil" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :tamil)
      assert is_binary(result)
      assert result != "हिन्दी"
    end

    test "Devanagari-Telugu" do
      {:ok, result} = Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :telugu)
      assert is_binary(result)
      assert result != "हिन्दी"
    end
  end

  describe "Thai-Latin transform" do
    test "transforms basic Thai" do
      {:ok, result} = Unicode.Transform.transform("ไทย", from: :thai, to: :latin)
      assert is_binary(result)
      assert result != "ไทย"
      # Should not contain regex metacharacters
      refute String.contains?(result, "[")
      refute String.contains?(result, "]")
    end
  end

  describe "Hebrew-Latin transform" do
    test "transforms basic Hebrew" do
      {:ok, result} = Unicode.Transform.transform("שלום", from: :hebrew, to: :latin)
      assert is_binary(result)
      assert result != "שלום"
    end
  end

  describe "Hangul-Latin transform" do
    test "transforms Korean text" do
      {:ok, result} = Unicode.Transform.transform("한글", from: :hangul, to: :latin)
      assert result == "hangeul"
    end

    test "transforms Korean greeting" do
      {:ok, result} = Unicode.Transform.transform("가", from: :hangul, to: :latin)
      assert is_binary(result)
      assert result != "가"
    end
  end

  describe "Katakana-Latin transform" do
    test "transforms basic Katakana" do
      {:ok, result} = Unicode.Transform.transform("アイウ", from: :katakana, to: :latin)
      assert result == "aiu"
    end
  end

  describe "Armenian-Latin-BGN transform" do
    test "transforms Armenian text" do
      {:ok, result} = Unicode.Transform.transform("Հայաստան", transform: "Armenian-Latin-BGN")
      assert result == "Hayastan"
    end
  end

  describe "Georgian transforms" do
    test "Georgian-Latin" do
      {:ok, result} = Unicode.Transform.transform("საქართველო", from: :georgian, to: :latin)
      assert result == "sakartvelo"
    end

    test "Georgian-Latin-BGN" do
      {:ok, result} = Unicode.Transform.transform("საქართველო", transform: "Georgian-Latin-BGN")
      assert result == "sakartvelo"
    end
  end

  describe "Fullwidth-Halfwidth transform" do
    test "transforms fullwidth to halfwidth" do
      {:ok, result} =
        Unicode.Transform.transform("\uFF21\uFF22", from: :fullwidth, to: :halfwidth)

      assert result == "AB"
    end
  end

  describe "CanadianAboriginal-Latin transform" do
    test "transforms Canadian Aboriginal syllabics" do
      {:ok, result} = Unicode.Transform.transform("ᐃ", from: :canadian_aboriginal, to: :latin)
      assert is_binary(result)
      assert result != "ᐃ"
    end
  end

  describe "Gujarati-Devanagari transform" do
    test "transforms Gujarati to Devanagari" do
      {:ok, result} = Unicode.Transform.transform("ગુજરાતી", from: :gujarati, to: :devanagari)
      assert is_binary(result)
      assert result != "ગુજરાતી"
    end
  end

  describe "Latin-Katakana transform" do
    test "transforms Latin to Katakana" do
      {:ok, result} = Unicode.Transform.transform("tokyo", from: :latin, to: :katakana)
      assert is_binary(result)
      assert result != "tokyo"
    end
  end

  describe "Latin-Hangul transform" do
    test "transforms Latin to Hangul" do
      {:ok, result} = Unicode.Transform.transform("hangul", from: :latin, to: :hangul)
      assert is_binary(result)
      assert result != "hangul"
    end
  end

  describe "loader" do
    test "loads a transform file" do
      data = Unicode.Transform.Loader.load_file("transforms/Latin-ASCII.xml")
      assert data.source == "Latin"
      assert data.target == "ASCII"
      assert data.direction == "both"
      assert is_binary(data.rules)
      assert String.length(data.rules) > 0
    end

    test "derives transform ID from file path" do
      assert "Latin-ASCII" =
               Unicode.Transform.Loader.transform_id_from_file("transforms/Latin-ASCII.xml")
    end

    test "finds transforms by alias" do
      assert {_path, :forward} = Unicode.Transform.Loader.find_transform("Latin-ASCII")
    end

    test "finds transforms by backward alias" do
      assert {_path, :backward} =
               Unicode.Transform.Loader.find_transform("CanadianAboriginal-Latin")
    end
  end

  describe "pattern module" do
    alias Unicode.Transform.Pattern

    test "compiles literal pattern" do
      assert {:ok, regex} = Pattern.compile("hello")
      assert Regex.match?(regex, "hello")
    end

    test "compiles Unicode set pattern" do
      assert {:ok, regex} = Pattern.compile("[:Mn:]+")
      assert Regex.match?(regex, "\u0308")
    end

    test "applies backreferences" do
      assert "ba" = Pattern.apply_backreferences("$2$1", ["a", "b"])
    end

    test "handles replacement without backreferences" do
      assert "hello" = Pattern.apply_backreferences("hello", [])
    end
  end

  describe "transform with :transform and :direction options" do
    test "uses transform ID directly" do
      {:ok, result} = Unicode.Transform.transform("Ä Ö Ü ß", transform: "Latin-ASCII")
      assert result == "A O U ss"
    end

    test "uses :direction option with transform ID" do
      {:ok, katakana} =
        Unicode.Transform.transform("あいうえお", transform: "Hiragana-Katakana")

      {:ok, back} =
        Unicode.Transform.transform(katakana, transform: "Hiragana-Katakana", direction: :reverse)

      assert String.to_charlist(back) == String.to_charlist("あいうえお")
    end

    test "defaults direction to :forward" do
      {:ok, result} = Unicode.Transform.transform("абвг", transform: "Cyrillic-Latin")
      assert result == "abvg"
    end
  end

  describe "string :from/:to options" do
    test "accepts string :to" do
      assert {:ok, "HELLO"} = Unicode.Transform.transform("hello", to: "Upper")
    end

    test "accepts string :from and :to" do
      assert {:ok, "abgd"} = Unicode.Transform.transform("αβγδ", from: "Greek", to: "Latin")
    end

    test "accepts string :from with atom :to" do
      assert {:ok, "abgd"} = Unicode.Transform.transform("αβγδ", from: "Greek", to: :latin)
    end

    test "accepts atom :from with string :to" do
      assert {:ok, "A O U ss"} = Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: "ASCII")
    end

    test "case-insensitive string :to" do
      assert {:ok, "HELLO"} = Unicode.Transform.transform("hello", to: "upper")
    end

    test "case-insensitive string :from and :to" do
      assert {:ok, "abgd"} = Unicode.Transform.transform("αβγδ", from: "greek", to: "latin")
    end

    test "case-insensitive :transform option" do
      assert {:ok, "A O U ss"} = Unicode.Transform.transform("Ä Ö Ü ß", transform: "latin-ascii")
    end

    test "passes through unknown string names unchanged" do
      assert {:ok, "AE oe ue"} = Unicode.Transform.transform("Ä ö ü", from: "de", to: "ASCII")
    end

    test "resolves transform from non-script atoms" do
      assert {:ok, "AE oe ue"} = Unicode.Transform.transform("Ä ö ü", from: :de, to: :ascii)
    end
  end

  describe "from: :detect" do
    test "detects Greek and transforms to Latin" do
      {:ok, result} = Unicode.Transform.transform("αβγδ", from: :detect, to: :latin)
      assert result == "abgd"
    end

    test "detects multiple scripts and chains transforms" do
      {:ok, result} = Unicode.Transform.transform("αβγδ мир", from: :detect, to: :latin)
      assert is_binary(result)
      # Greek should be transliterated
      refute String.contains?(result, "α")
      # Cyrillic should be transliterated
      refute String.contains?(result, "м")
    end

    test "works with string :to" do
      {:ok, result} = Unicode.Transform.transform("αβγδ", from: :detect, to: "Latin")
      assert result == "abgd"
    end

    test "returns error when detected script has no transform to target" do
      assert {:error, {:unknown_transform, _}} =
               Unicode.Transform.transform("αβγδ", from: :detect, to: :nonexistent)
    end
  end

  describe "reverse transform ID resolution" do
    test "resolves reverse when forward ID doesn't exist" do
      # Latin-ConjoiningJamo.xml exists with direction="both", so
      # ConjoiningJamo-Latin should resolve as the reverse of Latin-ConjoiningJamo
      {:ok, result} = Unicode.Transform.transform("ᄀ", from: :jamo, to: :latin)
      assert is_binary(result)
    end

    test "resolves forward ID with string options" do
      {:ok, result} = Unicode.Transform.transform("αβγδ", from: "greek", to: "latin")
      assert result == "abgd"
    end

    test "resolves reverse with string options when forward doesn't exist" do
      # "CanadianAboriginal-Latin" is the backward alias of Latin-CanadianAboriginal
      {:ok, result} =
        Unicode.Transform.transform("ᐃ", from: "CanadianAboriginal", to: "Latin")

      assert is_binary(result)
      assert result != "ᐃ"
    end
  end

  describe "parser edge cases" do
    alias Unicode.Transform.Parser
    alias Unicode.Transform.Rule.Conversion

    test "parses rule with after-context on right side (no opening brace)" do
      # e.g., ค ↔ kh } $notHAccent ;
      rules = Parser.parse("a ↔ b } c ;")
      assert [%Conversion{direction: :both, right: right}] = rules
      assert right.text == "b"
      assert right.after_context == "c"
    end
  end
end
