defmodule Unicode.Transform.Parser.Variable do
  import NimbleParsec
  alias Unicode.Transform.Utils

  # Characters that are valid to start
  # an identifier
  id_start =
    Unicode.Property.properties()
    |> Map.get(:id_start)
    |> Utils.ranges_to_combinator_utf8_list()

  # Characters that are valid for
  # an identifier after the first
  # character
  id_continue =
    Unicode.Property.properties()
    |> Map.get(:id_continue)
    |> Utils.ranges_to_combinator_utf8_list()

  def variable_name do
    utf8_char(unquote(id_start))
    |> repeat(utf8_char(unquote(id_continue)))
    |> reduce(:to_string)
    |> unwrap_and_tag(:variable_name)
    |> label("variable name")
  end
end
