defmodule Unicode.Transform.Parser.Reducers do

  def maybe_not([?^ | [rest]]) do
    {:not, rest}
  end

  def maybe_not([?^ | rest]) do
    {:not, rest}
  end

  def maybe_not([other]) do
    other
  end

  def maybe_not(other) do
    other
  end

  def hex_to_integer(chars) do
    chars
    |> List.to_string()
    |> String.to_integer(16)
  end

  def insert_variable(_rest, args, context, _line, _offset) do
    [variable_name: variable_name] = args
    case Map.get(context, variable_name) do
      nil -> {:error, "Unknown variable #{inspect variable_name}"}
      variable_value -> {variable_value, context}
    end
  end

  def store_variable_in_context(_rest, args, context, _line, _offset) do
    [set_variable: [variable_name: variable_name, value: value]] = args
    context = Map.put(context, variable_name, value)
    {[], context}
  end

  def to_atom(args) do
    args
    |> List.to_string()
    |> String.to_atom()
  end

  def to_lower_atom([?^ | args]) do
    {:not, to_lower_atom(args)}
  end

  def to_lower_atom(args) do
    args
    |> List.to_string()
    |> String.replace(" ", "_")
    |> String.downcase()
    |> String.to_atom()
  end

  def postfix_set_operations([class, {:set_intersection, _}, other_class | rest]) do
    postfix_set_operations([{:intersection, [class, other_class]} | rest])
  end

  def postfix_set_operations([class, {:set_negation, _}, other_class | rest]) do
    postfix_set_operations([{:negation, [class, other_class]} | rest])
  end

  def postfix_set_operations([class]) do
    class
  end

  def postfix_set_operations([class | rest]) do
    {:and, [class, postfix_set_operations(rest)]}
  end

end