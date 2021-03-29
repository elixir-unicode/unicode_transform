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
    |> Map.new()
  end

  @doc false
  def extract_character_class(string, level \\ 0)

  def extract_character_class("" = string, _level) do
    {string, ""}
  end

  def extract_character_class(<<"\\[", rest::binary>>, level) do
    {string, rest} = extract_character_class(rest, level)
    {"\\[" <> string, rest}
  end

  def extract_character_class(<<"\\]", rest::binary>>, level) do
    {string, rest} = extract_character_class(rest, level)
    {"\\]" <> string, rest}
  end

  def extract_character_class(<<"[", rest::binary>>, level) do
    {string, rest} = extract_character_class(rest, level + 1)
    {"[" <> string, rest}
  end

  def extract_character_class(<<"]", rest::binary>>, 1) do
    {"]", rest}
  end

  def extract_character_class(<<"]", rest::binary>>, level) do
    {string, rest} = extract_character_class(rest, level - 1)
    {"]" <> string, rest}
  end

  def extract_character_class(<<char::binary-1, rest::binary>>, level) do
    {string, rest} = extract_character_class(rest, level)
    {char <> string, rest}
  end
end
