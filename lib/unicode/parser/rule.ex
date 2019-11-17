defmodule Unicode.Transform.Parser.Rule do
  import NimbleParsec
  import Unicode.Transform.Parser.Set
  import Unicode.Transform.Parser.Variable

  def filter_rule do
    ignore(string("::"))
    |> ignore(optional(parsec(:whitespace)))
    |> choice([
      parsec(:unicode_set),
      character_class()
    ])
    |> concat(end_of_rule())
    |> tag(:filter_rule)
    |> label("filter rule")
  end

  def transform_rule do
    ignore(string("::"))
    |> ignore(optional(parsec(:whitespace)))
    |> choice([
      both_transform(),
      forward_transform(),
      inverse_transform()
    ])
    |> concat(end_of_rule())
    |> tag(:transform)
    |> label("transform rule")
  end

  def forward_transform do
    transform_name()
    |> unwrap_and_tag(:forward_transform)
  end

  def inverse_transform do
    ignore(string("("))
    |> ignore(optional(parsec(:whitespace)))
    |> optional(transform_name() |> unwrap_and_tag(:inverse_transform))
    |> ignore(optional(parsec(:whitespace)))
    |> ignore(string(")"))
  end

  def both_transform do
    forward_transform()
    |> ignore(optional(parsec(:whitespace)))
    |> concat(inverse_transform())
  end

  def transform_name do
    times(ascii_char([?a..?z, ?A..?Z, ?-, ?_]), min: 1)
    |> reduce({List, :to_string, []})
  end

  def variable_definition do
    ignore(string("$"))
    |> concat(variable_name())
    |> ignore(optional(parsec(:whitespace)))
    |> ignore(string("="))
    |> ignore(optional(parsec(:whitespace)))
    |> concat(variable_value())
    |> concat(end_of_rule())
    |> tag(:set_variable)
    |> label("variable definition")
    |> post_traverse(:store_variable_in_context)
  end

  def variable_value do
    characters_or_variable_or_class()
    |> repeat(ignore(optional(parsec(:whitespace))) |> concat(characters_or_variable_or_class()))
    |> reduce(:consolidate_string)
    |> tag(:value)
  end

  def end_of_rule do
    ignore(optional(parsec(:whitespace)))
    |> ignore(string(";"))
    |> ignore(optional(parsec(:whitespace)))
    |> ignore(optional(comment()))
    |> label("valid rule")
  end

  def comment do
    string("#")
    |> repeat(utf8_char([{:not, ?\r}, {:not, ?\n}]))
  end

  def characters_or_variable_or_class do
    choice([
      parsec(:unicode_set),
      character_class(),
      parsec(:variable),
      character_string(),
      repeat_or_optional_flags()
    ])
  end

  def end_of_line do
    choice([
      string("\n"),
      string("\r\n")
    ])
    |> repeat()
    |> ignore()
  end

  def trailing_whitespace do
    ascii_char([?\s, ?\t, ?\n, ?\r])
    |> repeat()
    |> label("trailing whitespace")
  end
end
