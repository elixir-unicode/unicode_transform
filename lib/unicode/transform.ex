defmodule Unicode.Transform do
  @moduledoc """
  Implements the CLDR transliteration rules.

  """
  import NimbleParsec
  import Unicode.Transform.Combinators

  defparsec(:filter, filter_rule())
  defparsec(:transform, transform_rule())
  defparsec(:rule, choice([filter_rule(), transform_rule(), variable_definition()]))
end
