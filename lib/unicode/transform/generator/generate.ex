defmodule Unicode.Transform.Generate do
  @source_dir "transforms"
  @destination_dir "lib/transforms"
  @base_module Unicode.Transform

  @unavailable_names [Generate, Parser, Utils]
  @builtin_names [AnyNFC, AnyNFD, AnyNFKC, AnyNFKC, AnyLower, AnyUpper, AnyTitle]

  def generate(file, options \\ []) do
    source_directory = Keyword.get(options, :source_dir, @source_dir)
    destination_directory = Keyword.get(options, :destination_dir, @destination_dir)

  end


end