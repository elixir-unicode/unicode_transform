defmodule Unicode.Transform.AnyAccents do
  use Unicode.Transform

  # This file is generated. Manual changes are not recommended
  # Source: Any
  # Target: Accents
  # Transform direction: both
  # Transform alias: und-t-d0-accents

  #
  #
  transform("NFD")
  # to do: make reversible
  # define special conversion characters.
  # varients of this could use different characters, or set one or the other to null.
  define("$pre", "←")
  define("$post", "→")
  # Provide keyboard equivalents for common diacritics used in transliteration
  # COMBINING GRAVE ACCENT
  replace("$pre \` $post", "̀")
  # COMBINING ACUTE ACCENT
  replace("$pre \' $post", "́")
  # COMBINING CIRCUMFLEX ACCENT
  replace("$pre \^ $post", "̂")
  # COMBINING TILDE
  replace("$pre \~ $post", "̃")
  # COMBINING MACRON
  replace("$pre \- $post", "̄")
  # COMBINING DIAERESIS
  replace("$pre \" $post", "̈")
  # COMBINING RING ABOVE
  replace("$pre \* $post", "̊")
  # COMBINING CEDILLA
  replace("$pre \, $post", "̧")
  # COMBINING LONG SOLIDUS OVERLAY
  replace("$pre / $post", "̸")
  # COMBINING DOT BELOW
  replace("$pre \. $post", "̣")
  # Combine common characters
  # LATIN CAPITAL LETTER AE
  replace("$pre AE $post", "Æ")
  # LATIN SMALL LETTER AE
  replace("$pre ae $post", "æ")
  # LATIN CAPITAL LETTER ETH
  replace("$pre D $post", "Ð")
  # LATIN SMALL LETTER ETH
  replace("$pre d $post", "ð")
  # LATIN CAPITAL LETTER O WITH STROKE
  replace("$pre O/ $post", "Ø")
  # LATIN SMALL LETTER O WITH STROKE
  replace("$pre o/ $post", "ø")
  # LATIN CAPITAL LETTER THORN
  replace("$pre TH $post", "Þ")
  # LATIN SMALL LETTER THORN
  replace("$pre th $post", "þ")
  # LATIN CAPITAL LIGATURE OE
  replace("$pre OE $post", "Œ")
  # LATIN SMALL LIGATURE OE
  replace("$pre oe $post", "œ")
  # LATIN SMALL LETTER SHARP S
  replace("$pre ss $post", "ß")
  # LATIN CAPITAL LETTER ENG
  replace("$pre NG $post", "Ŋ")
  # LATIN SMALL LETTER ENG
  replace("$pre ng $post", "ŋ")
  # THETA
  replace("$pre T $post", "Θ")
  # THETA
  replace("$pre t $post", "θ")
  # LATIN CAPITAL LETTER ESH
  replace("$pre SH $post", "Ʃ")
  # LATIN SMALL LETTER ESH
  replace("$pre sh $post", "ʃ")
  # LATIN CAPITAL LETTER EZH
  replace("$pre ZH $post", "Ʒ")
  # LATIN SMALL LETTER EZH
  replace("$pre zh $post", "ʒ")
  # LATIN CAPITAL LETTER UPSILON
  replace("$pre U $post", "Ʊ")
  # LATIN SMALL LETTER UPSILON
  replace("$pre u $post", "ʊ")
  # LATIN CAPITAL LETTER SCHWA
  replace("$pre A $post", "Ə")
  # LATIN SMALL LETTER SCHWA
  replace("$pre a $post", "ə")
  # LATIN CAPITAL LETTER OPEN O
  replace("$pre O $post", "Ɔ")
  # LATIN SMALL LETTER OPEN O
  replace("$pre o $post", "ɔ")
  # LATIN CAPITAL LETTER OPEN E
  replace("$pre E $post", "Ɛ")
  # LATIN SMALL LETTER OPEN E
  replace("$pre e $post", "ɛ")
  # three that don't have uppercases
  # LATIN LETTER GLOTTAL STOP
  replace("$pre ? $post", "ʔ")
  # LATIN LETTER SMALL CAPITAL I
  replace("$pre i $post", "ɪ")
  # LATIN SMALL LETTER TURNED V
  replace("$pre v $post", "ʌ")
  # Additional Characters that may be added in the future
  # $pre XXX $post ↔ ̆ ; # COMBINING BREVE
  # $pre XXX $post ↔ ̇ ; # COMBINING DOT ABOVE
  # $pre XXX $post ↔ ̉ ; # COMBINING HOOK ABOVE
  # $pre XXX $post ↔ ̋ ; # COMBINING DOUBLE ACUTE ACCENT
  # $pre XXX $post ↔ ̌ ; # COMBINING CARON
  # $pre XXX $post ↔ ̏ ; # COMBINING DOUBLE GRAVE ACCENT
  # $pre XXX $post ↔ ̑ ; # COMBINING INVERTED BREVE
  # $pre XXX $post ↔ ̓ ; # COMBINING COMMA ABOVE
  # $pre XXX $post ↔ ̔ ; # COMBINING REVERSED COMMA ABOVE
  # $pre XXX $post ↔ ̛ ; # COMBINING HORN
  # $pre XXX $post ↔ ̤ ; # COMBINING DIAERESIS BELOW
  # $pre XXX $post ↔ ̥ ; # COMBINING RING BELOW
  # $pre XXX $post ↔ ̦ ; # COMBINING COMMA BELOW
  # $pre XXX $post ↔ ̨ ; # COMBINING OGONEK
  # $pre XXX $post ↔ ̭ ; # COMBINING CIRCUMFLEX ACCENT BELOW
  # $pre XXX $post ↔ ̮ ; # COMBINING BREVE BELOW
  # $pre XXX $post ↔ ̰ ; # COMBINING TILDE BELOW
  # $pre XXX $post ↔ ̱ ; # COMBINING MACRON BELOW
  # $pre YYY $post ↔ ª ; # FEMININE ORDINAL INDICATOR
  # $pre YYY $post ↔ º ; # MASCULINE ORDINAL INDICATOR
  # $pre YYY $post ↔ Đ ; # LATIN CAPITAL LETTER D WITH STROKE
  # $pre YYY $post ↔ đ ; # LATIN SMALL LETTER D WITH STROKE
  # $pre YYY $post ↔ Ħ ; # LATIN CAPITAL LETTER H WITH STROKE
  # $pre YYY $post ↔ ħ ; # LATIN SMALL LETTER H WITH STROKE
  # $pre YYY $post ↔ ı ; # LATIN SMALL LETTER DOTLESS I
  # $pre YYY $post ↔ ĸ ; # LATIN SMALL LETTER KRA
  # $pre YYY $post ↔ Ŀ ; # LATIN CAPITAL LETTER L WITH MIDDLE DOT
  # $pre YYY $post ↔ ŀ ; # LATIN SMALL LETTER L WITH MIDDLE DOT
  # $pre YYY $post ↔ Ł ; # LATIN CAPITAL LETTER L WITH STROKE
  # $pre YYY $post ↔ ł ; # LATIN SMALL LETTER L WITH STROKE
  # $pre YYY $post ↔ ŉ ; # LATIN SMALL LETTER N PRECEDED BY APOSTROPHE
  # $pre YYY $post ↔ Ŧ ; # LATIN CAPITAL LETTER T WITH STROKE
  # $pre YYY $post ↔ ŧ ; # LATIN SMALL LETTER T WITH STROKE
  # $pre YYY $post ↔ ſ ; # LATIN SMALL LETTER LONG S
  # $pre YYY $post ↔ ƀ ; # LATIN SMALL LETTER B WITH STROKE
  # $pre YYY $post ↔ Ɓ ; # LATIN CAPITAL LETTER B WITH HOOK
  # $pre YYY $post ↔ Ƃ ; # LATIN CAPITAL LETTER B WITH TOPBAR
  # $pre YYY $post ↔ ƃ ; # LATIN SMALL LETTER B WITH TOPBAR
  # $pre YYY $post ↔ Ƅ ; # LATIN CAPITAL LETTER TONE SIX
  # $pre YYY $post ↔ ƅ ; # LATIN SMALL LETTER TONE SIX
  # $pre YYY $post ↔ Ƈ ; # LATIN CAPITAL LETTER C WITH HOOK
  # $pre YYY $post ↔ ƈ ; # LATIN SMALL LETTER C WITH HOOK
  # $pre YYY $post ↔ Ɖ ; # LATIN CAPITAL LETTER AFRICAN D
  # $pre YYY $post ↔ Ɗ ; # LATIN CAPITAL LETTER D WITH HOOK
  # $pre YYY $post ↔ Ƌ ; # LATIN CAPITAL LETTER D WITH TOPBAR
  # $pre YYY $post ↔ ƌ ; # LATIN SMALL LETTER D WITH TOPBAR
  # $pre YYY $post ↔ ƍ ; # LATIN SMALL LETTER TURNED DELTA
  # $pre YYY $post ↔ Ǝ ; # LATIN CAPITAL LETTER REVERSED E
  # $pre YYY $post ↔ Ƒ ; # LATIN CAPITAL LETTER F WITH HOOK
  # $pre YYY $post ↔ ƒ ; # LATIN SMALL LETTER F WITH HOOK
  # $pre YYY $post ↔ Ɠ ; # LATIN CAPITAL LETTER G WITH HOOK
  # $pre YYY $post ↔ Ɣ ; # LATIN CAPITAL LETTER GAMMA
  # $pre YYY $post ↔ ƕ ; # LATIN SMALL LETTER HV
  # $pre YYY $post ↔ Ɩ ; # LATIN CAPITAL LETTER IOTA
  # $pre YYY $post ↔ Ɨ ; # LATIN CAPITAL LETTER I WITH STROKE
  # $pre YYY $post ↔ Ƙ ; # LATIN CAPITAL LETTER K WITH HOOK
  # $pre YYY $post ↔ ƙ ; # LATIN SMALL LETTER K WITH HOOK
  # $pre YYY $post ↔ ƚ ; # LATIN SMALL LETTER L WITH BAR
  # $pre YYY $post ↔ ƛ ; # LATIN SMALL LETTER LAMBDA WITH STROKE
  # $pre YYY $post ↔ Ɯ ; # LATIN CAPITAL LETTER TURNED M
  # $pre YYY $post ↔ Ɲ ; # LATIN CAPITAL LETTER N WITH LEFT HOOK
  # $pre YYY $post ↔ ƞ ; # LATIN SMALL LETTER N WITH LONG RIGHT LEG
  # $pre YYY $post ↔ Ɵ ; # LATIN CAPITAL LETTER O WITH MIDDLE TILDE
  # $pre YYY $post ↔ Ƣ ; # LATIN CAPITAL LETTER OI
  # $pre YYY $post ↔ ƣ ; # LATIN SMALL LETTER OI
  # $pre YYY $post ↔ Ƥ ; # LATIN CAPITAL LETTER P WITH HOOK
  # $pre YYY $post ↔ ƥ ; # LATIN SMALL LETTER P WITH HOOK
  # $pre YYY $post ↔ Ʀ ; # LATIN LETTER YR
  # $pre YYY $post ↔ Ƨ ; # LATIN CAPITAL LETTER TONE TWO
  # $pre YYY $post ↔ ƨ ; # LATIN SMALL LETTER TONE TWO
  # $pre YYY $post ↔ ƪ ; # LATIN LETTER REVERSED ESH LOOP
  # $pre YYY $post ↔ ƫ ; # LATIN SMALL LETTER T WITH PALATAL HOOK
  # $pre YYY $post ↔ Ƭ ; # LATIN CAPITAL LETTER T WITH HOOK
  # $pre YYY $post ↔ ƭ ; # LATIN SMALL LETTER T WITH HOOK
  # $pre YYY $post ↔ Ʈ ; # LATIN CAPITAL LETTER T WITH RETROFLEX HOOK
  # $pre YYY $post ↔ Ʋ ; # LATIN CAPITAL LETTER V WITH HOOK
  # $pre YYY $post ↔ Ƴ ; # LATIN CAPITAL LETTER Y WITH HOOK
  # $pre YYY $post ↔ ƴ ; # LATIN SMALL LETTER Y WITH HOOK
  # $pre YYY $post ↔ Ƶ ; # LATIN CAPITAL LETTER Z WITH STROKE
  # $pre YYY $post ↔ ƶ ; # LATIN SMALL LETTER Z WITH STROKE
  # $pre YYY $post ↔ Ƹ ; # LATIN CAPITAL LETTER EZH REVERSED
  # $pre YYY $post ↔ ƹ ; # LATIN SMALL LETTER EZH REVERSED
  # $pre YYY $post ↔ ƺ ; # LATIN SMALL LETTER EZH WITH TAIL
  # $pre YYY $post ↔ ƻ ; # LATIN LETTER TWO WITH STROKE
  # $pre YYY $post ↔ Ƽ ; # LATIN CAPITAL LETTER TONE FIVE
  # $pre YYY $post ↔ ƽ ; # LATIN SMALL LETTER TONE FIVE
  # $pre YYY $post ↔ ƾ ; # LATIN LETTER INVERTED GLOTTAL STOP WITH STROKE
  # $pre YYY $post ↔ ƿ ; # LATIN LETTER WYNN
  # $pre YYY $post ↔ ǀ ; # LATIN LETTER DENTAL CLICK
  # $pre YYY $post ↔ ǁ ; # LATIN LETTER LATERAL CLICK
  # $pre YYY $post ↔ ǂ ; # LATIN LETTER ALVEOLAR CLICK
  # $pre YYY $post ↔ ǃ ; # LATIN LETTER RETROFLEX CLICK
  # $pre YYY $post ↔ Ǆ ; # LATIN CAPITAL LETTER DZ WITH CARON
  # $pre YYY $post ↔ ǅ ; # LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON
  # $pre YYY $post ↔ ǆ ; # LATIN SMALL LETTER DZ WITH CARON
  # $pre YYY $post ↔ Ǉ ; # LATIN CAPITAL LETTER LJ
  # $pre YYY $post ↔ ǈ ; # LATIN CAPITAL LETTER L WITH SMALL LETTER J
  # $pre YYY $post ↔ ǉ ; # LATIN SMALL LETTER LJ
  # $pre YYY $post ↔ Ǌ ; # LATIN CAPITAL LETTER NJ
  # $pre YYY $post ↔ ǋ ; # LATIN CAPITAL LETTER N WITH SMALL LETTER J
  # $pre YYY $post ↔ ǌ ; # LATIN SMALL LETTER NJ
  # $pre YYY $post ↔ ǝ ; # LATIN SMALL LETTER TURNED E
  # $pre YYY $post ↔ Ǥ ; # LATIN CAPITAL LETTER G WITH STROKE
  # $pre YYY $post ↔ ǥ ; # LATIN SMALL LETTER G WITH STROKE
  # $pre YYY $post ↔ Ǳ ; # LATIN CAPITAL LETTER DZ
  # $pre YYY $post ↔ ǲ ; # LATIN CAPITAL LETTER D WITH SMALL LETTER Z
  # $pre YYY $post ↔ ǳ ; # LATIN SMALL LETTER DZ
  # $pre YYY $post ↔ Ƕ ; # LATIN CAPITAL LETTER HWAIR
  # $pre YYY $post ↔ Ƿ ; # LATIN CAPITAL LETTER WYNN
  # $pre YYY $post ↔ Ȝ ; # LATIN CAPITAL LETTER YOGH
  # $pre YYY $post ↔ ȝ ; # LATIN SMALL LETTER YOGH
  # $pre YYY $post ↔ Ȣ ; # LATIN CAPITAL LETTER OU
  # $pre YYY $post ↔ ȣ ; # LATIN SMALL LETTER OU
  # $pre YYY $post ↔ Ȥ ; # LATIN CAPITAL LETTER Z WITH HOOK
  # $pre YYY $post ↔ ȥ ; # LATIN SMALL LETTER Z WITH HOOK
  # $pre YYY $post ↔ ɐ ; # LATIN SMALL LETTER TURNED A
  # $pre YYY $post ↔ ɑ ; # LATIN SMALL LETTER ALPHA
  # $pre YYY $post ↔ ɒ ; # LATIN SMALL LETTER TURNED ALPHA
  # $pre YYY $post ↔ ɓ ; # LATIN SMALL LETTER B WITH HOOK
  # $pre YYY $post ↔ ɕ ; # LATIN SMALL LETTER C WITH CURL
  # $pre YYY $post ↔ ɖ ; # LATIN SMALL LETTER D WITH TAIL
  # $pre YYY $post ↔ ɗ ; # LATIN SMALL LETTER D WITH HOOK
  # $pre YYY $post ↔ ɘ ; # LATIN SMALL LETTER REVERSED E
  # $pre YYY $post ↔ ɚ ; # LATIN SMALL LETTER SCHWA WITH HOOK
  # $pre YYY $post ↔ ɜ ; # LATIN SMALL LETTER REVERSED OPEN E
  # $pre YYY $post ↔ ɝ ; # LATIN SMALL LETTER REVERSED OPEN E WITH HOOK
  # $pre YYY $post ↔ ɞ ; # LATIN SMALL LETTER CLOSED REVERSED OPEN E
  # $pre YYY $post ↔ ɟ ; # LATIN SMALL LETTER DOTLESS J WITH STROKE
  # $pre YYY $post ↔ ɠ ; # LATIN SMALL LETTER G WITH HOOK
  # $pre YYY $post ↔ ɡ ; # LATIN SMALL LETTER SCRIPT G
  # $pre YYY $post ↔ ɢ ; # LATIN LETTER SMALL CAPITAL G
  # $pre YYY $post ↔ ɣ ; # LATIN SMALL LETTER GAMMA
  # $pre YYY $post ↔ ɤ ; # LATIN SMALL LETTER RAMS HORN
  # $pre YYY $post ↔ ɥ ; # LATIN SMALL LETTER TURNED H
  # $pre YYY $post ↔ ɦ ; # LATIN SMALL LETTER H WITH HOOK
  # $pre YYY $post ↔ ɧ ; # LATIN SMALL LETTER HENG WITH HOOK
  # $pre YYY $post ↔ ɨ ; # LATIN SMALL LETTER I WITH STROKE
  # $pre YYY $post ↔ ɩ ; # LATIN SMALL LETTER IOTA
  # $pre YYY $post ↔ ɫ ; # LATIN SMALL LETTER L WITH MIDDLE TILDE
  # $pre YYY $post ↔ ɬ ; # LATIN SMALL LETTER L WITH BELT
  # $pre YYY $post ↔ ɭ ; # LATIN SMALL LETTER L WITH RETROFLEX HOOK
  # $pre YYY $post ↔ ɮ ; # LATIN SMALL LETTER LEZH
  # $pre YYY $post ↔ ɯ ; # LATIN SMALL LETTER TURNED M
  # $pre YYY $post ↔ ɰ ; # LATIN SMALL LETTER TURNED M WITH LONG LEG
  # $pre YYY $post ↔ ɱ ; # LATIN SMALL LETTER M WITH HOOK
  # $pre YYY $post ↔ ɲ ; # LATIN SMALL LETTER N WITH LEFT HOOK
  # $pre YYY $post ↔ ɳ ; # LATIN SMALL LETTER N WITH RETROFLEX HOOK
  # $pre YYY $post ↔ ɴ ; # LATIN LETTER SMALL CAPITAL N
  # $pre YYY $post ↔ ɵ ; # LATIN SMALL LETTER BARRED O
  # $pre YYY $post ↔ ɶ ; # LATIN LETTER SMALL CAPITAL OE
  # $pre YYY $post ↔ ɷ ; # LATIN SMALL LETTER CLOSED OMEGA
  # $pre YYY $post ↔ ɸ ; # LATIN SMALL LETTER PHI
  # $pre YYY $post ↔ ɹ ; # LATIN SMALL LETTER TURNED R
  # $pre YYY $post ↔ ɺ ; # LATIN SMALL LETTER TURNED R WITH LONG LEG
  # $pre YYY $post ↔ ɻ ; # LATIN SMALL LETTER TURNED R WITH HOOK
  # $pre YYY $post ↔ ɼ ; # LATIN SMALL LETTER R WITH LONG LEG
  # $pre YYY $post ↔ ɽ ; # LATIN SMALL LETTER R WITH TAIL
  # $pre YYY $post ↔ ɾ ; # LATIN SMALL LETTER R WITH FISHHOOK
  # $pre YYY $post ↔ ɿ ; # LATIN SMALL LETTER REVERSED R WITH FISHHOOK
  # $pre YYY $post ↔ ʀ ; # LATIN LETTER SMALL CAPITAL R
  # $pre YYY $post ↔ ʁ ; # LATIN LETTER SMALL CAPITAL INVERTED R
  # $pre YYY $post ↔ ʂ ; # LATIN SMALL LETTER S WITH HOOK
  # $pre YYY $post ↔ ʄ ; # LATIN SMALL LETTER DOTLESS J WITH STROKE AND HOOK
  # $pre YYY $post ↔ ʅ ; # LATIN SMALL LETTER SQUAT REVERSED ESH
  # $pre YYY $post ↔ ʆ ; # LATIN SMALL LETTER ESH WITH CURL
  # $pre YYY $post ↔ ʇ ; # LATIN SMALL LETTER TURNED T
  # $pre YYY $post ↔ ʈ ; # LATIN SMALL LETTER T WITH RETROFLEX HOOK
  # $pre YYY $post ↔ ʉ ; # LATIN SMALL LETTER U BAR
  # $pre YYY $post ↔ ʋ ; # LATIN SMALL LETTER V WITH HOOK
  # $pre YYY $post ↔ ʍ ; # LATIN SMALL LETTER TURNED W
  # $pre YYY $post ↔ ʎ ; # LATIN SMALL LETTER TURNED Y
  # $pre YYY $post ↔ ʏ ; # LATIN LETTER SMALL CAPITAL Y
  # $pre YYY $post ↔ ʐ ; # LATIN SMALL LETTER Z WITH RETROFLEX HOOK
  # $pre YYY $post ↔ ʑ ; # LATIN SMALL LETTER Z WITH CURL
  # $pre YYY $post ↔ ʓ ; # LATIN SMALL LETTER EZH WITH CURL
  # $pre YYY $post ↔ ʔ ; # LATIN LETTER GLOTTAL STOP
  # $pre YYY $post ↔ ʕ ; # LATIN LETTER PHARYNGEAL VOICED FRICATIVE
  # $pre YYY $post ↔ ʖ ; # LATIN LETTER INVERTED GLOTTAL STOP
  # $pre YYY $post ↔ ʗ ; # LATIN LETTER STRETCHED C
  # $pre YYY $post ↔ ʘ ; # LATIN LETTER BILABIAL CLICK
  # $pre YYY $post ↔ ʙ ; # LATIN LETTER SMALL CAPITAL B
  # $pre YYY $post ↔ ʚ ; # LATIN SMALL LETTER CLOSED OPEN E
  # $pre YYY $post ↔ ʛ ; # LATIN LETTER SMALL CAPITAL G WITH HOOK
  # $pre YYY $post ↔ ʜ ; # LATIN LETTER SMALL CAPITAL H
  # $pre YYY $post ↔ ʝ ; # LATIN SMALL LETTER J WITH CROSSED-TAIL
  # $pre YYY $post ↔ ʞ ; # LATIN SMALL LETTER TURNED K
  # $pre YYY $post ↔ ʟ ; # LATIN LETTER SMALL CAPITAL L
  # $pre YYY $post ↔ ʠ ; # LATIN SMALL LETTER Q WITH HOOK
  # $pre YYY $post ↔ ʡ ; # LATIN LETTER GLOTTAL STOP WITH STROKE
  # $pre YYY $post ↔ ʢ ; # LATIN LETTER REVERSED GLOTTAL STOP WITH STROKE
  # $pre YYY $post ↔ ʣ ; # LATIN SMALL LETTER DZ DIGRAPH
  # $pre YYY $post ↔ ʤ ; # LATIN SMALL LETTER DEZH DIGRAPH
  # $pre YYY $post ↔ ʥ ; # LATIN SMALL LETTER DZ DIGRAPH WITH CURL
  # $pre YYY $post ↔ ʦ ; # LATIN SMALL LETTER TS DIGRAPH
  # $pre YYY $post ↔ ʧ ; # LATIN SMALL LETTER TESH DIGRAPH
  # $pre YYY $post ↔ ʨ ; # LATIN SMALL LETTER TC DIGRAPH WITH CURL
  # $pre YYY $post ↔ ʩ ; # LATIN SMALL LETTER FENG DIGRAPH
  # $pre YYY $post ↔ ʪ ; # LATIN SMALL LETTER LS DIGRAPH
  # $pre YYY $post ↔ ʫ ; # LATIN SMALL LETTER LZ DIGRAPH
  # $pre YYY $post ↔ ʬ ; # LATIN LETTER BILABIAL PERCUSSIVE
  # $pre YYY $post ↔ ʭ ; # LATIN LETTER BIDENTAL PERCUSSIVE
  # $pre YYY $post ↔ ʰ ; # MODIFIER LETTER SMALL H
  # $pre YYY $post ↔ ʱ ; # MODIFIER LETTER SMALL H WITH HOOK
  # $pre YYY $post ↔ ʲ ; # MODIFIER LETTER SMALL J
  # $pre YYY $post ↔ ʳ ; # MODIFIER LETTER SMALL R
  # $pre YYY $post ↔ ʴ ; # MODIFIER LETTER SMALL TURNED R
  # $pre YYY $post ↔ ʵ ; # MODIFIER LETTER SMALL TURNED R WITH HOOK
  # $pre YYY $post ↔ ʶ ; # MODIFIER LETTER SMALL CAPITAL INVERTED R
  # $pre YYY $post ↔ ʷ ; # MODIFIER LETTER SMALL W
  # $pre YYY $post ↔ ʸ ; # MODIFIER LETTER SMALL Y
  # $pre YYY $post ↔ ˠ ; # MODIFIER LETTER SMALL GAMMA
  # $pre YYY $post ↔ ˡ ; # MODIFIER LETTER SMALL L
  # $pre YYY $post ↔ ˢ ; # MODIFIER LETTER SMALL S
  # $pre YYY $post ↔ ˣ ; # MODIFIER LETTER SMALL X
  # $pre YYY $post ↔ ˤ ; # MODIFIER LETTER SMALL REVERSED GLOTTAL STOP
  # $pre YYY $post ↔ ẚ ; # LATIN SMALL LETTER A WITH RIGHT HALF RING
  # $pre YYY $post ↔ ⁿ ; # SUPERSCRIPT LATIN SMALL LETTER N
  #
  transform("NFC")
  #
end