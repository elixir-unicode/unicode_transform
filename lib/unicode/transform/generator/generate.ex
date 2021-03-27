defmodule Unicode.Transform.Generate do
  @source_dir "transforms"
  @destination_dir "lib/transforms"
  @base_module "Unicode.Transform"

  # @unavailable_names [Generate, Parser, Utils]
  # @builtin_names [AnyNFC, AnyNFD, AnyNFKC, AnyNFKC, AnyLower, AnyUpper, AnyTitle]
  @default_files "*.xml"

  def generate(options \\ []) do
    source_directory = Keyword.get(options, :source_dir, @source_dir)
    destination_directory = Keyword.get(options, :destination_dir, @destination_dir)
    files = Keyword.get(options, :files, @default_files)

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

    File.write(file, generated_code)
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
      source,
      target,
      " ",
      "do",
      "\n",
      "use ",
      @base_module,
      "\n",
      "\n",
      "# This file is generated. Manual changes are not recommended", "\n",
      "# Source: #{source}", "\n",
      "# Target: #{target}", "\n",
      "# Transform direction: #{direction}", "\n",
      "# Transform alias: #{alias}", "\n", "\n"
    ]
  end

  def generate_rules(rules) do
    rules
    |> Unicode.Transform.Parser.parse()
    |> Enum.map(&Unicode.Transform.Rule.to_forward_code/1)
  end

  def generate_footer() do
    ["end", "\n"]
  end
end
