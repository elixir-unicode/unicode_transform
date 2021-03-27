defmodule Unicode.Transform.Rule.Filter do
  @moduledoc """
  #### 10.3.8 <a name="Filter_Rules" href="#Filter_Rules">Filter Rules</a>

  A filter rule consists of two colons followed by a UnicodeSet. This filter is global in that only the characters matching the filter will be affected by any transform rules or conversion rules. The inverse filter rule consists of two colons followed by a UnicodeSet in parentheses. This filter is also global for the inverse transform.

  For example, the Hiragana-Latin transform can be implemented by "pivoting" through the Katakana converter, as follows:

  ```
  :: [:^Katakana:] ; # do not touch any katakana that was in the text!
  :: Hiragana-Katakana;
  :: Katakana-Latin;
  :: ([:^Katakana:]) ; # do not touch any katakana that was in the text
                       # for the inverse either!
  ```

  The filters keep the transform from mistakenly converting any of the "pivot" characters. Note that this is a case where a rule list contains no conversion rules at all, just transform rules and filters.
  """

  defstruct [:unicode_set, :comment]

  alias Unicode.Transform.Rule.Comment

  @regex ~r/(?<unicode_set>[^;]*)\s*;(\#\s*(?<comment>.*))?/u

  def parse(<<"::[">> <> unicode_set) do
    parsed = Regex.named_captures(@regex, unicode_set)

    rule =
      %{parsed | "unicode_set" => "[" <> String.trim(parsed["unicode_set"])}
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    struct(__MODULE__, rule)
  end

  def parse(<<":: [">> <> unicode_set) do
    parse("::[" <> unicode_set)
  end

  def parse(_other) do
    nil
  end

  defimpl Unicode.Transform.Rule do
    def to_forward_code(rule) do
      [Comment.comment_from(rule), "filter(", inspect(rule.unicode_set), ")", "\n"]
    end

    def to_backward_code(rule) do
      [Comment.comment_from(rule), "filter(", inspect(rule.unicode_set), ")", "\n"]
    end
  end
end
