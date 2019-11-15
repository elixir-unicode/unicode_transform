defmodule Unicode.Transform do
  @moduledoc """
  Implements the Unicode transform rules.

  """
  import NimbleParsec
  import Unicode.Transform.Combinators

  defparsec(:rule, choice([filter_rule(), transform_rule(), variable_definition()]))
end
