defmodule Unicode.Transform.Rule.Definition do
  @moduledoc """
  #### 10.3.7 [Variable Definition Rules](https://unicode.org/reports/tr35/tr35-general.html#Variable_Definition_Rules)

  Each variable definition is of the following form:

  ```
  $variableName = contents ;
  ```

  The variable name can contain letters and digits, but must start with a letter. More precisely, the variable names use Unicode identifiers as defined by [[UAX31](https://www.unicode.org/reports/tr41/#UAX31)]. The identifier properties allow for the use of foreign letters and numbers.

  The contents of a variable definition is any sequence of Unicode sets and characters or characters. For example:

  ```
  $mac = M [aA] [cC] ;
  ```

  Variables are only replaced within other variable definition rules and within conversion rules. They have no effect on transliteration rules.

  """
  defstruct [:variable, :value, :comment]

  alias Unicode.Transform.Rule.Comment

  @regex ~r/(?<variable>[a-zA-Z][a-zA-Z0-9]*)\s*=\s*(?<value>[^;]*)\s*;(\#\s*(?<comment>.*))?/u

  def parse(<<"$">> <> rule) do
    parsed = Regex.named_captures(@regex, rule)
    rule = %{parsed | "value" => String.trim(parsed["value"])}
    struct(__MODULE__, rule)
  end

  def parse(_other) do
    nil
  end

  defimpl Unicode.Transform.Rule do
    def to_forward_code(rule) do
      [
        Comment.comment_from(rule),
        "define(",
        inspect(rule.variable),
        ", ",
        inspect(rule.value),
        "\n"
      ]
    end

    def to_backward_code(rule) do
      [
        Comment.comment_from(rule),
        "define(",
        inspect(rule.variable),
        ", ",
        inspect(rule.value),
        "\n"
      ]
    end
  end
end
