# Benchmark comparing Latin-ASCII performance across three code paths:
#   (a) Fast-path compiled module (Unicode.Transform.LatinAscii)
#   (b) Elixir standard backend (cursor-based engine)
#   (c) NIF (ICU utrans)
#
# Run with: mix run bench/latin_ascii_benchmark.exs

unless Unicode.Transform.Nif.available?() do
  IO.puts("ERROR: NIF backend not available. Compile with UNICODE_TRANSFORM_NIF=true")
  System.halt(1)
end

char_source = "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ"

generate_input = fn target_length ->
  chars = String.graphemes(char_source)

  Stream.cycle(chars)
  |> Enum.take(target_length)
  |> Enum.join()
end

lengths = [10, 50, 100]

# Pre-warm
for len <- lengths do
  input = generate_input.(len)
  Unicode.Transform.LatinAscii.transform(input)
  Unicode.Transform.Nif.transform("Latin-ASCII", input, 0)

  Unicode.Transform.Cache.get_or_compile("Latin-ASCII", :forward, fn ->
    case Unicode.Transform.Loader.find_transform("Latin-ASCII") do
      {file_path, file_direction} ->
        data = Unicode.Transform.Loader.load_file(file_path)
        rules = Unicode.Transform.Parser.parse(data.rules)
        {:ok, Unicode.Transform.Compiler.compile(rules, file_direction)}

      nil ->
        {:error, :not_found}
    end
  end)
end

IO.puts("=== Latin-ASCII: fast-path vs Elixir engine vs NIF ===\n")

benchee_scenarios =
  for len <- lengths,
      {label, fun} <- [
        {"fast-path", fn input -> Unicode.Transform.LatinAscii.transform(input) end},
        {"elixir engine",
         fn input ->
           Unicode.Transform.transform(input, transform: "Latin-ASCII", backend: :elixir)
         end},
        {"nif",
         fn input -> Unicode.Transform.Nif.transform("Latin-ASCII", input, 0) end}
      ],
      into: %{} do
    input = generate_input.(len)
    {"#{label} (#{len} chars)", fn -> fun.(input) end}
  end

Benchee.run(
  benchee_scenarios,
  warmup: 2,
  time: 5,
  print: [configuration: false, benchmarking: false],
  formatters: [
    {Benchee.Formatters.Console, comparison: true}
  ]
)
