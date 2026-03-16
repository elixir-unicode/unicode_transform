# Available Transforms

This document lists all transforms available in `unicode_transform`, including the `:from` and `:to` option atoms, direct transform IDs for the `:transform` option, and the 394 CLDR XML rule sets that ship with the library.

## Using transforms

There are three ways to invoke a transform:

```elixir
# 1. :from / :to atoms (most convenient)
Unicode.Transform.transform("Москва", from: :cyrillic, to: :latin)

# 2. :transform string (for transforms without atom mappings)
Unicode.Transform.transform("text", transform: "Armenian-Latin-BGN")

# 3. :transform with :direction (for reverse transforms)
Unicode.Transform.transform("text", transform: "Hiragana-Katakana", direction: :reverse)
```

The `:from` option defaults to `:any` when omitted:

```elixir
# These are equivalent:
Unicode.Transform.transform("hello", to: :upper)
Unicode.Transform.transform("hello", from: :any, to: :upper)
```

Both atoms and strings are accepted for `:from` and `:to`:

```elixir
Unicode.Transform.transform("text", from: :greek, to: :latin)
Unicode.Transform.transform("text", from: "Greek", to: "Latin")
Unicode.Transform.transform("text", from: :grek, to: :latn)
```

## Script detection

Use `from: :detect` to automatically detect scripts in the input:

```elixir
Unicode.Transform.transform("αβγδ мир", from: :detect, to: :latin)
{:ok, "abgd mir"}
```

## Programmatic listing

To list all available transforms at runtime:

```elixir
Unicode.Transform.available_transforms()
```

This returns a sorted list of all transform IDs the library can resolve.

## Built-in transforms

These transforms are implemented directly in Elixir without CLDR XML rule sets.

| `:to` atom | Transform ID | Description |
|---|---|---|
| `:nfc` | `Any-NFC` | Unicode NFC normalization |
| `:nfd` | `Any-NFD` | Unicode NFD normalization |
| `:nfkc` | `Any-NFKC` | Unicode NFKC normalization |
| `:nfkd` | `Any-NFKD` | Unicode NFKD normalization |
| `:upper` | `Any-Upper` | Uppercase mapping |
| `:lower` | `Any-Lower` | Lowercase mapping |
| `:title` | `Any-Title` | Titlecase mapping |
| `:null` | `Any-Null` | Identity (no change) |
| `:remove` | `Any-Remove` | Remove all characters |

## Script name atoms

These atoms can be used with the `:from` and `:to` options. Each script has a full name atom and a BCP47 (ISO 15924) code atom that resolve to the same value.

| Full name | BCP47 code | Resolves to |
|---|---|---|
| `:arabic` | `:arab` | `"Arabic"` |
| `:armenian` | `:armn` | `"Armenian"` |
| `:bengali` | `:beng` | `"Bengali"` |
| `:bopomofo` | `:bopo` | `"Bopomofo"` |
| `:canadian_aboriginal` | `:cans` | `"CanadianAboriginal"` |
| `:cyrillic` | `:cyrl` | `"Cyrillic"` |
| `:devanagari` | `:deva` | `"Devanagari"` |
| `:ethiopic` | `:ethi` | `"Ethiopic"` |
| `:georgian` | `:geor` | `"Georgian"` |
| `:greek` | `:grek` | `"Greek"` |
| `:gujarati` | `:gujr` | `"Gujarati"` |
| `:gurmukhi` | `:guru` | `"Gurmukhi"` |
| `:han` | `:hani` | `"Han"` |
| `:hangul` | `:hang` | `"Hangul"` |
| `:hebrew` | `:hebr` | `"Hebrew"` |
| `:hiragana` | `:hira` | `"Hiragana"` |
| `:kannada` | `:knda` | `"Kannada"` |
| `:katakana` | — | `"Katakana"` |
| `:khmer` | `:khmr` | `"Khmer"` |
| `:lao` | `:laoo` | `"Lao"` |
| `:latin` | `:latn` | `"Latin"` |
| `:malayalam` | `:mlym` | `"Malayalam"` |
| `:myanmar` | `:mymr` | `"Myanmar"` |
| `:oriya` | `:orya` | `"Oriya"` |
| `:sinhala` | `:sinh` | `"Sinhala"` |
| `:syriac` | `:syrc` | `"Syriac"` |
| `:tamil` | `:taml` | `"Tamil"` |
| `:telugu` | `:telu` | `"Telugu"` |
| `:thaana` | `:thaa` | `"Thaana"` |
| `:thai` | — | `"Thai"` |

Additional atoms without BCP47 equivalents:

| Atom | Resolves to |
|---|---|
| `:hant` | `"Hant"` |
| `:interindic` | `"InterIndic"` |
| `:jamo` | `"Jamo"` |

### Target atoms

| Atom | Resolves to |
|---|---|
| `:ascii` | `"ASCII"` |
| `:fullwidth` | `"Fullwidth"` |
| `:halfwidth` | `"Halfwidth"` |

### Special atoms

| Atom | Resolves to |
|---|---|
| `:publishing` | `"Publishing"` |
| `:accents` | `"Accents"` |
| `:any` | `"Any"` |
| `:detect` | Automatic script detection |

## Script-to-Latin transforms

These are the most commonly used transforms. Use `from: <script>, to: :latin` or the equivalent `:transform` string.

| `:from` | `:to` | Transform ID | Bidirectional |
|---|---|---|---|
| `:arabic` | `:latin` | `Arabic-Latin` | Yes |
| `:armenian` | `:latin` | `Armenian-Latin` | No (forward only) |
| `:bengali` | `:latin` | `Bengali-Latin` | Yes |
| `:canadian_aboriginal` | `:latin` | `CanadianAboriginal-Latin` | Yes |
| `:cyrillic` | `:latin` | `Cyrillic-Latin` | Yes |
| `:devanagari` | `:latin` | `Devanagari-Latin` | Yes |
| `:georgian` | `:latin` | `Georgian-Latin` | Yes |
| `:greek` | `:latin` | `Greek-Latin` | Yes |
| `:gujarati` | `:latin` | `Gujarati-Latin` | Yes |
| `:gurmukhi` | `:latin` | `Gurmukhi-Latin` | Yes |
| `:han` | `:latin` | `Han-Latin` | No (forward only) |
| `:hangul` | `:latin` | `Hangul-Latin` | Yes |
| `:hant` | `:latin` | `Hant-Latin` | No (forward only) |
| `:hebrew` | `:latin` | `Hebrew-Latin` | Yes |
| `:hiragana` | `:latin` | `Hiragana-Latin` | Yes |
| `:kannada` | `:latin` | `Kannada-Latin` | Yes |
| `:katakana` | `:latin` | `Katakana-Latin` | Yes |
| `:khmer` | `:latin` | `Khmer-Latin` | Yes |
| `:lao` | `:latin` | `Lao-Latin` | Yes |
| `:malayalam` | `:latin` | `Malayalam-Latin` | Yes |
| `:myanmar` | `:latin` | `Myanmar-Latin` | Yes |
| `:oriya` | `:latin` | `Oriya-Latin` | Yes |
| `:sinhala` | `:latin` | `Sinhala-Latin` | Yes |
| `:syriac` | `:latin` | `Syriac-Latin` | Yes |
| `:tamil` | `:latin` | `Tamil-Latin` | Yes |
| `:telugu` | `:latin` | `Telugu-Latin` | Yes |
| `:thaana` | `:latin` | `Thaana-Latin` | Yes |
| `:thai` | `:latin` | `Thai-Latin` | Yes |

Bidirectional transforms can be used in reverse with `from: :latin, to: <script>`.

## Latin-ASCII (accent stripping)

| `:from` | `:to` | Transform ID |
|---|---|---|
| `:latin` | `:ascii` | `Latin-ASCII` |

```elixir
Unicode.Transform.transform("café résumé", from: :latin, to: :ascii)
{:ok, "cafe resume"}
```

This transform has a dedicated fast-path module for maximum performance.

## Width transforms

| Transform ID | Description |
|---|---|
| `Fullwidth-Halfwidth` | Convert fullwidth characters to halfwidth |
| `Halfwidth-Fullwidth` | Convert halfwidth characters to fullwidth (reverse) |

```elixir
Unicode.Transform.transform("Ｈｅｌｌｏ", transform: "Fullwidth-Halfwidth")
```

## Japanese script conversion

| `:from` | `:to` | Transform ID | Bidirectional |
|---|---|---|---|
| `:hiragana` | `:katakana` | `Hiragana-Katakana` | Yes |

```elixir
Unicode.Transform.transform("あいうえお", from: :hiragana, to: :katakana)
{:ok, "アイウエオ"}
```

## Han (Chinese) transforms

| Transform ID | Description |
|---|---|
| `Han-Latin` | Chinese characters to Latin (pinyin) |
| `Han-Latin-Names` | Chinese names to Latin (surname-first order) |
| `Han-Spacedhan` | Insert spaces between Chinese characters |
| `Simplified-Traditional` | Simplified Chinese to Traditional Chinese |

```elixir
Unicode.Transform.transform("中国", transform: "Han-Latin")
```

## Indic cross-script transforms

Every pair of Indic scripts has a direct transform via the InterIndic pivot. These are all bidirectional.

### Available Indic scripts

Bengali, Devanagari, Gujarati, Gurmukhi, Kannada, Malayalam, Oriya, Tamil, Telugu

### Cross-script matrix

Each Indic script can be transformed to every other Indic script. For example:

```elixir
Unicode.Transform.transform("हिन्दी", from: :devanagari, to: :bengali)
{:ok, "হিন্দী"}

Unicode.Transform.transform("বাংলা", from: :bengali, to: :gujarati)
{:ok, "બાંલા"}
```

The full set of Indic cross-script files:

| Source → | Bengali | Devanagari | Gujarati | Gurmukhi | Kannada | Malayalam | Oriya | Tamil | Telugu |
|---|---|---|---|---|---|---|---|---|---|
| **Bengali** | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Devanagari** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Gujarati** | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Gurmukhi** | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Kannada** | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ |
| **Malayalam** | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **Oriya** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ |
| **Tamil** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| **Telugu** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |

### Indic-to-Arabic and Indic-to-Urdu

Each Indic script also has transforms to Arabic script and Urdu:

| Transform ID | Description |
|---|---|
| `Bengali-Arabic` | Bengali to Arabic script |
| `Bengali-ur` | Bengali to Urdu |
| `Devanagari-Arabic` | Devanagari to Arabic script |
| `Devanagari-ur` | Devanagari to Urdu |
| `Gujarati-Arabic` | Gujarati to Arabic script |
| `Gujarati-ur` | Gujarati to Urdu |
| `Gurmukhi-Arabic` | Gurmukhi to Arabic script |
| `Gurmukhi-ur` | Gurmukhi to Urdu |
| `Kannada-Arabic` | Kannada to Arabic script |
| `Kannada-ur` | Kannada to Urdu |
| `Malayalam-Arabic` | Malayalam to Arabic script |
| `Malayalam-ur` | Malayalam to Urdu |
| `Oriya-Arabic` | Oriya to Arabic script |
| `Oriya-ur` | Oriya to Urdu |
| `Tamil-Arabic` | Tamil to Arabic script |
| `Tamil-ur` | Tamil to Urdu |
| `Telugu-Arabic` | Telugu to Arabic script |
| `Telugu-ur` | Telugu to Urdu |

### InterIndic pivot transforms

These are internal transforms used by the cross-script Indic pipeline. They can also be used directly:

| Transform ID | Description |
|---|---|
| `Bengali-InterIndic` | Bengali to InterIndic |
| `Devanagari-InterIndic` | Devanagari to InterIndic |
| `Gujarati-InterIndic` | Gujarati to InterIndic |
| `Gurmukhi-InterIndic` | Gurmukhi to InterIndic |
| `Kannada-InterIndic` | Kannada to InterIndic |
| `Malayalam-InterIndic` | Malayalam to InterIndic |
| `Oriya-InterIndic` | Oriya to InterIndic |
| `Tamil-InterIndic` | Tamil to InterIndic |
| `Telugu-InterIndic` | Telugu to InterIndic |
| `InterIndic-Bengali` | InterIndic to Bengali |
| `InterIndic-Devanagari` | InterIndic to Devanagari |
| `InterIndic-Gujarati` | InterIndic to Gujarati |
| `InterIndic-Gurmukhi` | InterIndic to Gurmukhi |
| `InterIndic-Kannada` | InterIndic to Kannada |
| `InterIndic-Latin` | InterIndic to Latin |
| `InterIndic-Malayalam` | InterIndic to Malayalam |
| `InterIndic-Oriya` | InterIndic to Oriya |
| `InterIndic-Tamil` | InterIndic to Tamil |
| `InterIndic-Telugu` | InterIndic to Telugu |
| `InterIndic-Arabic` | InterIndic to Arabic |
| `InterIndic-ur` | InterIndic to Urdu |

## BGN/PCGN romanization transforms

These follow the [BGN/PCGN romanization](https://en.wikipedia.org/wiki/BGN/PCGN_romanization) standards used by the U.S. Board on Geographic Names and the Permanent Committee on Geographical Names.

| Transform ID | Description |
|---|---|
| `Amharic-Latin-BGN` | Amharic (Ethiopic) to Latin |
| `Arabic-Latin-BGN` | Arabic to Latin |
| `Armenian-Latin-BGN` | Armenian to Latin |
| `Azerbaijani-Latin-BGN` | Azerbaijani (Cyrillic) to Latin |
| `Belarusian-Latin-BGN` | Belarusian to Latin |
| `Bulgarian-Latin-BGN` | Bulgarian to Latin |
| `Georgian-Latin-BGN` | Georgian to Latin |
| `Georgian-Latin-BGN_1981` | Georgian to Latin (1981 system) |
| `Greek-Latin-BGN` | Greek to Latin |
| `Hebrew-Latin-BGN` | Hebrew to Latin |
| `Katakana-Latin-BGN` | Katakana to Latin |
| `Kazakh-Latin-BGN` | Kazakh to Latin |
| `Kirghiz-Latin-BGN` | Kirghiz to Latin |
| `Korean-Latin-BGN` | Korean to Latin |
| `Macedonian-Latin-BGN` | Macedonian to Latin |
| `Maldivian-Latin-BGN` | Maldivian (Thaana) to Latin |
| `Mongolian-Latin-BGN` | Mongolian to Latin |
| `Pashto-Latin-BGN` | Pashto to Latin |
| `Persian-Latin-BGN` | Persian to Latin |
| `Russian-Latin-BGN` | Russian to Latin |
| `Serbian-Latin-BGN` | Serbian to Latin |
| `Turkmen-Latin-BGN` | Turkmen to Latin |
| `Ukrainian-Latin-BGN` | Ukrainian to Latin |
| `Uzbek-Latin-BGN` | Uzbek to Latin |

```elixir
Unicode.Transform.transform("Москва", transform: "Russian-Latin-BGN")
```

## UNGEGN romanization

| Transform ID | Description |
|---|---|
| `Greek_Latin_UNGEGN` | Greek to Latin (UNGEGN standard) |

## Locale-specific transforms

### German ASCII

| `:from` | `:to` | Transform ID | Description |
|---|---|---|---|
| `:de` | `:ASCII` | `de-ASCII` | Context-sensitive German umlaut conversion |

```elixir
Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
{:ok, "AE oe ue"}

# Also available via :from/:to
Unicode.Transform.transform("Ä ö ü", from: :de, to: :ASCII)
{:ok, "AE oe ue"}
```

### Locale-specific case transforms

These apply language-specific casing rules (e.g., Turkish dotted/dotless I, Lithuanian accent handling).

| Transform ID | Description |
|---|---|
| `az-Lower` | Azerbaijani lowercase |
| `az-Title` | Azerbaijani titlecase |
| `az-Upper` | Azerbaijani uppercase |
| `el-Lower` | Greek lowercase |
| `el-Title` | Greek titlecase |
| `el-Upper` | Greek uppercase |
| `lt-Lower` | Lithuanian lowercase |
| `lt-Title` | Lithuanian titlecase |
| `lt-Upper` | Lithuanian uppercase |
| `nl-Title` | Dutch titlecase (IJ digraph handling) |
| `tr-Lower` | Turkish lowercase |
| `tr-Title` | Turkish titlecase |
| `tr-Upper` | Turkish uppercase |

```elixir
Unicode.Transform.transform("İSTANBUL", transform: "tr-Lower")
```

## Ethiopic transforms

| Transform ID | Description |
|---|---|
| `Ethiopic-Latin-ALALOC` | Ethiopic to Latin (ALA-LOC standard) |
| `Ethiopic-Latin-Aethiopica` | Ethiopic to Latin (Aethiopica) |
| `Ethiopic-Latin-BetaMetsehaf` | Ethiopic to Latin (Beta Maṣāḥǝft) |
| `Ethiopic-Latin-ES3842` | Ethiopic to Latin (ES 3842) |
| `Ethiopic-Latin-IES_JES_1964` | Ethiopic to Latin (IES/JES 1964) |
| `Ethiopic-Latin-Lambdin` | Ethiopic to Latin (Lambdin) |
| `Ethiopic-Latin-SERA` | Ethiopic to Latin (SERA) |
| `Ethiopic-Latin-TekieAlibekit` | Ethiopic to Latin (Tekie Alibekit) |
| `Ethiopic-Latin-Xaleget` | Ethiopic to Latin (Xaleget) |
| `Ethiopic-Braille-Amharic` | Ethiopic to Braille (Amharic) |
| `Ethiopic-Cyrillic-Gutgarts` | Ethiopic to Cyrillic (Gutgarts) |
| `Ethiopic-Ethiopic-Gurage` | Ethiopic variant (Gurage) |
| `Ethiopic-Musnad` | Ethiopic to Musnad |

## Phonetic (IPA/FONIPA) transforms

Transforms to and from the International Phonetic Alphabet.

| Transform ID | Description |
|---|---|
| `IPA-XSampa` | IPA to X-SAMPA notation |
| `am-am_FONIPA` | Amharic to IPA |
| `ar-ar_FONIPA` | Arabic to IPA (via `und_FONIPA-ar`) |
| `blt-fonipa-t-blt` | Tai Dam to IPA |
| `ch-ch_FONIPA` | Chamorro to IPA |
| `chr-chr_FONIPA` | Cherokee to IPA |
| `cs-cs_FONIPA` | Czech to IPA |
| `cy-fonipa-t-cy` | Welsh to IPA |
| `dsb-dsb_FONIPA` | Lower Sorbian to IPA |
| `eo-eo_FONIPA` | Esperanto to IPA |
| `es-es_FONIPA` | Spanish to IPA |
| `fa-fa_FONIPA` | Persian to IPA |
| `hy-hy_FONIPA` | Armenian to IPA |
| `hy_AREVMDA-hy_AREVMDA_FONIPA` | Western Armenian to IPA |
| `ia-ia_FONIPA` | Interlingua to IPA |
| `kk-kk_FONIPA` | Kazakh to IPA |
| `ky-ky_FONIPA` | Kyrgyz to IPA |
| `la-la_FONIPA` | Latin to IPA |
| `my-my_FONIPA` | Myanmar to IPA |
| `nv-nv_FONIPA` | Navajo to IPA |
| `pl-pl_FONIPA` | Polish to IPA |
| `ro-ro_FONIPA` | Romanian to IPA |
| `sat_Olck-sat_FONIPA` | Santali (Ol Chiki) to IPA |
| `si-si_FONIPA` | Sinhala to IPA |
| `sk-sk_FONIPA` | Slovak to IPA |
| `ta-ta_FONIPA` | Tamil to IPA |
| `tlh-tlh_FONIPA` | Klingon to IPA |
| `ug-ug_FONIPA` | Uyghur to IPA |
| `vec-vec_FONIPA` | Venetian to IPA |
| `xh-xh_FONIPA` | Xhosa to IPA |
| `zu-zu_FONIPA` | Zulu to IPA |

### IPA-based cross-language transforms

These use IPA as a pivot to approximate transliteration between languages.

| Transform ID | Description |
|---|---|
| `cs_FONIPA-ja` | Czech IPA to Japanese |
| `cs_FONIPA-ko` | Czech IPA to Korean |
| `es_FONIPA-am` | Spanish IPA to Amharic |
| `es_FONIPA-es_419_FONIPA` | Spanish IPA to Latin American Spanish IPA |
| `es_FONIPA-ja` | Spanish IPA to Japanese |
| `es_FONIPA-zh` | Spanish IPA to Chinese |
| `pl_FONIPA-ja` | Polish IPA to Japanese |
| `ro_FONIPA-ja` | Romanian IPA to Japanese |
| `sk_FONIPA-ja` | Slovak IPA to Japanese |
| `und_FONIPA-ar` | IPA to Arabic |
| `und_FONIPA-chr` | IPA to Cherokee |
| `und_FONIPA-fa` | IPA to Persian |

## Cross-language transliteration transforms

These transform between specific language pairs, often using phonetic approximation.

| Transform ID | Description |
|---|---|
| `am-ar` | Amharic to Arabic |
| `am-chr` | Amharic to Cherokee |
| `am-fa` | Amharic to Persian |
| `ch-am` | Chamorro to Amharic |
| `ch-ar` | Chamorro to Arabic |
| `ch-chr` | Chamorro to Cherokee |
| `ch-fa` | Chamorro to Persian |
| `cs-am` | Czech to Amharic |
| `cs-ar` | Czech to Arabic |
| `cs-chr` | Czech to Cherokee |
| `cs-fa` | Czech to Persian |
| `cs-ja` | Czech to Japanese |
| `cs-ko` | Czech to Korean |
| `eo-am` | Esperanto to Amharic |
| `eo-ar` | Esperanto to Arabic |
| `eo-chr` | Esperanto to Cherokee |
| `eo-fa` | Esperanto to Persian |
| `es-am` | Spanish to Amharic |
| `es-ar` | Spanish to Arabic |
| `es-chr` | Spanish to Cherokee |
| `es-fa` | Spanish to Persian |
| `es-ja` | Spanish to Japanese |
| `es-zh` | Spanish to Chinese |
| `es_419-am` | Latin American Spanish to Amharic |
| `es_419-ar` | Latin American Spanish to Arabic |
| `es_419-chr` | Latin American Spanish to Cherokee |
| `es_419-fa` | Latin American Spanish to Persian |
| `es_419-ja` | Latin American Spanish to Japanese |
| `es_419-zh` | Latin American Spanish to Chinese |
| `hy-am` | Armenian to Amharic |
| `hy-ar` | Armenian to Arabic |
| `hy-chr` | Armenian to Cherokee |
| `hy-fa` | Armenian to Persian |
| `hy_AREVMDA-am` | Western Armenian to Amharic |
| `hy_AREVMDA-ar` | Western Armenian to Arabic |
| `hy_AREVMDA-chr` | Western Armenian to Cherokee |
| `hy_AREVMDA-fa` | Western Armenian to Persian |
| `ia-am` | Interlingua to Amharic |
| `ia-ar` | Interlingua to Arabic |
| `ia-chr` | Interlingua to Cherokee |
| `ia-fa` | Interlingua to Persian |
| `it-am` | Italian to Amharic |
| `it-ja` | Italian to Japanese |
| `ja_Latn-ko` | Romanized Japanese to Korean |
| `ja_Latn-ru` | Romanized Japanese to Russian |
| `kk-am` | Kazakh to Amharic |
| `kk-ar` | Kazakh to Arabic |
| `kk-chr` | Kazakh to Cherokee |
| `kk-fa` | Kazakh to Persian |
| `ky-am` | Kyrgyz to Amharic |
| `ky-ar` | Kyrgyz to Arabic |
| `ky-chr` | Kyrgyz to Cherokee |
| `ky-fa` | Kyrgyz to Persian |
| `my-am` | Myanmar to Amharic |
| `my-ar` | Myanmar to Arabic |
| `my-chr` | Myanmar to Cherokee |
| `my-fa` | Myanmar to Persian |
| `pl-am` | Polish to Amharic |
| `pl-ar` | Polish to Arabic |
| `pl-chr` | Polish to Cherokee |
| `pl-fa` | Polish to Persian |
| `pl-ja` | Polish to Japanese |
| `rm_SURSILV-am` | Romansh (Sursilvan) to Amharic |
| `rm_SURSILV-ar` | Romansh (Sursilvan) to Arabic |
| `rm_SURSILV-chr` | Romansh (Sursilvan) to Cherokee |
| `rm_SURSILV-fa` | Romansh (Sursilvan) to Persian |
| `rm_SURSILV-rm_FONIPA_SURSILV` | Romansh (Sursilvan) to IPA |
| `ro-am` | Romanian to Amharic |
| `ro-ar` | Romanian to Arabic |
| `ro-chr` | Romanian to Cherokee |
| `ro-fa` | Romanian to Persian |
| `ro-ja` | Romanian to Japanese |
| `ru-ja` | Russian to Japanese |
| `ru-zh` | Russian to Chinese |
| `sat-am` | Santali to Amharic |
| `sat-ar` | Santali to Arabic |
| `sat-chr` | Santali to Cherokee |
| `sat-fa` | Santali to Persian |
| `si-am` | Sinhala to Amharic |
| `si-ar` | Sinhala to Arabic |
| `si-chr` | Sinhala to Cherokee |
| `si-fa` | Sinhala to Persian |
| `sk-am` | Slovak to Amharic |
| `sk-ar` | Slovak to Arabic |
| `sk-chr` | Slovak to Cherokee |
| `sk-fa` | Slovak to Persian |
| `sk-ja` | Slovak to Japanese |
| `tlh-am` | Klingon to Amharic |
| `tlh-ar` | Klingon to Arabic |
| `tlh-chr` | Klingon to Cherokee |
| `tlh-fa` | Klingon to Persian |
| `xh-am` | Xhosa to Amharic |
| `xh-ar` | Xhosa to Arabic |
| `xh-chr` | Xhosa to Cherokee |
| `xh-fa` | Xhosa to Persian |
| `zu-am` | Zulu to Amharic |
| `zu-ar` | Zulu to Arabic |
| `zu-chr` | Zulu to Cherokee |
| `zu-fa` | Zulu to Persian |

## Specialized transforms

| Transform ID | Description |
|---|---|
| `Any-Accents` | Add accents to Latin text |
| `Any-Publishing` | Typographic improvements (smart quotes, dashes) |
| `Jamo-Latin` | Korean Jamo to Latin |
| `Latin-ConjoiningJamo` | Latin to Conjoining Jamo (bidirectional) |
| `Latin-NumericPinyin` | Latin pinyin to numeric tone pinyin |
| `Pinyin-NumericPinyin` | Pinyin with tone marks to numeric tones |
| `Jpan-Latn` | Japanese (mixed scripts) to Latin |
| `ug-Latin` | Uyghur to Latin |
| `si-si_Latn` | Sinhala to Sinhala Latin |

## Other transforms

### Myanmar/Zawgyi

| Transform ID | Description |
|---|---|
| `my-t-my-d0-zawgyi` | Myanmar Unicode to Zawgyi encoding |
| `my-t-my-s0-zawgyi` | Zawgyi encoding to Myanmar Unicode |

### Script variant transforms

| Transform ID | Description |
|---|---|
| `Simplified-Traditional` | Simplified Chinese to Traditional Chinese |
| `uz_Cyrl-uz_Latn` | Uzbek Cyrillic to Uzbek Latin |
| `ru_Latn-ru-BGN` | Romanized Russian back to Russian Cyrillic |
| `ha-ha_NE` | Hausa to Hausa (Niger variant) |
| `yo-yo_BJ` | Yoruba to Yoruba (Benin variant) |
| `mn-mn_Latn-MNS` | Mongolian to Mongolian Latin (MNS) |
| `zh_Latn_PINYIN-ru` | Pinyin to Russian |

## Programmatic listing

To list all available transforms at runtime:

```elixir
Unicode.Transform.available_transforms()
```

This returns a sorted list of all transform IDs the library can resolve.
