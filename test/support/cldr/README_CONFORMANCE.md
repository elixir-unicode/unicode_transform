# CLDR transform conformance suite

This directory drives a strict conformance test of the pure-Elixir transform engine against the official CLDR transform test data.

## Layout

* `transforms/*.txt` — the vendored CLDR test data, one file per BCP-47 transform id, each line a tab-separated `source<TAB>expected` pair. See `transforms/PROVENANCE.md` for the source version.

## Running the tests

The conformance tests are tagged `:cldr_conformance` and excluded from the default `mix test` run (there are ~297k cases). Run them explicitly:

```
mix test --only cldr_conformance
```

Each transform is one test. It runs every `source` for that transform through the engine (`backend: :elixir`, forward direction) and asserts that **every** case produces the expected output. A transform is a conformance failure unless it passes 100% of its cases, so the suite is red until the engine fully conforms to CLDR and each failing test reports exactly how many of that transform's cases still diverge — an honest scorecard rather than a regression floor.

## Known non-conformant transforms

A small number of transforms are not yet at 100%. See the project CHANGELOG/notes for the current list; the remaining cases involve deep or ambiguous CLDR/ICU behaviour (e.g. flat-rule trailing-boundary semantics and Tai Viet tonology) where matching the golden data confidently would require ICU itself as an oracle.
