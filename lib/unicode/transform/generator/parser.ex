defmodule Unicode.Transform.Parser do
  @moduledoc """

  """
  alias Unicode.Transform.Rule.{Comment, Filter, Transform, Conversion, Definition}
  alias Unicode.Transform.Utils

  def parse_file(filename) do
    %{rules: rules} = Utils.file(filename)
    parse(rules)
  end

  def parse(string) do
    string
    |> String.split("\n")
    |> Enum.reject(&Regex.match?(~r/^\s*$/u, &1))
    |> Enum.map(&parse_rule/1)
  end

  def parse_rule(string) do
    # IO.inspect string, label: "Parse"

    Definition.parse(string) ||
      Comment.parse(string) ||
      Filter.parse(string) ||
      Transform.parse(string) ||
      Conversion.parse(string) ||

      raise ArgumentError, "Unknown rule #{inspect(string)}"
  end
end
