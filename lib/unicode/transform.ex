defmodule Unicode.Transform do
  @moduledoc """
  Implements the Unicode transform rules.

  """
  import NimbleParsec
  import Unicode.Transform.Combinators
  import Unicode.Transform.Parser.Reducers

  defparsec(
    :parse_rule,
    choice([
      filter_rule(),
      transform_rule(),
      variable_definition(),
      comment(),
      end_of_rule()
    ])
  )

  defparsec(
    :parse,
    ignore(optional(trailing_whitespace()))
    |> parsec(:parse_rule)
    |> repeat(end_of_line() |> ignore(optional(parsec(:whitespace))) |> parsec(:parse_rule))
    |> ignore(optional(trailing_whitespace()))
  )

  defparsec(
    :whitespace,
    ascii_char([?\s, ?\t])
    |> repeat()
    |> label("whitespace")
  )

  defparsec(
    :variable,
    ignore(string("$"))
    |> concat(variable_name())
    |> post_traverse(:insert_variable)
  )

  # need to recuse on the character set for nested sets
  # add optional clause for character_class or unicode_set
  defparsec(:unicode_set,
    ignore(string("["))
    |> optional(ascii_char([?^]))
    |> concat(character_class())
    |> repeat(optional(set_operator()) |> ignore(optional(parsec(:whitespace))) |> concat(character_class()))
    |> ignore(string("]"))
    |> reduce(:postfix_set_operations)
    |> label("unicode set"))

end
