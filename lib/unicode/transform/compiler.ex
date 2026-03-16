defmodule Unicode.Transform.Compiler do
  @moduledoc """
  Compiles parsed transform rules into an executable form.

  The compiler takes a list of parsed rule structs and a direction,
  and produces a `CompiledTransform` that can be executed by the engine.

  Compilation involves:

  * Filtering rules by direction (forward vs inverse).

  * Resolving variable definitions.

  * Grouping conversion rules into passes (split by transform rules).

  * Compiling patterns for efficient matching.

  """

  alias Unicode.Transform.Rule.{Conversion, Definition, Filter, Transform}
  alias Unicode.Transform.Builtin

  defmodule CompiledTransform do
    @moduledoc false
    defstruct [:passes, :filter, :inverse_filter]

    @type t :: %__MODULE__{
            passes: [pass()],
            filter: compiled_filter() | nil,
            inverse_filter: compiled_filter() | nil
          }

    @type pass ::
            {:conversions, [compiled_rule()]}
            | {:transform, String.t()}
            | {:builtin, String.t()}

    @type compiled_rule :: %{
            before_context: compiled_pattern() | nil,
            pattern: compiled_pattern(),
            replacement: String.t(),
            revisit: String.t() | nil,
            after_context: compiled_pattern() | nil
          }

    @type compiled_pattern :: String.t() | {:unicode_set, String.t()} | {:regex, Regex.t()}
    @type compiled_filter :: {:unicode_set, String.t()} | {:regex, Regex.t()}
  end

  @doc """
  Compiles a list of parsed rules into an executable form.

  ### Arguments

  * `rules` — list of parsed rule structs.

  * `direction` — `:forward` or `:reverse`.

  * `resolve_transform` — function to resolve transform names.

  ### Returns

  A `CompiledTransform` struct.

  """
  @spec compile([struct()], :forward | :reverse, function()) :: CompiledTransform.t()
  def compile(rules, direction, resolve_transform \\ fn _, _ -> nil end) do
    variables = collect_variables(rules)
    filter = extract_filter(rules, direction)
    inverse_filter = extract_filter(rules, invert_direction(direction))

    passes =
      rules
      |> filter_by_direction(direction)
      |> resolve_variables(variables)
      |> group_into_passes()
      |> maybe_reverse_passes(direction)
      |> compile_passes(resolve_transform, direction)

    %CompiledTransform{
      passes: passes,
      filter: compile_filter(filter),
      inverse_filter: compile_filter(inverse_filter)
    }
  end

  @doc """
  Compiles a built-in transform.

  ### Arguments

  * `name` — the built-in transform name.

  * `direction` — `:forward` or `:reverse`.

  ### Returns

  A `CompiledTransform` struct with a single builtin pass.

  """
  @spec compile_builtin(String.t(), :forward | :reverse) :: CompiledTransform.t()
  def compile_builtin(name, direction) do
    effective_name =
      case direction do
        :forward -> name
        :reverse -> Builtin.inverse(name) || name
      end

    %CompiledTransform{
      passes: [{:builtin, effective_name}],
      filter: nil,
      inverse_filter: nil
    }
  end

  # Collect all variable definitions into a map
  defp collect_variables(rules) do
    rules
    |> Enum.filter(&match?(%Definition{}, &1))
    |> Enum.reduce(%{}, fn %Definition{variable: var, value: val}, acc ->
      # Variables can reference earlier variables
      resolved_val = substitute_variables(val, acc)
      Map.put(acc, var, resolved_val)
    end)
  end

  # Extract the filter for the given direction
  defp extract_filter(rules, :forward) do
    Enum.find_value(rules, fn
      %Filter{direction: :forward, unicode_set: set} -> set
      _ -> nil
    end)
  end

  defp extract_filter(rules, :reverse) do
    Enum.find_value(rules, fn
      %Filter{direction: :inverse, unicode_set: set} -> set
      _ -> nil
    end)
  end

  # Filter rules to only those relevant for the given direction
  defp filter_by_direction(rules, direction) do
    Enum.flat_map(rules, fn rule ->
      case rule do
        %Conversion{direction: :forward} when direction == :forward -> [rule]
        %Conversion{direction: :forward} when direction == :reverse -> []
        %Conversion{direction: :backward} when direction == :reverse -> [invert_conversion(rule)]
        %Conversion{direction: :backward} when direction == :forward -> []
        %Conversion{direction: :both} when direction == :forward -> [forward_from_dual(rule)]
        %Conversion{direction: :both} when direction == :reverse -> [backward_from_dual(rule)]
        %Transform{} -> [select_transform_direction(rule, direction)]
        %Filter{} -> []
        %Definition{} -> []
        _ -> []
      end
      |> Enum.reject(&is_nil/1)
    end)
  end

  # For a dual rule in forward direction:
  # a { b | c } d ↔ e { f | g } h
  # becomes: a { b c } d → f | g
  defp forward_from_dual(%Conversion{left: left, right: right}) do
    # Left side: combine text and revisit into text, ignore revisit
    left_text =
      [left.text, left.revisit]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("")

    # Right side: text is replacement, revisit is revisit
    %Conversion{
      direction: :forward,
      left: %{left | text: left_text, revisit: nil},
      right: %{
        before_context: nil,
        text: right.text || "",
        revisit: right.revisit,
        after_context: nil
      }
    }
  end

  # For a dual rule in reverse direction:
  # a { b | c } d ↔ e { f | g } h
  # becomes: b | c ← e { f g } h
  defp backward_from_dual(%Conversion{left: left, right: right}) do
    # Right side becomes the source pattern
    right_text =
      [right.text, right.revisit]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("")

    %Conversion{
      direction: :forward,
      left: %{right | text: right_text, revisit: nil},
      right: %{
        before_context: nil,
        text: left.text || "",
        revisit: left.revisit,
        after_context: nil
      }
    }
  end

  # For backward rules, swap left and right
  defp invert_conversion(%Conversion{} = rule) do
    %Conversion{
      direction: :forward,
      left: rule.left,
      right: rule.right
    }
  end

  # Select the transform for the given direction
  defp select_transform_direction(%Transform{forward: fwd, backward: _bwd}, :forward) do
    if fwd, do: %Transform{forward: fwd, backward: nil}, else: nil
  end

  defp select_transform_direction(%Transform{forward: fwd, backward: bwd}, :reverse) do
    name = bwd || fwd

    if name do
      inverted = invert_transform_name(name)
      %Transform{forward: inverted, backward: nil}
    else
      nil
    end
  end

  # Invert a transform name: "Latin-Greek" -> "Greek-Latin"
  defp invert_transform_name(name) do
    case Builtin.inverse(name) do
      nil ->
        case String.split(name, "-", parts: 2) do
          [source, target] -> "#{target}-#{source}"
          _ -> name
        end

      inverse ->
        inverse
    end
  end

  # Substitute variable references in a string.
  # Spaces adjacent to variable references are syntactic separators
  # in the CLDR rule format, not literal characters.
  defp substitute_variables(text, variables) when is_binary(text) do
    Regex.replace(~r/\s*\$([a-zA-Z_][a-zA-Z0-9_]*)\s*/, text, fn _match, var_name ->
      Map.get(variables, var_name, "$" <> var_name)
    end)
  end

  defp substitute_variables(nil, _variables), do: nil

  # Resolve variables in conversion rules
  defp resolve_variables(rules, variables) do
    Enum.map(rules, fn
      %Conversion{left: left, right: right} = rule ->
        %{
          rule
          | left: resolve_side_variables(left, variables),
            right: resolve_side_variables(right, variables)
        }

      other ->
        other
    end)
  end

  defp resolve_side_variables(side, variables) when is_map(side) do
    %{
      before_context: substitute_variables(side.before_context, variables),
      text: substitute_variables(side.text, variables),
      revisit: substitute_variables(side.revisit, variables),
      after_context: substitute_variables(side.after_context, variables)
    }
  end

  # Group rules into passes, splitting at transform rules
  defp group_into_passes(rules) do
    rules
    |> Enum.reduce([[]], fn
      %Transform{} = t, acc ->
        [[], t | acc]

      %Conversion{} = c, [current | rest] ->
        [[c | current] | rest]

      _, acc ->
        acc
    end)
    |> Enum.map(fn
      %Transform{} = t -> t
      conversions when is_list(conversions) -> Enum.reverse(conversions)
    end)
    |> Enum.reverse()
    |> Enum.reject(fn
      [] -> true
      _ -> false
    end)
  end

  # For reverse direction, reverse the order of passes.
  # Case transforms (Upper, Lower, Title) are treated as output normalization:
  # they stay at the end of the pass list rather than being moved to the front.
  # Without this, a reversed chain with ::lower becomes ::Upper at the start,
  # uppercasing input before case-sensitive conversion rules can match.
  defp maybe_reverse_passes(passes, :reverse) do
    reversed = Enum.reverse(passes)

    {case_transforms, rest} =
      Enum.split_while(reversed, fn
        %Transform{forward: name} when name != nil ->
          Builtin.case_transform?(name)

        _ ->
          false
      end)

    rest ++ case_transforms
  end

  defp maybe_reverse_passes(passes, :forward), do: passes

  # Compile passes into executable form
  defp compile_passes(passes, _resolve_transform, _direction) do
    Enum.map(passes, fn
      %Transform{forward: name} ->
        if Builtin.builtin?(name) do
          {:builtin, name}
        else
          {:transform, name}
        end

      conversions when is_list(conversions) ->
        compiled = Enum.map(conversions, &compile_conversion/1)
        {:conversions, compiled}
    end)
  end

  # Compile a single conversion rule into a matcher
  defp compile_conversion(%Conversion{left: left, right: right}) do
    %{
      before_context: compile_pattern(left.before_context),
      pattern: compile_pattern(left.text),
      replacement: unescape_replacement(right.text || ""),
      revisit: unescape_replacement(right.revisit),
      after_context: compile_pattern(left.after_context)
    }
  end

  # Compile a pattern string into a form the engine can match
  defp compile_pattern(nil), do: nil
  defp compile_pattern(""), do: nil

  defp compile_pattern(pattern) do
    pattern = String.trim(pattern)

    if pattern == "" do
      nil
    else
      # Return pattern as-is; engine handles matching
      pattern
    end
  end

  defp compile_filter(nil), do: nil
  defp compile_filter(unicode_set), do: unicode_set

  defp unescape_replacement(nil), do: nil

  defp unescape_replacement(text) do
    text
    |> unescape_string()
  end

  # Unescape common escape sequences in rule text
  defp unescape_string(""), do: ""

  defp unescape_string(<<"\\u", hex::binary-4, rest::binary>>) do
    codepoint = String.to_integer(hex, 16)
    <<codepoint::utf8>> <> unescape_string(rest)
  end

  defp unescape_string(<<"\\U", hex::binary-8, rest::binary>>) do
    codepoint = String.to_integer(hex, 16)
    <<codepoint::utf8>> <> unescape_string(rest)
  end

  defp unescape_string(<<"\\", char::utf8, rest::binary>>) do
    <<char::utf8>> <> unescape_string(rest)
  end

  defp unescape_string(<<"'", rest::binary>>) do
    {quoted, remainder} = extract_quoted(rest)
    quoted <> unescape_string(remainder)
  end

  # Unquoted spaces in CLDR replacement text are syntactic separators,
  # not literal characters. Literal spaces use '\ ' or "' '".
  defp unescape_string(<<" ", rest::binary>>) do
    unescape_string(rest)
  end

  defp unescape_string(<<char::utf8, rest::binary>>) do
    <<char::utf8>> <> unescape_string(rest)
  end

  defp extract_quoted(string, acc \\ "")
  defp extract_quoted("", acc), do: {acc, ""}

  defp extract_quoted(<<"'", rest::binary>>, acc) do
    {acc, rest}
  end

  defp extract_quoted(<<char::utf8, rest::binary>>, acc) do
    extract_quoted(rest, acc <> <<char::utf8>>)
  end

  defp invert_direction(:forward), do: :reverse
  defp invert_direction(:reverse), do: :forward
end
