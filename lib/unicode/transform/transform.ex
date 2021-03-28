defmodule Unicode.Transform do
  @moduledoc """
  Implements the Unicode transform rules.

  """

  defmacro __using__(_) do
    module = __MODULE__

    quote do
      import unquote(module)
      Module.register_attribute(__MODULE__, :filter, accumulate: false)
      Module.register_attribute(__MODULE__, :rules, accumulate: true)

      import Unicode.Regex, only: [compile!: 1]
      require Unicode.Set

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

  defmacro __before_compile__(_env) do
    filter = Module.get_attribute(__CALLER__.module, :filter)

    guard =
      if filter do
        quote do
          defguard iff(codepoint) when Unicode.Set.match?(codepoint, unquote(filter))
        end
      else
        quote do
          defguard iff(codepoint) when is_integer(codepoint)
        end
      end

    {_counter, functions} =
      __CALLER__.module
      |> Module.get_attribute(:rules)
      |> Enum.reverse()
      |> group_rules()
      |> Enum.filter(&is_list/1)
      |> Enum.reduce({0, []}, &generate_function(&1, &2, filter))

    [guard | Enum.reverse(functions) |> List.flatten]
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

  def group_rules([{:transform, _} = t1 | rest]) do
   [t1 | group_rules(rest)]
  end

  def group_rules([group, {:replace, _, _, _} = r1 | rest]) when is_list(group) do
    group_rules([[r1 | group] | rest])
  end

  def group_rules([{:replace, _, _, _} = r1, {:replace, _, _, _} = r2 | rest]) do
    group_rules([[r2, r1] | rest])
  end

  def group_rules([group, {:transform, _} = t1 | rest]) when is_list(group) do
    [Enum.reverse(group), t1 | group_rules(rest)]
  end

  def group_rules([{:replace, _, _, _} = r1, {:transform, _} = t2 | rest]) do
    [[r1] | group_rules([t2 | rest])]
  end

  def group_rules([group]) when is_list(group) do
    [Enum.reverse(group)]
  end

  def generate_function({:transform, name}, {counter, acc}, filter) do
    funcall =
      quote do
        unquote(filter_module(name)).transform(unquote(filter))
      end

    {counter, [funcall | acc]}
  end

  def generate_function(replacements, {counter, acc}, _filter) when is_list(replacements) do
    counter = counter + 1
    function_name = :"replace_#{counter}"

    replacement_clauses =
      replacements
      |> Enum.map(&generate_replace_clause(&1, function_name))
      |> List.flatten

    final_clause =
      quote do
        <<char::utf8>> <> rest -> <<char::utf8>> <> unquote(function_name)(rest)
      end

    primary_function =
      quote do
        defp unquote(function_name)(<<char::utf8, rest::binary>>) when iff(char) do
          case <<char::utf8, rest::binary>> do
            unquote(replacement_clauses ++ final_clause)
          end
        end
      end

    default_function =
      quote do
        defp unquote(function_name)("") do
          ""
        end
      end

    {counter, [default_function, primary_function | acc]}
  end

  def generate_replace_clause({:replace, from, to, []}, function_name) do
    quote do
      unquote(from) <> rest -> unquote(to) <> unquote(function_name)(rest)
    end
  end

  def generate_replace_clause({:replace, from, to, options}, function_name) do
    preceeded_by = Keyword.get(options, :preceeded_by)

    quote do
      <<char::utf8, rest::binary>> when Unicode.Set.match?(char, unquote(preceeded_by))->
        replaced = String.replace(rest, compile!(unquote(from)), unquote(to))
        <<char::utf8>> <> unquote(function_name)(replaced)
    end
  end

  # Derive the name of the module from the filter
  # Doesn't yet handle complex names
  def filter_module(name) do
    Module.concat(__MODULE__, filter_module_name(name))
  end

  def filter_module_name(name) do
    name
    |> String.downcase
    |> String.split("-")
    |> case do
        [from] -> "Any" <> String.capitalize(from)
        [from, to] -> String.capitalize(from) <> String.capitalize(to)
      end
  end
end
