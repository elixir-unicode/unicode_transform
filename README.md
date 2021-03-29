# Unicode Transform

Implements the [Unicode transform rules](https://unicode.org/reports/tr35/tr35-general.html#Transforms). This is particularly useful from transliterating from one script to another.

## Installation

```elixir
def deps do
  [
    {:unicode_transform, "~> 0.1.0"}
  ]
end
```

The docs are found at [https://hexdocs.pm/unicode_transform](https://hexdocs.pm/unicode_transform).

### Usage

[CLDR](https://cldr.unicode.org) defines a [transform specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms) to aid in transforming text from one script to another. It also defines a number of transforms implementing the specification and this library aims to implement these transforms in elixir.

The strategy used it to generate an elixir module for each of the CLDR transforms. This happens in two parts:

1. The transform defined by CLDR is used to generate an elixir module that contains macro calls modelled on the transform specification. For example, see the generated [Unicode.Transform.LatinAscii.ex](https://github.com/elixir-unicode/unicode_transform/blob/master/lib/transforms/latin_ascii.ex).  Generation is performed with `Unicode.Transform.Generator.generate/2`

2. At compilation the macros in the generated module are compiled to elixir code resulting in a module with a single public API `transform/1`

### Current state

The library supports only one transform, `Unicode.Transform.LatinAscii` that translates the Latin-1 script to ASCII. This is commonly referred to as "removing accents" although the scope is much broader. The file [latin_ascii.ex](https://github.com/elixir-unicode/unicode_transform/blob/master/lib/transforms/latin_ascii.ex) is largely self-explanatory.
