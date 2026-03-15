defmodule Unicode.Transform.Rule do
  @moduledoc """
  Defines the structs for each type of CLDR transform rule.

  Transform rules are defined by the
  [CLDR specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms)
  and include the following types:

  * `Unicode.Transform.Rule.Comment` — comment lines
  * `Unicode.Transform.Rule.Filter` — global filter rules restricting which characters are affected
  * `Unicode.Transform.Rule.Transform` — transform directives (e.g., `:: NFD ;`)
  * `Unicode.Transform.Rule.Definition` — variable definitions (e.g., `$var = value ;`)
  * `Unicode.Transform.Rule.Conversion` — conversion rules with direction, context, and revisit
  """
end

defmodule Unicode.Transform.Rule.Comment do
  @moduledoc """
  A comment rule. Lines starting with `#` in the transform rule text.
  """

  defstruct [:text]

  @type t :: %__MODULE__{
          text: String.t() | nil
        }
end

defmodule Unicode.Transform.Rule.Filter do
  @moduledoc """
  A filter rule restricts which characters are affected by transform and conversion rules.

  ### Syntax

  A forward filter:
  ```
  :: [[:Latin:][:Common:]] ;
  ```

  An inverse filter:
  ```
  :: ([[:Latin:][:Common:]]) ;
  ```

  See [Filter Rules](https://unicode.org/reports/tr35/tr35-general.html#Filter_Rules).
  """

  defstruct [:unicode_set, :direction]

  @type t :: %__MODULE__{
          unicode_set: String.t(),
          direction: :forward | :inverse
        }
end

defmodule Unicode.Transform.Rule.Transform do
  @moduledoc """
  A transform rule invokes another named transform.

  ### Syntax

  ```
  :: NFD ;           # executed for both forward and inverse
  :: lower () ;      # only executed for forward
  :: (lower) ;       # only executed for inverse
  :: NFD (NFC) ;     # NFD for forward, NFC for inverse
  :: Latin-Greek ;   # invoke another rule-based transform
  ```

  See [Transform Rules](https://unicode.org/reports/tr35/tr35-general.html#Transform_Rules).
  """

  defstruct [:forward, :backward]

  @type t :: %__MODULE__{
          forward: String.t() | nil,
          backward: String.t() | nil
        }
end

defmodule Unicode.Transform.Rule.Definition do
  @moduledoc """
  A variable definition rule.

  ### Syntax

  ```
  $variableName = contents ;
  ```

  Variables are substituted within other variable definitions and conversion rules.

  See [Variable Definition Rules](https://unicode.org/reports/tr35/tr35-general.html#Variable_Definition_Rules).
  """

  defstruct [:variable, :value]

  @type t :: %__MODULE__{
          variable: String.t(),
          value: String.t()
        }
end

defmodule Unicode.Transform.Rule.Conversion do
  @moduledoc """
  A conversion rule maps text from one form to another.

  ### Syntax

  Forward:
  ```
  before_context { text_to_replace } after_context → completed_result | result_to_revisit ;
  ```

  Backward:
  ```
  completed_result | result_to_revisit ← before_context { text_to_replace } after_context ;
  ```

  Dual:
  ```
  a { b | c } d ↔ e { f | g } h ;
  ```

  See [Conversion Rules](https://unicode.org/reports/tr35/tr35-general.html#Conversion_Rules).
  """

  defstruct [:direction, :left, :right]

  @type side :: %{
          before_context: String.t() | nil,
          text: String.t(),
          revisit: String.t() | nil,
          after_context: String.t() | nil
        }

  @type t :: %__MODULE__{
          direction: :forward | :backward | :both,
          left: side(),
          right: side()
        }
end
