defmodule Unicode.Transform.Generator do
  @moduledoc """
  Generate Elixir source files from CLDR
  XML files the define Unicode transforms.

  """

  @source_dir "transforms"
  @destination_dir "lib/transforms"
  @base_module "Unicode.Transform"

  # @unavailable_names [Generate, Parser, Utils]
  # @builtin_names [AnyNFC, AnyNFD, AnyNFKC, AnyNFKC, AnyLower, AnyUpper, AnyTitle]
  @default_files "*.xml"

  def generate(files \\ @default_files, options \\ []) do
    source_directory = Keyword.get(options, :source_dir, @source_dir)
    destination_directory = Keyword.get(options, :destination_dir, @destination_dir)

    transforms =
      source_directory
      |> Path.join(files)
      |> Path.wildcard()

    Enum.map(transforms, &generate_module(&1, destination_directory))
  end

  def generate_module(file, destination_directory) do
    %{rules: rules, source: source, target: target, direction: direction, alias: alias} =
      Unicode.Transform.Utils.file(file)

    generated_code = generate_code(rules, source, target, direction, alias)
    basename = Path.basename(file, ".xml") |> String.replace("-", "_") |> String.downcase()
    file = Path.join(destination_directory, [basename, ".ex"])

    File.write!(file, generated_code)
    file
  end

  def generate_code(rules, source, target, direction, alias) do
    [generate_header(source, target, direction, alias), generate_rules(rules), generate_footer()]
    |> :erlang.iolist_to_binary()
    |> Code.format_string!()
  end

  def generate_header(source, target, direction, alias) do
    [
      "defmodule",
      " ",
      @base_module,
      ".",
      module_name(source, target),
      " ",
      "do",
      "\n",
      "use ",
      @base_module,
      "\n",
      "\n",
      "# This file is generated. Manual changes are not recommended",
      "\n",
      "# Source: #{source}",
      "\n",
      "# Target: #{target}",
      "\n",
      "# Transform direction: #{direction}",
      "\n",
      "# Transform alias: #{alias}",
      "\n",
      "\n"
    ]
  end

  defp generate_rules(rules) do
    rules
    |> Unicode.Transform.Parser.parse()
    |> Enum.map(&generate_rule/1)
  end

  defp generate_rule(rule) do
    Unicode.Transform.Rule.to_forward_code(rule)
  end

  defp generate_footer() do
    ["end", "\n"]
  end

  defp module_name(source, target) do
    String.capitalize(source) <> String.capitalize(target)
  end
end
