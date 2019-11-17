defmodule Unicode.Transform.Utils do
  @doc """
  Converts a list of codepoint ranges (represented
  as a 2-tuple) into a list of character ranges
  suitable for use with the `NimbleParsec.utf8_char/1`
  combinator

  """
  def ranges_to_combinator_utf8_list([{first, first}]) do
    quote do
      [first]
    end
  end

  def ranges_to_combinator_utf8_list([{first, last}]) do
    quote do
      [unquote(first)..unquote(last)]
    end
  end

  def ranges_to_combinator_utf8_list([{first, first} | rest]) do
    quote do
      [unquote(first) | unquote(ranges_to_combinator_utf8_list(rest))]
    end
  end

  def ranges_to_combinator_utf8_list([{first, last} | rest]) do
    quote do
      [unquote(first)..unquote(last) | unquote(ranges_to_combinator_utf8_list(rest))]
    end
  end

  def duplicate_and_capitalize(list) do
    new_list = Enum.map(list, &String.capitalize/1)
    new_list ++ list
  end

end
