defmodule Unicode.Transform.RegressionTest do
  @moduledoc """
  A fast smoke test that runs a curated sample of the vendored CLDR conformance
  data through the pure-Elixir engine on every `mix test` run.

  The exhaustive ~297k-case suite is tagged `:cldr_conformance` and excluded from
  the default run, so this guards the engine fixes — and exercises the parser,
  compiler, engine, resolver and loader paths they added — without that cost. Each
  listed transform is fully conformant; a handful of its cases is enough to
  compile and drive its rules.
  """
  use ExUnit.Case, async: true

  @data_dir Path.join(__DIR__, "support/cldr/transforms")

  # One representative (fully-conformant) transform per engine fix.
  @transforms ~w(
    und-Latn-t-und-ethi
    und-Latn-t-und-ethi-m0-beta-metsehaf
    und-Latn-t-und-ethi-m0-sera
    und-Latn-t-und-ethi-m0-beta-metsehaf-geminate
    byn-Latn-t-byn-ethi-m0-tekie-alibekit
    byn-Latn-t-byn-ethi-m0-xaleget
    d0-morse-t-am-Ethi
    my-Latn-t-my
    ja-t-cs
    und-Deva-t-und-mlym
    und-Beng-t-und-mlym
    fa-t-es
    ar-t-es
    am-t-my
    ar-t-my
    am-t-si
    ar-t-si
    ug-fonipa-t-ug
    vec-fonipa-t-vec
    ka-Latn-t-ka-m0-bgn-2009
  )

  for id <- @transforms do
    test "sample conformance: #{id}" do
      id = unquote(id)

      for {source, expected} <- sample_cases(id) do
        assert Unicode.Transform.transform(source,
                 transform: id,
                 direction: :forward,
                 backend: :elixir
               ) == {:ok, expected},
               "#{id}: #{inspect(source)} should transform to #{inspect(expected)}"
      end
    end
  end

  # First few `source<TAB>expected` cases of a transform's vendored test file.
  defp sample_cases(id) do
    @data_dir
    |> Path.join(id <> ".txt")
    |> File.read!()
    |> String.split(~r/\r\n|\r|\n/)
    |> Enum.reject(&(&1 == "" or String.starts_with?(String.trim_leading(&1), "#")))
    |> Enum.flat_map(fn line ->
      case String.split(line, "\t") do
        [source, expected | _] -> [{source, expected}]
        _ -> []
      end
    end)
    |> Enum.take(5)
  end
end
