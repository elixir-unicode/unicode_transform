defmodule Unicode.Transform.Parser.Set do
  import NimbleParsec
  import Unicode.Transform.Parser.Character
  alias Unicode.Transform.Utils

  # Known script names in Unicode
  script_names =
    Unicode.Script.scripts()
    |> Map.keys()
    |> Enum.map(&String.replace(&1, "_", " "))
    |> Enum.map(&String.downcase/1)
    |> Utils.duplicate_and_capitalize
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn script ->
      quote do
        string(unquote(script))
      end
    end)

  # Known block names in Unicode
  block_names =
    Unicode.Block.blocks()
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
    |> Enum.map(&String.replace(&1, "_", " "))
    |> Enum.map(&String.upcase/1)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn block ->
      quote do
        string(unquote(block))
      end
    end)

  # Known block names in Unicode
  category_names =
    Unicode.Category.categories()
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn category ->
      quote do
        string(unquote(category))
      end
    end)

  def script do
    ignore(string(":"))
    |> ignore(optional(string("script=")))
    |> concat(script_name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:script)
    |> label("unicode script")
  end

  def block do
    ignore(string(":"))
    |> ignore(string("block="))
    |> choice(unquote(block_names))
    |> ignore(string(":"))
    |> reduce(:to_lower_atom)
    |> unwrap_and_tag(:block)
    |> label("unicode block name")
  end

  def category do
    ignore(string(":"))
    |> concat(category_name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:category)
    |> label("unicode category")
  end

  def canonical_combining_class do
    ignore(string(":"))
    |> ignore(string("ccc="))
    |> concat(combining_class_name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:combining_class)
    |> label("canonical combining class")
  end

  def set_operator do
    ignore(optional(parsec(:whitespace)))
    |> choice([
      ascii_char([?-]) |> tag(:difference),
      ascii_char([?&]) |> tag(:intersection)
    ])
    |> ignore(optional(parsec(:whitespace)))
  end

  def combining_class_name do
    times(ascii_char([?a..?z, ?A..?Z]), min: 1)
    |> label("name")
  end

  def script_name do
    choice([parsec(:variable) | unquote(script_names)])
    |> reduce(:to_lower_atom)
  end

  def category_name do
    choice([parsec(:variable) | unquote(category_names)])
    |> reduce(:to_atom)
  end

  def block_name do
    choice([parsec(:variable) | unquote(block_names)])
    |> reduce(:to_atom)
  end

  def unicode_set_or_character_class do
    choice([
      parsec(:unicode_set),
      character_class()
      ])
  end

  def character_class do
    ignore(string("["))
    |> ignore(optional(parsec(:whitespace)))
    |> optional(ascii_char([?^]))
    |> choice([
      parsec(:unicode_set),
      block(),
      canonical_combining_class(),
      script(),
      category(),
      parsec(:variable),
      class_characters()
    ])
    |> ignore(string("]"))
    |> reduce(:maybe_not)
    |> label("character class")
  end

  def character_string do
    choice([
      parsec(:variable),
      one_character()
    ])
    |> times(min: 1)
    |> reduce(:consolidate_string)
  end

  def character_strings do
    character_string()
    |> repeat(ignore(optional(parsec(:whitespace))) |> concat(character_string()))
    |> reduce(:consolidate_string)
  end

  def repeat_or_optional_flags do
    choice([
      ascii_char([?*]) |> replace(:repeat_star),
      ascii_char([?+]) |> replace(:repeat_plus),
      ascii_char([??]) |> replace(:optional)
    ])
  end
end