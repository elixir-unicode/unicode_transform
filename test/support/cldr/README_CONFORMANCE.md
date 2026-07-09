# CLDR transform conformance suite

This directory drives a conformance test of the pure-Elixir transform engine
against the official CLDR transform test data.

## Layout

* `transforms/*.txt` — the vendored CLDR test data, one file per BCP-47 transform id, each line a tab-separated `source<TAB>expected` pair. See `transforms/PROVENANCE.md` for the source version.
* `conformance_manifest.exs` — a `%{transform_id => passing_count}` map recording how many cases each transform currently passes. This is the regression floor.
* `gen_conformance_manifest.exs` — regenerates the manifest from the vendored data.

## Running the tests

The conformance tests are tagged `:cldr_conformance` and excluded from the default `mix test` run (there are ~297k cases). Run them explicitly:

```
mix test --only cldr_conformance
```

Each transform is one test. It runs every `source` for that transform through the engine (`backend: :elixir`, forward direction) and asserts the number of cases producing the expected output is at least the manifest floor. Transforms that currently pass every case therefore act as exact regression guards; partially-passing transforms are guarded against dropping below their recorded count.

## Regenerating the manifest

After improving the engine (so more cases pass), lock in the gains:

```
mix run test/support/cldr/gen_conformance_manifest.exs
```

Review the diff (passing counts should only go up) and commit the updated `conformance_manifest.exs`. If a change legitimately lowers a count, the diff makes that explicit for review.
