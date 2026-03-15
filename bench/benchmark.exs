# Benchmark transform performance across different transforms and string lengths.
#
# Run with: mix run bench/benchmark.exs

transforms = %{
  "Any-Upper" => %{
    script: :latin,
    char_source: "abcdefghijklmnopqrstuvwxyz"
  },
  "NFC" => %{
    script: :latin,
    # A-umlaut as combining sequence (A + combining diaeresis)
    char_source: "A\u0308o\u0308u\u0308e\u0301i\u0300a\u0302"
  },
  "Latin-ASCII" => %{
    script: :latin,
    char_source: "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ"
  },
  "Greek-Latin" => %{
    script: :greek,
    char_source: "αβγδεζηθικλμνξοπρστυφχψω"
  },
  "Cyrillic-Latin" => %{
    script: :cyrillic,
    char_source: "абвгдежзиклмнопрстуфхцчшщ"
  },
  "Hangul-Latin" => %{
    script: :hangul,
    char_source: "한글테스트가나다라마바사아자차카타파하"
  },
  "Devanagari-Bengali" => %{
    script: :devanagari,
    char_source: "हिन्दीभाषालेखनपरीक्षा"
  },
  "Thai-Latin" => %{
    script: :thai,
    char_source: "ภาษาไทยกรุงเทพมหานคร"
  },
  "Hiragana-Katakana" => %{
    script: :hiragana,
    char_source: "あいうえおかきくけこさしすせそ"
  },
  "Arabic-Latin" => %{
    script: :arabic,
    char_source: "عربية كتابة نص اختبار"
  }
}

# Generate input strings of target lengths by repeating the char source
generate_input = fn char_source, target_length ->
  chars = String.graphemes(char_source)
  count = length(chars)

  Stream.cycle(chars)
  |> Enum.take(target_length)
  |> Enum.join()
end

lengths = [10, 50, 100]

# Build benchmark scenarios
scenarios =
  for {name, config} <- transforms,
      len <- lengths,
      into: %{} do
    input = generate_input.(config.char_source, len)
    label = "#{name} (#{len} chars)"
    {label, {name, input}}
  end

# Pre-warm the transform cache by running each transform once
IO.puts("Pre-warming transform cache...")

for {_label, {name, input}} <- scenarios do
  Unicode.Transform.transform(input, transform: name)
end

IO.puts("Running benchmarks...\n")

benchee_scenarios =
  for {label, {name, input}} <- scenarios, into: %{} do
    {label, fn -> Unicode.Transform.transform(input, transform: name) end}
  end

Benchee.run(
  benchee_scenarios,
  warmup: 2,
  time: 5,
  memory_time: 2,
  print: [configuration: true, benchmarking: true],
  formatters: [
    {Benchee.Formatters.Console, extended_statistics: true}
  ]
)
