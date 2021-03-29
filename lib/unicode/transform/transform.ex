defmodule Unicode.Transform do
  @moduledoc """
  Implements the Unicode transform rules.

  The rules are implemented by the macros
  `filter/1`, `transform/1` and `replace/3`.

  Typically transform modules are generated
  from the CLDR transform specifications using
  `Unicode.Transform.Generator.generate/1`.

  These macros are then transformed to elixir
  code by the functions in this module.

  """

  @doc """
  Transform a string.
  """
  @callback transform(String.t) :: String.t

  @doc """
  Transform a string with a filter
  module provided
  """
  @callback transform(String.t, module()) :: String.t

  defmacro __using__(_) do
    module = __MODULE__

    quote do
      import unquote(module)
      Module.register_attribute(__MODULE__, :filter, accumulate: false)
      Module.register_attribute(__MODULE__, :rules, accumulate: true)
      Module.register_attribute(__MODULE__, :variables, accumulate: true)

      import Unicode.Regex, only: [compile!: 1]
      require Unicode.Set

      @behaviour Unicode.Transform

      @before_compile unquote(module)
    end
  end

  defmacro filter(filter) do
    quote do
      Module.put_attribute(__MODULE__, :filter, unquote(filter))
    end
  end

  defmacro transform(transform) do
    quote do
      Module.put_attribute(__MODULE__, :rules, {:transform, unquote(transform)})
    end
  end

  defmacro replace(from, to, options \\ []) do
    rule = Macro.escape({:replace, from, to, options})

    quote do
      Module.put_attribute(__MODULE__, :rules, unquote(rule))
    end
  end

  defmacro define(var, value) do
    quote do
      Module.put_attribute(__MODULE__, :variables, {:define, unquote(var), unquote(value)})
    end
  end

  defmacro __before_compile__(_env) do
    caller = __CALLER__.module
    filter = Module.get_attribute(caller, :filter)

    variables =
      caller
      |> Module.get_attribute(:variables)
      |> Unicode.Transform.Utils.make_variable_map()

    rules =
      __CALLER__.module
      |> Module.get_attribute(:rules)
      |> Enum.reverse()
      |> group_rules()

    [
      generate_guard(filter),
      filter_function(filter),
      generate_transform(rules, caller),
      generate_conversions(rules, filter)
    ]
  end

  # Guard clause which represents the
  # filter rule

  defp generate_guard(nil) do
    quote do
      defguard iff(codepoint) when is_integer(codepoint)
    end
  end

  defp generate_guard(filter) do
    quote do
      defguardp iff(codepoint) when Unicode.Set.match?(codepoint, unquote(filter))
    end
  end

  # Generates a function for the filter
  # rule that can be called by other
  # transforms since the filter rule
  # is considered global and therefore
  # when a transform rule is invoked it
  # needs to conform to this filter too.

  def filter_function(nil) do
    quote do
      def filter?(_) do
        true
      end
    end
  end

  def filter_function(filter) do
    {filter, _} = Code.eval_quoted(filter)

    quote do
      def filter?(char) do
        Unicode.Set.match?(char, unquote(filter))
      end
    end
  end

  # Generate the functions which implement the
  # conversion rules

  defp generate_conversions(rules, filter) do
    rules
    |> Enum.filter(&is_list/1)
    |> Enum.reduce({0, []}, &generate_conversion(&1, &2, filter))
    |> elem(1)
    |> Enum.reverse
  end

  # Generate the transform/1 function
  # that is the single public API

  defp generate_transform(rules, caller) do
    pipeline = generate_pipeline(rules, caller)
    [from, to] = extract_from_to(caller)

    quote do
      @doc """
      Transforms a string from #{inspect unquote(from)} to #{inspect unquote(to)}
      """
      @spec transform(String.t) :: String.t

      def transform(string) do
        unquote(pipeline)
      end

      @doc false
      def transform(string, _filter) do
        unquote(pipeline)
      end
    end
  end

  defp extract_from_to(caller) do
    caller
    |> Module.split
    |> List.last
    |> Macro.underscore
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
  end

  # Generate the pipeline that executes
  # the transform rules and the conversion rules
  # in the correct order

  defp generate_pipeline(rules, caller) do
    rules
    |> Enum.reduce({0, []}, &generate_function_call(&1, &2, caller))
    |> elem(1)
    |> Enum.reverse()
    |> List.insert_at(0, quote do string end)
    |> Enum.reduce(&Macro.pipe(&2, &1, 0))
  end

  # Generate the function calls used in the pipeline

  def generate_function_call({:transform, name}, {counter, acc}, caller) do
    funcall =
      quote do
        unquote(filter_module(name)).transform(unquote(caller))
      end

    {counter, [funcall | acc]}
  end

  def generate_function_call(_rule_group, {counter, acc}, _caller) do
    counter = counter + 1
    function_name = :"replace_#{counter}"

    funcall =
      quote do
        unquote(function_name)()
      end

    {counter, [funcall | acc]}
  end

  # Generate the functions that do the conversions

  defp generate_conversion(conversions, {counter, acc}, _filter) when is_list(conversions) do
    counter = counter + 1
    function_name = :"replace_#{counter}"

    conversion_clauses =
      conversions
      |> Enum.map(&generate_replace_clause(&1, function_name))
      |> List.flatten

    final_clause =
      quote do
        <<char::utf8>> <> rest -> <<char::utf8>> <> unquote(function_name)(rest)
      end

    conversion_function =
      quote do
        defp unquote(function_name)(<<char::utf8, rest::binary>>) when iff(char) do
          case <<char::utf8, rest::binary>> do
            unquote(conversion_clauses ++ final_clause)
          end
        end
      end

    no_conversion_function =
      quote do
        defp unquote(function_name)(<<char::utf8, rest::binary>>) do
          <<char::utf8>> <> unquote(function_name)(rest)
        end
      end

    empty_function =
      quote do
        defp unquote(function_name)("") do
          ""
        end
      end

    {counter, [empty_function, no_conversion_function, conversion_function | acc]}
  end

  # Generate the case clauses, one for each conversion rule

  defp generate_replace_clause({:replace, from, to, []}, function_name) do
    quote do
      unquote(from) <> rest -> unquote(to) <> unquote(function_name)(rest)
    end
  end

  defp generate_replace_clause({:replace, from, to, options}, function_name) do
    preceeded_by = Keyword.get(options, :preceeded_by)

    quote do
      <<char::utf8, rest::binary>> when Unicode.Set.match?(char, unquote(preceeded_by))->
        replaced = String.replace(rest, compile!(unquote(from)), unquote(to))
        <<char::utf8>> <> unquote(function_name)(replaced)
    end
  end

  # Groups clusters of conversion rules together so
  # that we can identify the breaks between transform
  # rules and conversion rules.

  # The return is a list of two entry types:
  # 1. A transform tuple {:transform, transform_name}
  # 2. Or a list of conversion tuples {:replace, ....}

  # The grouping reflects the final pipleine that will
  # be generated in which we execute transforms (which process
  # the whole string) and replacements (which process each
  # the string iteratively).

  # For example:
  # [
  #   {:transform, "NFD"},
  #   [
  #     {:replace, "[:Mn:]+", "", [preceeded_by: "[[:Latin:][0-9]]"]}
  #   ],
  #   {:transform, "NFC"},
  #   [
  #     {:replace, "Æ", "AE", []},
  #     {:replace, "Ð", "D", []},
  #     ....
  #   ]
  # ]

  defp group_rules([]) do
    []
  end

  defp group_rules([{:transform, _} = t1 | rest]) do
   [t1 | group_rules(rest)]
  end

  defp group_rules([group, {:replace, _, _, _} = r1 | rest]) when is_list(group) do
    group_rules([[r1 | group] | rest])
  end

  defp group_rules([{:replace, _, _, _} = r1, {:replace, _, _, _} = r2 | rest]) do
    group_rules([[r2, r1] | rest])
  end

  defp group_rules([group, {:transform, _} = t1 | rest]) when is_list(group) do
    [Enum.reverse(group), t1 | group_rules(rest)]
  end

  defp group_rules([{:replace, _, _, _} = r1, {:transform, _} = t2 | rest]) do
    [[r1] | group_rules([t2 | rest])]
  end

  defp group_rules([group]) when is_list(group) do
    [Enum.reverse(group)]
  end

  # Derive the name of the module from the filter
  # Doesn't yet handle complex names

  defp filter_module(name) do
    Module.concat(__MODULE__, filter_module_name(name))
  end

  defp filter_module_name(name) do
    name
    |> String.downcase
    |> String.split("-")
    |> case do
        [from] -> "Any" <> String.capitalize(from)
        [from, to] -> String.capitalize(from) <> String.capitalize(to)
      end
  end
end
