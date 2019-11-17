defmodule Unicode.Transform do
  @moduledoc """
  Implements the Unicode transform rules.

  """
  import NimbleParsec
  import Unicode.Transform.Combinators
  import Unicode.Transform.Parser.Reducers

  defparsec(:parse_rule,
    choice([
      filter_rule(),
      transform_rule(),
      variable_definition(),
      end_of_rule()
    ]))

  defparsec(:parse,
    parsec(:parse_rule)
    |> repeat(end_of_line() |> parsec(:parse_rule))
    |> ignore(optional(trailing_whitespace())))
end
