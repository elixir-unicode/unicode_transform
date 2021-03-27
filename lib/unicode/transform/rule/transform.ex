defmodule Unicode.Transform.Rule.Transform do
  @moduledoc """
  #### 10.3.6 <a name="Transform_Rules" href="#Transform_Rules">Transform Rules</a>

  Each transform rule consists of two colons followed by a transform name, which is of the form source-target. For example:

  ```
  :: NFD ;
  :: und_Latn-und_Greek ;
  :: Latin-Greek; # alternate form
  ```

  If either the source or target is 'und', it can be omitted, thus 'und_NFC' is equivalent to 'NFC'. For compatibility, the English names for scripts can be used instead of the und_Latn locale name, and "Any" can be used instead of "und". Case is not significant.

  The following transforms are defined not by rules, but by the operations in the Unicode Standard, and may be used in building any other transform:

  > **Any-NFC, Any-NFD, Any-NFKD, Any-NFKC** - the normalization forms defined by [[UAX15](https://www.unicode.org/reports/tr41/#UAX15)].
  >
  > **Any-Lower, Any-Upper, Any-Title** - full case transformations, defined by [[Unicode](tr35.md#Unicode)] Chapter 3.

  In addition, the following special cases are defined:

  > **Any-Null** - has no effect; that is, each character is left alone.
  > **Any-Remove** - maps each character to the empty string; this, removes each character.

  The inverse of a transform rule uses parentheses to indicate what should be done when the inverse transform is used. For example:

  ```
  :: lower () ; # only executed for the normal
  :: (lower) ; # only executed for the inverse
  :: lower ; # executed for both the normal and the inverse
  ```

  """

  defstruct [:forward, :backward, :comment]

  alias Unicode.Transform.Rule.Comment

  @transform "[A-Za-z_-]"
  @regex ~r/(?<forward>#{@transform}*)?\s*(\((?<backward>#{@transform}*)\))?\s*;\s*(\#\s*(?<comment>.*))?/u

  def parse(<< "::" >> <> rule) do
    rule =
      Regex.named_captures(@regex, String.trim(rule))
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    struct(__MODULE__, rule)
  end

  def parse(_other) do
    nil
  end

  defimpl Unicode.Transform.Rule do
    def to_forward_code(%{forward: ""} = _rule) do
      []
    end

    def to_forward_code(rule) do
      [Comment.comment_from(rule), "transform(", inspect(rule.forward), ")", "\n"]
    end

    def to_backward_code(%{backward: ""} = _rule) do
      []
    end

    def to_backward_code(rule) do
      [Comment.comment_from(rule), "transform(", inspect(rule.backward), ")", "\n"]
    end
  end
end