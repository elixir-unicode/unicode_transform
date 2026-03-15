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
iex> Unicode.Transform.transform("Ελληνικά", "Greek-Latin")
{:ok, "Ellēniká"}

# Cyrillic to Latin
iex> Unicode.Transform.transform("Москва", "Cyrillic-Latin")
{:ok, "Moskva"}

# Korean to Latin
iex> Unicode.Transform.transform("한글", "Hangul-Latin")
{:ok, "hangeul"}

# Thai to Latin
iex> Unicode.Transform.transform("กรุงเทพ", "Thai-Latin")
{:ok, "krungtheph"}

# Arabic to Latin
iex> Unicode.Transform.transform("عربي", "Arabic-Latin")
{:ok, "ʿrby"}
```

### Latin-ASCII (accent stripping)

Remove diacritics and convert to plain ASCII:

```elixir
iex> Unicode.Transform.transform("Ä Ö Ü ß", "Latin-ASCII")
{:ok, "A O U ss"}

iex> Unicode.Transform.transform("café résumé", "Latin-ASCII")
{:ok, "cafe resume"}
```

### German-specific ASCII transliteration

Uses context-sensitive rules (e.g., uppercase Ä becomes AE, lowercase ä becomes ae):

```elixir
iex> Unicode.Transform.transform("Ä ö ü", "de-ASCII")
{:ok, "AE oe ue"}
```

### Cross-script Indic transliteration

Convert between Indic scripts without going through Latin:

```elixir
iex> Unicode.Transform.transform("हिन्दी", "Devanagari-Bengali")
{:ok, "হিন্দী"}

iex> Unicode.Transform.transform("বাংলা", "Bengali-Gujarati")
{:ok, "બાંલા"}
```

### Japanese script conversion

```elixir
iex> Unicode.Transform.transform("あいうえお", "Hiragana-Katakana")
{:ok, "アイウエオ"}

iex> Unicode.Transform.transform("tokyo", "Latin-Katakana")
{:ok, "トキョ"}
```

### Normalization and case transforms

Built-in transforms for Unicode normalization forms and case mapping:

```elixir
iex> Unicode.Transform.transform("hello world", "Any-Upper")
{:ok, "HELLO WORLD"}

iex> Unicode.Transform.transform("hello world", "Any-Title")
{:ok, "Hello World"}

iex> Unicode.Transform.transform("A\u0308", "NFC")
{:ok, "Ä"}
```

### Reverse direction

Many transforms support an inverse direction:

```elixir
iex> Unicode.Transform.transform("アイウエオ", "Hiragana-Katakana", :reverse)
{:ok, "あいうえお"}
```

### Bang variant

`transform!/3` returns the result directly or raises on error:

```elixir
iex> Unicode.Transform.transform!("Ä Ö Ü ß", "Latin-ASCII")
"A O U ss"
```

### Listing available transforms

```elixir
iex> Unicode.Transform.available_transforms() |> Enum.take(5)
["Amharic-Latin-BGN", "Any-Accents", "Any-Publishing", "Arabic-Latin-BGN", "Arabic-Latin"]
```

## How transform resolution works

When you call `Unicode.Transform.transform/3`, the library resolves the transform name, compiles its rules, and executes them against the input string.

### Resolution

Transform names are resolved in order of priority:

1. **Built-in transforms** — names like `NFC`, `NFD`, `Any-Upper`, `Any-Lower`, and `Any-Title` map directly to Elixir standard library functions (`String.normalize/2`, `String.upcase/1`, etc.).

2. **CLDR XML alias match** — each of the 394 XML files declares forward and backward aliases in its metadata. The alias `"Greek-Latin"` points to `transforms/Greek-Latin.xml` in the forward direction. The backward alias `"Latin-Greek"` points to the same file but compiles in the reverse direction. Aliases are indexed into a `persistent_term` map on first use.

3. **Filename match** — if no alias matches, the library looks for a file named `transforms/<transform-id>.xml`.

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

Compiled transforms are cached in ETS so repeated calls avoid recompilation.

### Transitive rule resolution

Transform rules within a rule set can reference other transforms, forming chains of arbitrary depth. Each `:: TransformName ;` directive becomes a separate pass that calls back into the full resolve-compile-execute pipeline.

For example, `Hangul-Latin` contains these rules:

```
:: ['ᄀ-하-ᅵᆨ-ᇂ...'] ;   # filter to Korean characters
:: NFKD ;                  # decompose Hangul syllables to jamo
:: ConjoiningJamo-Latin ;   # transliterate jamo to Latin
:: NFC ;                    # recompose
```

When executed, the engine:

1. Applies the filter (restricts processing to Korean characters)
2. Executes `NFKD` — a built-in that decomposes Hangul syllables (한 → 한)
3. Resolves `ConjoiningJamo-Latin` — finds `Latin-ConjoiningJamo.xml` via its backward alias, compiles its 121 conversion rules in reverse, and executes them against the decomposed jamo
4. Executes `NFC` — a built-in that recomposes to canonical form

Similarly, `Thai-Latin` chains through five sub-transforms: `NFD → Thai-ThaiSemi → Any-BreakInternal → Thai-ThaiLogical → ThaiLogical-Latin → NFC`. Each sub-transform is independently resolved, compiled, cached, and executed.

This design means adding a new transform that builds on existing ones requires only writing the rule file — no code changes are needed.
