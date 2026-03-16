# Changelog

## Unicode Transform 1.0.0

This is the changelog for Unicode Transform 1.0.0 released on March 17th, 2026.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-unicode/unicode_transform/tags)

### Breaking Changes

* This release is a complete re-implementation of the [CLDR Transform](https://unicode.org/reports/tr35/tr35-general.html#Transforms) specification. It implements the full suite of transformations. See `Cldr.Transform.transform/2` for the primary public API.

* The library has now moved on from a proof-of-concept that code-generated one transform module at compile time to a full runtime implementation of the Unicode CLDR Transform specification with currently 394 transforms, a unified API, optional ICU NIF backend, OTP supervision, caching, CI, and comprehensive property-based testing.

* The transformations are those available in CLDR version 48 which is the current version as of March 17th, 2026.

* Consult the [README](README.md) for information on how to install and use the library.

* See [TRANSFORMS](TRANSFORMS.md) for a complete listing of all available transforms.

## Unicode Transform 0.4.0

This is the changelog for Unicode Transform 0.4.0 released on 8th December, 2025.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-unicode/unicode_transform/tags)

### Bug Fixes

* Fix rules generator to ensure that a transform to an ASCII space is not trimmed (thereby causing an empty string). Thanks to @arcanemachine for the report. Closes #2.

### Enhancements

* Updates to CLDR 47 Transform rules (most of which remain unimplemented in this release)

## Unicode Transform 0.3.0

This is the changelog for Unicode Transform 0.3.0 released on April 18th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-unicode/unicode_transform/tags)

### Enhancements

* Generate some additional simple transforms and remove compiler warnings.

## Unicode Transform 0.2.0

This is the changelog for Unicode Transform 0.2.0 released on September 14th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-unicode/unicode_transform/tags)

### Enhancements

* Update to use [Unicode 14](https://unicode.org/versions/Unicode14.0.0) release data.

## Unicode Transform 0.1.0

This is the changelog for Unicode Transform 0.1.0 released on March 29th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-unicode/unicode_transform/tags)

### Enhancements

* Initial release. Supports the transform of Latin-1 to ASCII. See `Unicode.Transform.LatinAscii.transform/1`.
