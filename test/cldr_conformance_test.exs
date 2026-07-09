defmodule Unicode.Transform.CldrConformanceTest do
  @moduledoc """
  Strict conformance tests driven by the CLDR transform test data vendored under
  `test/support/cldr/transforms/`.

  Each `*.txt` file is named with a BCP-47 transform identifier and contains
  tab-separated `source<TAB>expected` pairs. Every file is one test: it runs each
  `source` through the pure-Elixir transform engine (`backend: :elixir`, forward
  direction) and asserts that **every** case produces the expected output.

  A transform is a conformance failure unless it passes 100% of its cases, so
  this suite fails until the engine fully conforms to CLDR. Each failing test
  reports how many of that transform's cases still diverge, making the run an
  honest scorecard of the remaining non-conformance rather than a pass/regress
  floor.

  The tests are tagged `:cldr_conformance` and excluded from the default
  `mix test` run (there are ~297k cases, ~60s). Run them explicitly:

      mix test --only cldr_conformance

  """
  use ExUnit.Case, async: true

  @moduletag :cldr_conformance

  @data_dir Path.join(__DIR__, "support/cldr/transforms")

  @transform_files @data_dir
                   |> Path.join("*.txt")
                   |> Path.wildcard()
                   |> Enum.reject(&(&1 |> Path.basename() |> String.starts_with?("_")))

  for file <- @transform_files do
    id = Path.basename(file, ".txt")

    @tag transform: id
    test "conformance: #{id}" do
      {passing, total} = run_conformance(unquote(file), unquote(id))

      assert passing == total,
             "#{unquote(id)}: only #{passing}/#{total} cases conform — " <>
               "#{total - passing} still produce wrong output or error"
    end
  end

  # Parse a CLDR transform test file into `{source, expected}` pairs, skipping
  # blank lines and `#` comments.
  defp read_cases(file) do
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
  end

  # Run every case for a transform and return `{passing, total}`. A case passes
  # only when the engine returns `{:ok, expected}`; wrong output, `{:error, _}`,
  # and engine crashes all count as not-passing.
  #
  # Cases run concurrently across schedulers. The engine compiles and caches a
  # transform's rules on first use, so we warm that cache with a single call
  # before fanning out to avoid a first-compile race between workers.
  defp run_conformance(file, id) do
    cases = read_cases(file)

    case cases do
      [{source, _expected} | _] -> transform_ok?(source, id, :__warm__)
      [] -> :ok
    end

    passing =
      cases
      |> Task.async_stream(
        fn {source, expected} -> transform_ok?(source, id, expected) end,
        ordered: false,
        max_concurrency: System.schedulers_online(),
        timeout: :infinity
      )
      |> Enum.count(fn {:ok, ok?} -> ok? end)

    {passing, length(cases)}
  end

  defp transform_ok?(source, id, expected) do
    # The engine call is a boundary that can raise on malformed rule input; a
    # crash is counted as a (non-passing) failure rather than aborting the run.
    result =
      try do
        Unicode.Transform.transform(source,
          transform: id,
          direction: :forward,
          backend: :elixir
        )
      rescue
        _ -> :error
      catch
        _, _ -> :error
      end

    match?({:ok, ^expected}, result)
  end
end
