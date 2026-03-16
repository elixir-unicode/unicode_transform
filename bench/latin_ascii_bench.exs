# Quick comparison of compiled module vs engine-based Latin-ASCII transform
input = "café résumé Ä Ö Ü ß Æ œ Ð þ Ł ñ"
long_input = String.duplicate(input, 20)

IO.puts("Input: #{inspect(input)} (#{String.length(input)} chars)")
IO.puts("Long input: #{String.length(long_input)} chars\n")

# Verify both produce the same output
{:ok, compiled_result} = Unicode.Transform.transform(input, from: :latin, to: :ascii)
IO.puts("Compiled result: #{inspect(compiled_result)}")

# Direct module call
direct_result = Unicode.Transform.LatinAscii.transform(input)
IO.puts("Direct result:   #{inspect(direct_result)}")
IO.puts("Match: #{compiled_result == direct_result}\n")

# Benchmark
iterations = 10_000

{compiled_time, _} = :timer.tc(fn ->
  for _ <- 1..iterations do
    Unicode.Transform.LatinAscii.transform(input)
  end
end)

# Force engine path by using do_transform with a different cache key
# Actually, let's just time the full API path since it uses compiled module now
{api_time, _} = :timer.tc(fn ->
  for _ <- 1..iterations do
    Unicode.Transform.transform(input, from: :latin, to: :ascii)
  end
end)

IO.puts("--- Short string (#{String.length(input)} chars) x #{iterations} iterations ---")
IO.puts("Compiled module (direct): #{div(compiled_time, 1000)}ms (#{div(compiled_time, iterations)}µs/call)")
IO.puts("Full API (via compiled):  #{div(api_time, 1000)}ms (#{div(api_time, iterations)}µs/call)")

# Long string
long_iterations = 1_000

{compiled_long_time, _} = :timer.tc(fn ->
  for _ <- 1..long_iterations do
    Unicode.Transform.LatinAscii.transform(long_input)
  end
end)

{api_long_time, _} = :timer.tc(fn ->
  for _ <- 1..long_iterations do
    Unicode.Transform.transform(long_input, from: :latin, to: :ascii)
  end
end)

IO.puts("\n--- Long string (#{String.length(long_input)} chars) x #{long_iterations} iterations ---")
IO.puts("Compiled module (direct): #{div(compiled_long_time, 1000)}ms (#{div(compiled_long_time, long_iterations)}µs/call)")
IO.puts("Full API (via compiled):  #{div(api_long_time, 1000)}ms (#{div(api_long_time, long_iterations)}µs/call)")
