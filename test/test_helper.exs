exclude = if Unicode.Transform.Nif.available?(), do: [], else: [:nif]
ExUnit.start(exclude: exclude)
