defmodule Unicode.Transform.Utils do
  import SweetXml

  def file(transform_file) do
    transform_file
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//transform",
      source: ~x"./@source"s,
      target: ~x"./@target"s,
      direction: ~x"./@direction"s,
      alias: ~x"./@alias"s,
      rules: ~x"./tRule/text()"s
    )
  end

  @doc false
  def unescape_string("") do
    ""
  end

  def unescape_string("\\\\" <> rest) do
    "\\" <> unescape_string(rest)
  end

  def unescape_string("\\" <> rest) do
    unescape_string(rest)
  end

  def unescape_string(<<char::utf8>> <> rest) do
    <<char::utf8>> <> unescape_string(rest)
  end

  @doc false
  def atomize_keys(rule) do
    Enum.map(rule, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc false
  def make_variable_map(variables) do
    variables
    |> Enum.map(fn {:define, var, value} -> {var, value} end)
    |> Map.new
  end
end
