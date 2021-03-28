defmodule Example do
  import Kernel, except: [match?: 2]
  import Unicode.Set, only: [match?: 2]
  import Unicode.Regex, only: [compile!: 1]

  # Define the global filter
  defguard filter(codepoint) when match?(codepoint, "[[:Latin:][:Common:][:Inherited:][〇]]")

  # Use this as the default filter
  defguard filter2(codepoint) when is_integer(codepoint)

  # With :preceeded_by which we turn into a guard
  def replace_1(<<char::utf8>> <> rest) when filter(char) do
    case <<char::utf8, rest::binary>> do
      <<char::utf8, rest::binary>> when match?(char, "[[:Latin:][0-9]]") ->
        replaced = String.replace(rest, compile!("[:Mn:]+"), "")
        <<char::utf8>> <> replace_1(replaced)

      <<char::utf8, rest::binary>> ->
        <<char::utf8>> <> replace_2(rest)
    end
  end

  def replace_1(""), do: ""

  # Handling a "block" of replacements
  def replace_2(<<char::utf8, rest::binary>>) when filter(char) do
    case <<char::utf8, rest::binary>> do
      "Æ" <> rest -> "AE" <> replace_2(rest)
      "Ð" <> rest -> "D" <> replace_2(rest)
      <<char::utf8>> <> rest -> <<char::utf8>> <> replace_2(rest)
    end
  end

  def replace_2(""), do: ""

  def transform(string) do
    string
    |> Unicode.Transform.AnyNfd.transform()
    |> replace_1()
    |> Unicode.Transform.AnyNfc.transform()
    |> replace_2()
  end
end
