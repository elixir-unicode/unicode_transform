# Benchmark comparing Elixir vs NIF backend performance.
#
# Requires: UNICODE_TRANSFORM_NIF=true mix compile
# Run with: mix run bench/backend_comparison.exs

unless Unicode.Transform.Nif.available?() do
  IO.puts("ERROR: NIF backend not available. Compile with UNICODE_TRANSFORM_NIF=true")
  System.halt(1)
end

transforms = [
  {"Any-Upper", "abcdefghijklmnopqrstuvwxyz"},
  {"NFC", "A\u0308o\u0308u\u0308e\u0301i\u0300a\u0302"},
  {"Latin-ASCII", "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ"},
  {"Greek-Latin", "αβγδεζηθικλμνξοπρστυφχψω"},
  {"Cyrillic-Latin", "абвгдежзиклмнопрстуфхцчшщ"},
  {"Arabic-Latin", "عربية كتابة نص اختبار"},
  {"Thai-Latin", "ภาษาไทยกรุงเทพมหานคร"},
  {"Hiragana-Katakana", "あいうえおかきくけこさしすせそ"},
  {"Hangul-Latin", "한글테스트가나다라마바사아자차카타파하"},
  {"Han-Latin", "中国人民共和国北京天安门广场"},
  {"Devanagari-Latin", "हिन्दीभाषालेखनपरीक्षा"}
]

generate_input = fn char_source, target_length ->
  chars = String.graphemes(char_source)

  Stream.cycle(chars)
  |> Enum.take(target_length)
  |> Enum.join()
end

lengths = [10, 50, 100]

# Pre-warm both backends
IO.puts("Pre-warming caches...")

for {name, char_source} <- transforms, len <- lengths do
  input = generate_input.(char_source, len)
  Unicode.Transform.transform(input, transform: name, backend: :nif)
  Unicode.Transform.transform(input, transform: name, backend: :elixir)
end

IO.puts("Running benchmarks...\n")

for {name, char_source} <- transforms do
  benchee_scenarios =
    for len <- lengths,
        backend <- [:elixir, :nif],
        into: %{} do
      input = generate_input.(char_source, len)
      label = "#{backend} (#{len} chars)"

      {label,
       fn ->
         Unicode.Transform.transform(input, transform: name, backend: backend)
       end}
    end

  IO.puts("=== #{name} ===")

  Benchee.run(
    benchee_scenarios,
    warmup: 2,
    time: 5,
    print: [configuration: false, benchmarking: false],
    formatters: [
      {Benchee.Formatters.Console, comparison: true}
    ]
  )

  IO.puts("")
end
