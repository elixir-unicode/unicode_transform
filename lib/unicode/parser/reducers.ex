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
      nil -> {:error, "Unknown variable #{inspect(variable_name)}"}
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

  def to_lower_atom(args) do
    args
    |> List.to_string()
    |> String.replace(" ", "_")
    |> String.downcase()
    |> String.to_atom()
  end

  def postfix_set_operations([?^ | rest]) do
    {:not, postfix_set_operations(rest)}
  end

  def postfix_set_operations([class, {:intersection, _}, other_class | rest]) do
    postfix_set_operations([{:intersection, [class, other_class]} | rest])
  end

  def postfix_set_operations([class, {:difference, _}, other_class | rest]) do
    postfix_set_operations([{:difference, [class, other_class]} | rest])
  end

  def postfix_set_operations([class]) do
    class
  end

  def postfix_set_operations([class | rest]) do
    {:and, [class, postfix_set_operations(rest)]}
  end

  def consolidate_string([a, b | rest]) when is_integer(a) and is_integer(b) do
    consolidate_string([{:string, [a, b]} | rest])
  end

  def consolidate_string([a, :repeat_star | rest]) when is_tuple(a) do
    consolidate_string([{:repeat_star, a} | rest])
  end

  def consolidate_string([a, :repeat_plus | rest]) when is_tuple(a) do
    consolidate_string([{:repeat_plus, a} | rest])
  end

  def consolidate_string([a, :optional | rest]) when is_tuple(a) do
    consolidate_string([{:optional, a} | rest])
  end

  def consolidate_string([a, rest]) when is_integer(a) do
    consolidate_string([{:string, [a]} | rest])
  end

  def consolidate_string([{:string, a}, b | rest]) when is_integer(b) do
    consolidate_string([{:string, a ++ [b]} | rest])
  end

  def consolidate_string([head]) when is_integer(head) do
    {:string, [head]}
  end

  def consolidate_string([head]) do
    head
  end

  def consolidate_string([head | rest]) do
    {:and, [head, consolidate_string(rest)]}
  end

  def consolidate_string(head) do
    head
  end

end
