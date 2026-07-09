# Regenerates the CLDR conformance manifest.
#
#   mix run test/support/cldr/gen_conformance_manifest.exs
#
# Reads every vendored transform test file under `test/support/cldr/transforms/`,
# runs each `source` through the pure-Elixir engine, and writes the per-transform
# passing-case count to `test/support/cldr/conformance_manifest.exs`. The
# conformance test (`test/cldr_conformance_test.exs`) asserts each transform keeps
# passing at least this many cases. Run this after improving the engine to lock in
# the gains, and commit the updated manifest.

dir = Path.join([__DIR__, "transforms"])
manifest_path = Path.join([__DIR__, "conformance_manifest.exs"])

files =
  dir
  |> Path.join("*.txt")
  |> Path.wildcard()
  |> Enum.reject(&(&1 |> Path.basename() |> String.starts_with?("_")))

run = fn source, id, expected ->
  result =
    try do
      Unicode.Transform.transform(source, transform: id, direction: :forward, backend: :elixir)
    rescue
      _ -> :error
    catch
      _, _ -> :error
    end

  match?({:ok, ^expected}, result)
end

manifest =
  Map.new(files, fn file ->
    id = Path.basename(file, ".txt")

    cases =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.reject(&(&1 == "" or String.starts_with?(String.trim_leading(&1), "#")))
      |> Enum.flat_map(fn line ->
        case String.split(line, "\t") do
          [source, expected | _] -> [{source, expected}]
          _ -> []
        end
      end)

    # Warm the rule cache once before fanning out (see the conformance test).
    case cases do
      [{source, _} | _] -> run.(source, id, :__warm__)
      [] -> :ok
    end

    passing =
      cases
      |> Task.async_stream(fn {source, expected} -> run.(source, id, expected) end,
        ordered: false,
        max_concurrency: System.schedulers_online(),
        timeout: :infinity
      )
      |> Enum.count(fn {:ok, ok?} -> ok? end)

    {id, passing}
  end)

File.write!(manifest_path, inspect(manifest, limit: :infinity, pretty: true) <> "\n")

total_pass = manifest |> Map.values() |> Enum.sum()

IO.puts(
  "Wrote #{map_size(manifest)} transforms, #{total_pass} passing cases, to #{manifest_path}"
)
