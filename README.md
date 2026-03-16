# Unicode Transform

An Elixir implementation of the [CLDR Transform](https://unicode.org/reports/tr35/tr35-general.html#Transforms) specification ([Unicode Technical Standard #35, Section 10](https://unicode.org/reports/tr35/tr35-general.html#Rule_Syntax)). This library transliterates text between scripts, applies normalization and case mappings, and executes arbitrary CLDR transform rule sets at runtime.

The library ships with 394 CLDR transform XML files covering script conversions (Greek, Cyrillic, Arabic, Devanagari, Thai, Hangul, and many more), Indic cross-script transliterations, BGN/PCGN romanizations, and specialized transforms like `Any-Publishing` and `Fullwidth-Halfwidth`.

## Installation

```elixir
def deps do
  [
    {:unicode_transform, "~> 1.0"}
  ]
end
```

The docs are found at [https://hexdocs.pm/unicode_transform](https://hexdocs.pm/unicode_transform).

## Example usage

### Script-to-Latin transliteration

Convert text from non-Latin scripts to Latin characters:

```elixir
# Greek to Latin
iex> Unicode.Transform.transform("Ελληνικά", from: :greek, to: :latin)
{:ok, "Ellēniká"}

# Cyrillic to Latin
iex> Unicode.Transform.transform("Москва", from: :cyrillic, to: :latin)
{:ok, "Moskva"}

# Korean to Latin
iex> Unicode.Transform.transform("한글", from: :hangul, to: :latin)
{:ok, "hangeul"}

# Thai to Latin
iex> Unicode.Transform.transform("กรุงเทพ", from: :thai, to: :latin)
{:ok, "krungtheph"}

# Arabic to Latin
iex> Unicode.Transform.transform("عربي", from: :arabic, to: :latin)
{:ok, "ʿrby"}
```

### Latin-ASCII (accent stripping)

Remove diacritics and convert to plain ASCII:

```elixir
iex> Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
{:ok, "A O U ss"}

iex> Unicode.Transform.transform("café résumé", from: :latin, to: :ascii)
{:ok, "cafe resume"}
```

### German-specific ASCII transliteration

Uses context-sensitive rules (e.g., uppercase Ä becomes AE, lowercase ä becomes ae):

```elixir
iex> Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
{:ok, "AE oe ue"}

iex> Unicode.Transform.transform("Ä ö ü", from: :de, to: :ASCII)
{:ok, "AE oe ue"}

iex> Unicode.Transform.transform("Ä ö ü", from: "de", to: "ASCII")
{:ok, "AE oe ue"}
```

### Cross-script Indic transliteration

Convert between Indic scripts without going through Latin:

```elixir
iex> Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :bengali)
{:ok, "হিন্দী"}

iex> Unicode.Transform.transform("বাংলা", from: :bengali, to: :gujarati)
{:ok, "બাંলা"}
```

### Japanese script conversion

```elixir
iex> Unicode.Transform.transform("あいうえお", from: :hiragana, to: :katakana)
{:ok, "アイウエオ"}

# Options accept strings too (case-insensitive)
iex> Unicode.Transform.transform("あいうえお", from: "Hiragana", to: "Katakana")
{:ok, "アイウエオ"}

iex> Unicode.Transform.transform("tokyo", from: :latin, to: :katakana)
{:ok, "トキョ"}
```

### Normalization and case transforms

Built-in transforms for Unicode normalization forms and case mapping:

```elixir
iex> Unicode.Transform.transform("hello world", to: :upper)
{:ok, "HELLO WORLD"}

iex> Unicode.Transform.transform("hello world", to: :title)
{:ok, "Hello World"}

iex> Unicode.Transform.transform("A\u0308", to: :nfc)
{:ok, "Ä"}
```

### Bang variant

`transform!/2` returns the result directly or raises on error:

```elixir
iex> Unicode.Transform.transform!("Ä Ö Ü ß", from: :latin, to: :ascii)
"A O U ss"
```

### Automatic script detection

Use `from: :detect` to automatically detect the scripts in the input and chain a transform for each one:

```elixir
# Mixed Greek and Cyrillic — both transliterated to Latin
iex> Unicode.Transform.transform("αβγδ мир", from: :detect, to: :latin)
{:ok, "abgd mir"}

# Korean and Cyrillic in one string
iex> Unicode.Transform.transform("한글 Москва", from: :detect, to: :latin)
{:ok, "hangeul Moskva"}
```

### Direct transform IDs

For transforms that don't have a convenient atom mapping (BGN romanizations, locale-specific transforms), use the `:transform` option with a string transform ID. Optionally specify `:direction` (defaults to `:forward`):

```elixir
iex> Unicode.Transform.transform("Հayaստan", transform: "Armenian-Latin-BGN")
{:ok, "Hayastan"}

iex> Unicode.Transform.transform("あいうえお", transform: "Hiragana-Katakana")
{:ok, "アイウエオ"}

iex> Unicode.Transform.transform("アイウエオ", transform: "Hiragana-Katakana", direction: :reverse)
{:ok, "あいうえお"}
```

### Listing available transforms

```elixir
iex> Unicode.Transform.available_transforms() |> Enum.take(5)
["Amharic-Latin-BGN", "Any-Accents", "Any-Publishing", "Arabic-Latin-BGN", "Arabic-Latin"]
```

## How transform resolution works

When you call `Unicode.Transform.transform/2`, `unicode_transform` resolves the transform name, compiles its rules, and executes them against the input string.

### Resolution

Transform names are resolved in order of priority:

1. **Built-in transforms** — names like `NFC`, `NFD`, `Any-Upper`, `Any-Lower`, and `Any-Title` map directly to Elixir standard library functions (`String.normalize/2`, `String.upcase/1`, etc.).

2. **CLDR XML alias match** — each of the 394 XML files declares forward and backward aliases in its metadata. The alias `"Greek-Latin"` points to `priv/transforms/Greek-Latin.xml` in the forward direction. The backward alias `"Latin-Greek"` points to the same file but compiles in the reverse direction. Aliases are indexed into a `persistent_term` map on first use.

3. **Filename match** — if no alias matches, `unicode_transform` looks for a file named `priv/transforms/<transform-id>.xml`.

4. **Reverse direction of bidirectional files** — for files with `direction="both"`, the reverse transform ID is also indexed (e.g., `Latin-ConjoiningJamo.xml` with `direction="both"` is also reachable as `ConjoiningJamo-Latin`).

### Compilation

Once the XML file is located, its rule text is parsed into structured rule types:

* **Filter rules** (`:: [unicode_set] ;`) — restrict which characters the transform processes
* **Transform rules** (`:: TransformName ;`) — invoke another transform as a sub-pass
* **Variable definitions** (`$var = value ;`) — define reusable pattern fragments
* **Conversion rules** (`pattern → replacement ;`) — the core character mapping rules, with support for before/after context, revisit markers, capture groups, and Unicode character classes

Variable references (`$varName`) are resolved during compilation, and conversion rules are grouped into passes separated by transform rules.

### Execution

The engine uses a cursor-based rewriting algorithm following the [ICU transliterator design](https://unicode-org.github.io/icu/userguide/transforms/general/):

1. For each pass of conversion rules, walk the string from left to right at the codepoint level
2. At each cursor position, try each rule in order
3. When a rule matches (checking before-context, pattern, and after-context), replace the matched text and reposition the cursor
4. If no rule matches, advance the cursor by one codepoint
5. Transform rule passes invoke the named sub-transform on the entire intermediate string

Compiled transforms are cached in `:persistent_term` so repeated calls avoid recompilation.

### Transitive rule resolution

Transform rules within a rule set can reference other transforms, forming chains of arbitrary depth. Each `:: TransformName ;` directive becomes a separate pass that calls back into the full resolve-compile-execute pipeline.

For example, `Hangul-Latin` contains these rules:

```
:: ['ᄀ-하-ᅵᆨ-ᇂ...'] ;      # filter to Korean characters
:: NFKD ;                   # decompose Hangul syllables to jamo
:: ConjoiningJamo-Latin ;   # transliterate jamo to Latin
:: NFC ;                    # recompose
```

When executed, the engine:

1. Applies the filter (restricts processing to Korean characters)
2. Executes `NFKD` — a built-in that decomposes Hangul syllables (한 → 한)
3. Resolves `ConjoiningJamo-Latin` — finds `Latin-ConjoiningJamo.xml` via its backward alias, compiles its 121 conversion rules in reverse, and executes them against the decomposed jamo
4. Executes `NFC` — a built-in that recomposes to canonical form

Similarly, `Thai-Latin` chains through five sub-transforms: `NFD → Thai-ThaiSemi → Any-BreakInternal → Thai-ThaiLogical → ThaiLogical-Latin → NFC`. Each sub-transform is independently resolved, compiled, cached, and executed.

This design means adding a new transform that builds on existing ones requires only writing the rule file — no code changes are needed.

## ICU NIF backend (optional)

An optional NIF backend wraps ICU4C's `utrans` transliterator API, providing
high-performance native transforms. When the NIF is loaded, it is used
automatically; otherwise the pure-Elixir engine is used as a seamless fallback.

### Setup

1. Install ICU system libraries (`libicu` on Linux). For MacOS, `icucore` is used and is part of the base operating system.
2. Add the `elixir_make` dependency (already included as optional).
3. Compile with the NIF enabled:

```bash
UNICODE_TRANSFORM_NIF=true mix compile
```

Or set it permanently in `config/config.exs`:

```elixir
config :unicode_transform, :nif, true
```

### Selecting a backend

The `:backend` option controls which engine executes the transform at runtime:

```elixir
# Use the NIF (ICU) backend explicitly
iex> Unicode.Transform.transform("αβγδ", from: :greek, to: :latin, backend: :nif)
{:ok, "avgd"}

# Use the pure-Elixir backend explicitly
iex> Unicode.Transform.transform("αβγδ", from: :greek, to: :latin, backend: :elixir)
{:ok, "abgd"}

# Default: NIF when available, Elixir otherwise
iex> Unicode.Transform.transform("αβγδ", from: :greek, to: :latin)
{:ok, "avgd"}
```

When `:backend` is `:nif` and ICU does not recognise the transform ID (for
example, CLDR-specific transforms like `"Armenian-Latin-BGN"`), `unicode_transform`
falls back to the Elixir engine automatically.

### Checking availability

```elixir
iex> Unicode.Transform.Nif.available?()
true

iex> Unicode.Transform.default_backend()
:nif

iex> Unicode.Transform.Nif.available_ids() |> length()
757
```

### Unicode version considerations

Different components in the stack may ship different Unicode versions:

| Component | Unicode version | Scope |
|---|---|---|
| Elixir `String` (casing) | 17 | `Any-Upper`, `Any-Lower`, `Any-Title` |
| OTP 28 `:unicode` module (normalization) | 16 | `Any-NFC`, `Any-NFD`, `Any-NFKC`, `Any-NFKD` |
| `unicode` / `unicode_set` libraries | 17 | Script detection, character sets |
| System ICU (NIF) | Varies by OS | All transforms via `utrans` |

In practice the divergence only affects characters added or changed between
Unicode 16 and 17 — a small set that most users will not encounter. The major
scripts (Latin, Greek, Cyrillic, CJK, Arabic, Devanagari, etc.) are stable
across versions.

## Compatibility between backends

The Elixir engine and the ICU NIF backend produce identical results for built-in transforms (`Any-Upper`, `Any-Lower`, `Any-NFC`, `Any-NFD`, `Latin-ASCII`, etc.) and for the most common script-to-Latin transliterations on standard text. However, there are systematic differences for certain scripts and character ranges. These are documented below, grouped by category.

These deviations will change depending on:

* The version of ICU installed and used with the NIF,
* The version of the CLDR transform definitions in use. These are part of the `cldr_transform` library and updated from the CLDR repository. The current versions are from CLDR 48.2.
* The version of Unicode used by Elixir (version 17 as of Elixir 1.19);
* The Unicode version embedded in OTP (it's Unicode 16 with OTP 28) and
* The version of Unicode supported by the [unicode](https://hex.pm/packages/unicode) and    [unicode_set](https://hex.pm/packages/unicode_set) packages - Unicode 17 as of `cldr_transform` version 1.0.0.

### Armenian: different romanization standards

Armenian shows the largest divergence. ICU uses a scholarly/ISO-style romanization while the Elixir engine uses BGN/PCGN-style transliteration. These are fundamentally different conventions, not bugs.

| Character | NIF (ICU) | Elixir |
|---|---|---|
| Ժ (U+053A) | `}` | `ZH` |
| Չ (U+0549) | `ʻ` (U+02BB) | `CH'` |
| Ծ (U+053E) | `c` | `TS` |
| Ջ (U+054B) | `J̌` | `J` |
| Ռ (U+057C) | `ṙ` | `rr` |
| և (U+0587) | `ev` | `yev` |
| Modifier apostrophe | U+02BB (ʻ) | U+2019 (') |

### Katakana: extended and archaic kana

ICU handles several extended and archaic Katakana characters that the Elixir engine passes through unchanged. These characters appear in real Japanese text.

- **Archaic kana** — `ヰ` (wi), `ヱ` (we), `ヺ` (vo): ICU transliterates; Elixir passes through.
- **Small kana in non-combination contexts** — `ァ`, `ォ`, `ュ`, `ヮ`: ICU prefixes with `~`; Elixir passes through when not preceded by a combining kana.
- **Iteration marks** — `ヽ` (repeat), `ヾ` (voiced repeat): ICU repeats the previous syllable; Elixir passes through.
- **Long vowel mark** — `ー` (U+30FC): ICU produces a macron over the preceding vowel; Elixir passes through or drops it at string start.
- **Vu kana** — `ヴ` (U+30F4): ICU maps to `vu`; Elixir passes through.

### Hebrew: vowel point handling

ICU converts Hebrew combining vowel marks (nikkud) to Latin vowels, while the Elixir engine often passes them through unchanged. Affected marks include `ֲ` (hataf patah), `ֱ` (hataf segol), `ָ` (qamats), and `ֹ` (holam).

### Arabic and Cyrillic: extended character coverage

Some less common characters in the Arabic and Cyrillic extended blocks are transliterated by ICU but passed through by the Elixir engine. These are characters outside the core rule sets in the CLDR XML files, such as `ړ` (U+0693), `ڦ` (U+06A6), and `ۻ` (U+06BB) in Arabic, and `Ӫ` (U+04EA) in Cyrillic.

### Greek: keraia (numeral sign)

The Greek keraia `ʹ` is mapped to different codepoints:

- **NIF:** U+0374 (Greek numeral sign, passed through).
- **Elixir:** U+02B9 (modifier letter prime).

### Thai: syllable boundary spacing

ICU inserts spaces at certain syllable boundaries during Thai-Latin transliteration. The Elixir engine does not insert these spaces, producing a more compact output.

### Japanese special characters

- **`ゟ` (U+309F, hiragana yori):** ICU passes through; Elixir expands to `yori`.
- **`゜` (U+309C, combining handakuten):** ICU keeps the combining mark; Elixir decomposes to space + U+309A.

### Gujarati: abbreviation sign

`૰` (U+0AF0, Gujarati abbreviation sign) — ICU passes through unchanged; Elixir maps to `.` (period).

### Greek final sigma (Any-Lower)

ICU applies context-aware σ → ς conversion (final sigma at word boundaries). Elixir's `String.downcase/1` does not apply this contextual rule.

### Summary

| Category | Impact | Notes |
|---|---|---|
| Armenian romanization | High | Different standard (ISO vs BGN/PCGN) |
| Katakana extended kana | Medium | Affects real text with ヴ, small kana, iteration marks |
| Hebrew vowel points | Medium | Affects pointed/vocalized text |
| Arabic/Cyrillic extended | Low–Medium | Less common characters |
| Greek keraia | Low | Single character |
| Thai spacing | Low | Cosmetic |
| Japanese ゟ/゜ | Low | Rare characters |
| Gujarati abbreviation | Low | Single character |
| Greek final sigma | Low | Only affects `Any-Lower` with Greek input |

## Performance

### Backend comparison

Mean execution time per call, comparing the Elixir engine and the ICU NIF
backend across a range of scripts and input lengths. Benchmarked on Apple M1.

| Transform | Backend | 10 chars | 50 chars | 100 chars |
|---|---|---|---|---|
| Any-Upper | Elixir | 0.028 ms | 0.030 ms | 0.032 ms |
| Any-Upper | NIF | 0.067 ms | 0.070 ms | 0.073 ms |
| NFC | Elixir | 0.037 ms | 0.065 ms | 0.099 ms |
| NFC | NIF | 0.078 ms | 0.085 ms | 0.093 ms |
| Hiragana-Katakana | Elixir | 0.54 ms | 3.18 ms | 6.54 ms |
| Hiragana-Katakana | NIF | 0.12 ms | 0.12 ms | 0.13 ms |
| Thai-Latin | Elixir | 0.27 ms | 0.36 ms | 0.48 ms |
| Thai-Latin | NIF | 0.21 ms | 0.23 ms | 0.25 ms |
| Devanagari-Latin | Elixir | 0.19 ms | 0.35 ms | 0.55 ms |
| Devanagari-Latin | NIF | 0.15 ms | 0.18 ms | 0.22 ms |
| Greek-Latin | Elixir | 1.71 ms | 10.29 ms | 20.48 ms |
| Greek-Latin | NIF | 0.13 ms | 0.14 ms | 0.16 ms |
| Cyrillic-Latin | Elixir | 1.80 ms | 10.74 ms | 20.80 ms |
| Cyrillic-Latin | NIF | 0.13 ms | 0.14 ms | 0.15 ms |
| Arabic-Latin | Elixir | 1.88 ms | 9.11 ms | 18.05 ms |
| Arabic-Latin | NIF | 0.12 ms | 0.13 ms | 0.14 ms |
| Hangul-Latin | Elixir | 0.10 ms | 0.15 ms | 0.21 ms |
| Hangul-Latin | NIF | 0.12 ms | 0.14 ms | 0.16 ms |
| Han-Latin | Elixir | 41.77 ms | 211.05 ms | 444.12 ms |
| Han-Latin | NIF | 0.30 ms | 0.65 ms | 1.97 ms |

**Key observations:**

- **Built-in transforms** (`Any-Upper`, `NFC`) delegate to Elixir's `String`
  module. They are already fast and the NIF adds overhead from the
  UTF-8 → UTF-16 → UTF-8 round-trip, making the Elixir backend faster.

- **Script-to-Latin transforms** show the NIF's strength. The Elixir engine's
  cursor-based algorithm scales linearly with input length × number of rules.
  ICU's compiled transliterator is largely insensitive to input length:
  Greek-Latin is **130×** faster via the NIF at 100 characters, and
  Han-Latin is **225×** faster.

- **Thai-Latin and Devanagari-Latin** are closer because the Elixir engine uses
  efficient chained sub-transforms rather than large flat rule sets.

- **Hangul-Latin** is fast in both backends because the Elixir engine uses
  built-in NFKD decomposition to split syllables before applying a small
  jamo-to-Latin rule set.

- Note that the ICU library uses UTF-16 internally so there is a cost of converting from Elixir's UTF-8 to ICU's UTF-16 and back again in each NIF call. That overhead if baked into the performance results above.

### Latin-ASCII: fast-path vs engine vs NIF

Latin-ASCII has a dedicated compiled fast-path module
(`Unicode.Transform.LatinAscii`) that maps codepoints directly without
the cursor-based engine.

| Code path | 10 chars | 50 chars | 100 chars |
|---|---|---|---|
| Elixir engine | 0.029 ms | 0.049 ms | 0.073 ms |
| Fast-path module | 0.006 ms | 0.025 ms | 0.048 ms |
| NIF (ICU) | 0.081 ms | 0.101 ms | 0.125 ms |

The fast-path module is **21×** faster than the NIF at 100 characters and is
used automatically as the default code path for Latin-ASCII transforms.

### Running benchmarks

```bash
mix run bench/backend_comparison.exs
mix run bench/latin_ascii_benchmark.exs
```
