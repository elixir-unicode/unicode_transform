# The CLDR conformance suite (~297k cases, tagged `:cldr_conformance`) is excluded
# from the default run. Run it explicitly with `mix test --only cldr_conformance`.
nif_exclude = if Unicode.Transform.Nif.available?(), do: [], else: [:nif]
ExUnit.start(exclude: [:cldr_conformance | nif_exclude])
