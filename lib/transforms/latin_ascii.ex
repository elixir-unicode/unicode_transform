defmodule Unicode.Transform.LatinAscii do
  use Unicode.Transform

  # This file is generated. Manual changes are not recommended
  # Source: Latin
  # Target: ASCII
  # Transform direction: both
  # Transform alias: und-t-und-latn-d0-ascii

  #
  # This handles only Latin, Common, and IDEOGRAPHIC NUMBER ZERO (Han).
  #
  #
  filter("[[:Latin:][:Common:][:Inherited:][〇]]")
  #
  # Don't want NFKD, because that would convert things like superscripts and
  # subscripts, which we do not want. So the individual transforms below
  # include an appropriate subset of the NFKD ones.
  # Here we remove accents from Latin characters or digits. We then recompose to permit rules
  # such as mapping NOT EQUAL TO to an ASCII equivalent e.g. "!=" if we choose to.
  #
  #
  transform("NFD")
  # maps to nothing; remove all Mn following Latin letter/digit
  replace("[:Mn:]+", "", preceeded_by: "[[:Latin:][0-9]]")
  #
  transform("NFC")
  #
  # Some of the following mappings (noted) are from CLDR ‹character-fallback› data.
  # (Note, here "‹character-fallback›" uses U+2039/U+203A to avoid XML issues)
  #
  # Latin letters and IPA
  #
  # 00C6;LATIN CAPITAL LETTER AE (from ‹character-fallback›)
  replace("Æ", "AE")
  # 00D0;LATIN CAPITAL LETTER ETH
  replace("Ð", "D")
  # 00D8;LATIN CAPITAL LETTER O WITH STROKE
  replace("Ø", "O")
  # 00DE;LATIN CAPITAL LETTER THORN
  replace("Þ", "TH")
  # 00DF;LATIN SMALL LETTER SHARP S (from ‹character-fallback›)
  replace("ß", "ss")
  # 00E6;LATIN SMALL LETTER AE (from ‹character-fallback›)
  replace("æ", "ae")
  # 00F0;LATIN SMALL LETTER ETH
  replace("ð", "d")
  # 00F8;LATIN SMALL LETTER O WITH STROKE
  replace("ø", "o")
  # 00FE;LATIN SMALL LETTER THORN
  replace("þ", "th")
  # 0110;LATIN CAPITAL LETTER D WITH STROKE
  replace("Đ", "D")
  # 0111;LATIN SMALL LETTER D WITH STROKE
  replace("đ", "d")
  # 0126;LATIN CAPITAL LETTER H WITH STROKE
  replace("Ħ", "H")
  # 0127;LATIN SMALL LETTER H WITH STROKE
  replace("ħ", "h")
  # 0131;LATIN SMALL LETTER DOTLESS I
  replace("ı", "i")
  # 0132;LATIN CAPITAL LIGATURE IJ (compat)
  replace("Ĳ", "IJ")
  # 0133;LATIN SMALL LIGATURE IJ (compat)
  replace("ĳ", "ij")
  # 0138;LATIN SMALL LETTER KRA (collates with q in DUCET)
  replace("ĸ", "q")
  # 013F;LATIN CAPITAL LETTER L WITH MIDDLE DOT (compat)
  replace("Ŀ", "L")
  # 0140;LATIN SMALL LETTER L WITH MIDDLE DOT (compat)
  replace("ŀ", "l")
  # 0141;LATIN CAPITAL LETTER L WITH STROKE
  replace("Ł", "L")
  # 0142;LATIN SMALL LETTER L WITH STROKE
  replace("ł", "l")
  # 0149;LATIN SMALL LETTER N PRECEDED BY APOSTROPHE (from ‹character-fallback›)
  replace("ŉ", "\'n")
  # 014A;LATIN CAPITAL LETTER ENG
  replace("Ŋ", "N")
  # 014B;LATIN SMALL LETTER ENG
  replace("ŋ", "n")
  # 0152;LATIN CAPITAL LIGATURE OE (from ‹character-fallback›)
  replace("Œ", "OE")
  # 0153;LATIN SMALL LIGATURE OE (from ‹character-fallback›)
  replace("œ", "oe")
  # 0166;LATIN CAPITAL LETTER T WITH STROKE
  replace("Ŧ", "T")
  # 0167;LATIN SMALL LETTER T WITH STROKE
  replace("ŧ", "t")
  # 017F;LATIN SMALL LETTER LONG S (compat)
  replace("ſ", "s")
  # 0180;LATIN SMALL LETTER B WITH STROKE
  replace("ƀ", "b")
  # 0181;LATIN CAPITAL LETTER B WITH HOOK
  replace("Ɓ", "B")
  # 0182;LATIN CAPITAL LETTER B WITH TOPBAR
  replace("Ƃ", "B")
  # 0183;LATIN SMALL LETTER B WITH TOPBAR
  replace("ƃ", "b")
  # 0187;LATIN CAPITAL LETTER C WITH HOOK
  replace("Ƈ", "C")
  # 0188;LATIN SMALL LETTER C WITH HOOK
  replace("ƈ", "c")
  # 0189;LATIN CAPITAL LETTER AFRICAN D
  replace("Ɖ", "D")
  # 018A;LATIN CAPITAL LETTER D WITH HOOK
  replace("Ɗ", "D")
  # 018B;LATIN CAPITAL LETTER D WITH TOPBAR
  replace("Ƌ", "D")
  # 018C;LATIN SMALL LETTER D WITH TOPBAR
  replace("ƌ", "d")
  # 0190;LATIN CAPITAL LETTER OPEN E
  replace("Ɛ", "E")
  # 0191;LATIN CAPITAL LETTER F WITH HOOK
  replace("Ƒ", "F")
  # 0192;LATIN SMALL LETTER F WITH HOOK
  replace("ƒ", "f")
  # 0193;LATIN CAPITAL LETTER G WITH HOOK
  replace("Ɠ", "G")
  # 0195;LATIN SMALL LETTER HV
  replace("ƕ", "hv")
  # 0196;LATIN CAPITAL LETTER IOTA
  replace("Ɩ", "I")
  # 0197;LATIN CAPITAL LETTER I WITH STROKE
  replace("Ɨ", "I")
  # 0198;LATIN CAPITAL LETTER K WITH HOOK
  replace("Ƙ", "K")
  # 0199;LATIN SMALL LETTER K WITH HOOK
  replace("ƙ", "k")
  # 019A;LATIN SMALL LETTER L WITH BAR
  replace("ƚ", "l")
  # 019D;LATIN CAPITAL LETTER N WITH LEFT HOOK
  replace("Ɲ", "N")
  # 019E;LATIN SMALL LETTER N WITH LONG RIGHT LEG
  replace("ƞ", "n")
  # 01A2;LATIN CAPITAL LETTER OI
  replace("Ƣ", "OI")
  # 01A3;LATIN SMALL LETTER OI
  replace("ƣ", "oi")
  # 01A4;LATIN CAPITAL LETTER P WITH HOOK
  replace("Ƥ", "P")
  # 01A5;LATIN SMALL LETTER P WITH HOOK
  replace("ƥ", "p")
  # 01AB;LATIN SMALL LETTER T WITH PALATAL HOOK
  replace("ƫ", "t")
  # 01AC;LATIN CAPITAL LETTER T WITH HOOK
  replace("Ƭ", "T")
  # 01AD;LATIN SMALL LETTER T WITH HOOK
  replace("ƭ", "t")
  # 01AE;LATIN CAPITAL LETTER T WITH RETROFLEX HOOK
  replace("Ʈ", "T")
  # 01B2;LATIN CAPITAL LETTER V WITH HOOK
  replace("Ʋ", "V")
  # 01B3;LATIN CAPITAL LETTER Y WITH HOOK
  replace("Ƴ", "Y")
  # 01B4;LATIN SMALL LETTER Y WITH HOOK
  replace("ƴ", "y")
  # 01B5;LATIN CAPITAL LETTER Z WITH STROKE
  replace("Ƶ", "Z")
  # 01B6;LATIN SMALL LETTER Z WITH STROKE
  replace("ƶ", "z")
  # 01C4;LATIN CAPITAL LETTER DZ WITH CARON (compat)
  replace("Ǆ", "DZ")
  # 01C5;LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON (compat)
  replace("ǅ", "Dz")
  # 01C6;LATIN SMALL LETTER DZ WITH CARON (compat)
  replace("ǆ", "dz")
  # 01C7;LATIN CAPITAL LETTER LJ (compat)
  replace("Ǉ", "LJ")
  # 01C8;LATIN CAPITAL LETTER L WITH SMALL LETTER J (compat)
  replace("ǈ", "Lj")
  # 01C9;LATIN SMALL LETTER LJ (compat)
  replace("ǉ", "lj")
  # 01CA;LATIN CAPITAL LETTER NJ (compat)
  replace("Ǌ", "NJ")
  # 01CB;LATIN CAPITAL LETTER N WITH SMALL LETTER J (compat)
  replace("ǋ", "Nj")
  # 01CC;LATIN SMALL LETTER NJ (compat)
  replace("ǌ", "nj")
  # 01E4;LATIN CAPITAL LETTER G WITH STROKE
  replace("Ǥ", "G")
  # 01E5;LATIN SMALL LETTER G WITH STROKE
  replace("ǥ", "g")
  # 01F1;LATIN CAPITAL LETTER DZ (compat)
  replace("Ǳ", "DZ")
  # 01F2;LATIN CAPITAL LETTER D WITH SMALL LETTER Z (compat)
  replace("ǲ", "Dz")
  # 01F3;LATIN SMALL LETTER DZ (compat)
  replace("ǳ", "dz")
  # 0221;LATIN SMALL LETTER D WITH CURL
  replace("ȡ", "d")
  # 0224;LATIN CAPITAL LETTER Z WITH HOOK
  replace("Ȥ", "Z")
  # 0225;LATIN SMALL LETTER Z WITH HOOK
  replace("ȥ", "z")
  # 0234;LATIN SMALL LETTER L WITH CURL
  replace("ȴ", "l")
  # 0235;LATIN SMALL LETTER N WITH CURL
  replace("ȵ", "n")
  # 0236;LATIN SMALL LETTER T WITH CURL
  replace("ȶ", "t")
  # 0237;LATIN SMALL LETTER DOTLESS J
  replace("ȷ", "j")
  # 0238;LATIN SMALL LETTER DB DIGRAPH
  replace("ȸ", "db")
  # 0239;LATIN SMALL LETTER QP DIGRAPH
  replace("ȹ", "qp")
  # 023A;LATIN CAPITAL LETTER A WITH STROKE
  replace("Ⱥ", "A")
  # 023B;LATIN CAPITAL LETTER C WITH STROKE
  replace("Ȼ", "C")
  # 023C;LATIN SMALL LETTER C WITH STROKE
  replace("ȼ", "c")
  # 023D;LATIN CAPITAL LETTER L WITH BAR
  replace("Ƚ", "L")
  # 023E;LATIN CAPITAL LETTER T WITH DIAGONAL STROKE
  replace("Ⱦ", "T")
  # 023F;LATIN SMALL LETTER S WITH SWASH TAIL
  replace("ȿ", "s")
  # 0240;LATIN SMALL LETTER Z WITH SWASH TAIL
  replace("ɀ", "z")
  # 0243;LATIN CAPITAL LETTER B WITH STROKE
  replace("Ƀ", "B")
  # 0244;LATIN CAPITAL LETTER U BAR
  replace("Ʉ", "U")
  # 0246;LATIN CAPITAL LETTER E WITH STROKE
  replace("Ɇ", "E")
  # 0247;LATIN SMALL LETTER E WITH STROKE
  replace("ɇ", "e")
  # 0248;LATIN CAPITAL LETTER J WITH STROKE
  replace("Ɉ", "J")
  # 0249;LATIN SMALL LETTER J WITH STROKE
  replace("ɉ", "j")
  # 024C;LATIN CAPITAL LETTER R WITH STROKE
  replace("Ɍ", "R")
  # 024D;LATIN SMALL LETTER R WITH STROKE
  replace("ɍ", "r")
  # 024E;LATIN CAPITAL LETTER Y WITH STROKE
  replace("Ɏ", "Y")
  # 024F;LATIN SMALL LETTER Y WITH STROKE
  replace("ɏ", "y")
  # 0253;LATIN SMALL LETTER B WITH HOOK
  replace("ɓ", "b")
  # 0255;LATIN SMALL LETTER C WITH CURL
  replace("ɕ", "c")
  # 0256;LATIN SMALL LETTER D WITH TAIL
  replace("ɖ", "d")
  # 0257;LATIN SMALL LETTER D WITH HOOK
  replace("ɗ", "d")
  # 025B;LATIN SMALL LETTER OPEN E
  replace("ɛ", "e")
  # 025F;LATIN SMALL LETTER DOTLESS J WITH STROKE
  replace("ɟ", "j")
  # 0260;LATIN SMALL LETTER G WITH HOOK
  replace("ɠ", "g")
  # 0261;LATIN SMALL LETTER SCRIPT G
  replace("ɡ", "g")
  # 0262;LATIN LETTER SMALL CAPITAL G
  replace("ɢ", "G")
  # 0266;LATIN SMALL LETTER H WITH HOOK
  replace("ɦ", "h")
  # 0267;LATIN SMALL LETTER HENG WITH HOOK
  replace("ɧ", "h")
  # 0268;LATIN SMALL LETTER I WITH STROKE
  replace("ɨ", "i")
  # 026A;LATIN LETTER SMALL CAPITAL I
  replace("ɪ", "I")
  # 026B;LATIN SMALL LETTER L WITH MIDDLE TILDE
  replace("ɫ", "l")
  # 026C;LATIN SMALL LETTER L WITH BELT
  replace("ɬ", "l")
  # 026D;LATIN SMALL LETTER L WITH RETROFLEX HOOK
  replace("ɭ", "l")
  # 0271;LATIN SMALL LETTER M WITH HOOK
  replace("ɱ", "m")
  # 0272;LATIN SMALL LETTER N WITH LEFT HOOK
  replace("ɲ", "n")
  # 0273;LATIN SMALL LETTER N WITH RETROFLEX HOOK
  replace("ɳ", "n")
  # 0274;LATIN LETTER SMALL CAPITAL N
  replace("ɴ", "N")
  # 0276;LATIN LETTER SMALL CAPITAL OE
  replace("ɶ", "OE")
  # 027C;LATIN SMALL LETTER R WITH LONG LEG
  replace("ɼ", "r")
  # 027D;LATIN SMALL LETTER R WITH TAIL
  replace("ɽ", "r")
  # 027E;LATIN SMALL LETTER R WITH FISHHOOK
  replace("ɾ", "r")
  # 0280;LATIN LETTER SMALL CAPITAL R
  replace("ʀ", "R")
  # 0282;LATIN SMALL LETTER S WITH HOOK
  replace("ʂ", "s")
  # 0288;LATIN SMALL LETTER T WITH RETROFLEX HOOK
  replace("ʈ", "t")
  # 0289;LATIN SMALL LETTER U BAR
  replace("ʉ", "u")
  # 028B;LATIN SMALL LETTER V WITH HOOK
  replace("ʋ", "v")
  # 028F;LATIN LETTER SMALL CAPITAL Y
  replace("ʏ", "Y")
  # 0290;LATIN SMALL LETTER Z WITH RETROFLEX HOOK
  replace("ʐ", "z")
  # 0291;LATIN SMALL LETTER Z WITH CURL
  replace("ʑ", "z")
  # 0299;LATIN LETTER SMALL CAPITAL B
  replace("ʙ", "B")
  # 029B;LATIN LETTER SMALL CAPITAL G WITH HOOK
  replace("ʛ", "G")
  # 029C;LATIN LETTER SMALL CAPITAL H
  replace("ʜ", "H")
  # 029D;LATIN SMALL LETTER J WITH CROSSED-TAIL
  replace("ʝ", "j")
  # 029F;LATIN LETTER SMALL CAPITAL L
  replace("ʟ", "L")
  # 02A0;LATIN SMALL LETTER Q WITH HOOK
  replace("ʠ", "q")
  # 02A3;LATIN SMALL LETTER DZ DIGRAPH
  replace("ʣ", "dz")
  # 02A5;LATIN SMALL LETTER DZ DIGRAPH WITH CURL
  replace("ʥ", "dz")
  # 02A6;LATIN SMALL LETTER TS DIGRAPH
  replace("ʦ", "ts")
  # 02AA;LATIN SMALL LETTER LS DIGRAPH
  replace("ʪ", "ls")
  # 02AB;LATIN SMALL LETTER LZ DIGRAPH
  replace("ʫ", "lz")
  # 1D00;LATIN LETTER SMALL CAPITAL A
  replace("ᴀ", "A")
  # 1D01;LATIN LETTER SMALL CAPITAL AE
  replace("ᴁ", "AE")
  # 1D03;LATIN LETTER SMALL CAPITAL BARRED B
  replace("ᴃ", "B")
  # 1D04;LATIN LETTER SMALL CAPITAL C
  replace("ᴄ", "C")
  # 1D05;LATIN LETTER SMALL CAPITAL D
  replace("ᴅ", "D")
  # 1D06;LATIN LETTER SMALL CAPITAL ETH
  replace("ᴆ", "D")
  # 1D07;LATIN LETTER SMALL CAPITAL E
  replace("ᴇ", "E")
  # 1D0A;LATIN LETTER SMALL CAPITAL J
  replace("ᴊ", "J")
  # 1D0B;LATIN LETTER SMALL CAPITAL K
  replace("ᴋ", "K")
  # 1D0C;LATIN LETTER SMALL CAPITAL L WITH STROKE
  replace("ᴌ", "L")
  # 1D0D;LATIN LETTER SMALL CAPITAL M
  replace("ᴍ", "M")
  # 1D0F;LATIN LETTER SMALL CAPITAL O
  replace("ᴏ", "O")
  # 1D18;LATIN LETTER SMALL CAPITAL P
  replace("ᴘ", "P")
  # 1D1B;LATIN LETTER SMALL CAPITAL T
  replace("ᴛ", "T")
  # 1D1C;LATIN LETTER SMALL CAPITAL U
  replace("ᴜ", "U")
  # 1D20;LATIN LETTER SMALL CAPITAL V
  replace("ᴠ", "V")
  # 1D21;LATIN LETTER SMALL CAPITAL W
  replace("ᴡ", "W")
  # 1D22;LATIN LETTER SMALL CAPITAL Z
  replace("ᴢ", "Z")
  # 1D6B;LATIN SMALL LETTER UE
  replace("ᵫ", "ue")
  # 1D6C;LATIN SMALL LETTER B WITH MIDDLE TILDE
  replace("ᵬ", "b")
  # 1D6D;LATIN SMALL LETTER D WITH MIDDLE TILDE
  replace("ᵭ", "d")
  # 1D6E;LATIN SMALL LETTER F WITH MIDDLE TILDE
  replace("ᵮ", "f")
  # 1D6F;LATIN SMALL LETTER M WITH MIDDLE TILDE
  replace("ᵯ", "m")
  # 1D70;LATIN SMALL LETTER N WITH MIDDLE TILDE
  replace("ᵰ", "n")
  # 1D71;LATIN SMALL LETTER P WITH MIDDLE TILDE
  replace("ᵱ", "p")
  # 1D72;LATIN SMALL LETTER R WITH MIDDLE TILDE
  replace("ᵲ", "r")
  # 1D73;LATIN SMALL LETTER R WITH FISHHOOK AND MIDDLE TILDE
  replace("ᵳ", "r")
  # 1D74;LATIN SMALL LETTER S WITH MIDDLE TILDE
  replace("ᵴ", "s")
  # 1D75;LATIN SMALL LETTER T WITH MIDDLE TILDE
  replace("ᵵ", "t")
  # 1D76;LATIN SMALL LETTER Z WITH MIDDLE TILDE
  replace("ᵶ", "z")
  # 1D7A;LATIN SMALL LETTER TH WITH STRIKETHROUGH
  replace("ᵺ", "th")
  # 1D7B;LATIN SMALL CAPITAL LETTER I WITH STROKE
  replace("ᵻ", "I")
  # 1D7D;LATIN SMALL LETTER P WITH STROKE
  replace("ᵽ", "p")
  # 1D7E;LATIN SMALL CAPITAL LETTER U WITH STROKE
  replace("ᵾ", "U")
  # 1D80;LATIN SMALL LETTER B WITH PALATAL HOOK
  replace("ᶀ", "b")
  # 1D81;LATIN SMALL LETTER D WITH PALATAL HOOK
  replace("ᶁ", "d")
  # 1D82;LATIN SMALL LETTER F WITH PALATAL HOOK
  replace("ᶂ", "f")
  # 1D83;LATIN SMALL LETTER G WITH PALATAL HOOK
  replace("ᶃ", "g")
  # 1D84;LATIN SMALL LETTER K WITH PALATAL HOOK
  replace("ᶄ", "k")
  # 1D85;LATIN SMALL LETTER L WITH PALATAL HOOK
  replace("ᶅ", "l")
  # 1D86;LATIN SMALL LETTER M WITH PALATAL HOOK
  replace("ᶆ", "m")
  # 1D87;LATIN SMALL LETTER N WITH PALATAL HOOK
  replace("ᶇ", "n")
  # 1D88;LATIN SMALL LETTER P WITH PALATAL HOOK
  replace("ᶈ", "p")
  # 1D89;LATIN SMALL LETTER R WITH PALATAL HOOK
  replace("ᶉ", "r")
  # 1D8A;LATIN SMALL LETTER S WITH PALATAL HOOK
  replace("ᶊ", "s")
  # 1D8C;LATIN SMALL LETTER V WITH PALATAL HOOK
  replace("ᶌ", "v")
  # 1D8D;LATIN SMALL LETTER X WITH PALATAL HOOK
  replace("ᶍ", "x")
  # 1D8E;LATIN SMALL LETTER Z WITH PALATAL HOOK
  replace("ᶎ", "z")
  # 1D8F;LATIN SMALL LETTER A WITH RETROFLEX HOOK
  replace("ᶏ", "a")
  # 1D91;LATIN SMALL LETTER D WITH HOOK AND TAIL
  replace("ᶑ", "d")
  # 1D92;LATIN SMALL LETTER E WITH RETROFLEX HOOK
  replace("ᶒ", "e")
  # 1D93;LATIN SMALL LETTER OPEN E WITH RETROFLEX HOOK
  replace("ᶓ", "e")
  # 1D96;LATIN SMALL LETTER I WITH RETROFLEX HOOK
  replace("ᶖ", "i")
  # 1D99;LATIN SMALL LETTER U WITH RETROFLEX HOOK
  replace("ᶙ", "u")
  # 1E9A;LATIN SMALL LETTER A WITH RIGHT HALF RING
  replace("ẚ", "a")
  # 1E9C;LATIN SMALL LETTER LONG S WITH DIAGONAL STROKE
  replace("ẜ", "s")
  # 1E9D;LATIN SMALL LETTER LONG S WITH HIGH STROKE
  replace("ẝ", "s")
  # 1E9E;LATIN CAPITAL LETTER SHARP S
  replace("ẞ", "SS")
  # 1EFA;LATIN CAPITAL LETTER MIDDLE-WELSH LL
  replace("Ỻ", "LL")
  # 1EFB;LATIN SMALL LETTER MIDDLE-WELSH LL
  replace("ỻ", "ll")
  # 1EFC;LATIN CAPITAL LETTER MIDDLE-WELSH V
  replace("Ỽ", "V")
  # 1EFD;LATIN SMALL LETTER MIDDLE-WELSH V
  replace("ỽ", "v")
  # 1EFE;LATIN CAPITAL LETTER Y WITH LOOP
  replace("Ỿ", "Y")
  # 1EFF;LATIN SMALL LETTER Y WITH LOOP
  replace("ỿ", "y")
  # Latin extended C and D (later addition)
  # 2C60;LATIN CAPITAL LETTER L WITH DOUBLE BAR
  replace("Ⱡ", "L")
  # 2C61;LATIN SMALL LETTER L WITH DOUBLE BAR
  replace("ⱡ", "l")
  # 2C62;LATIN CAPITAL LETTER L WITH MIDDLE TILDE
  replace("Ɫ", "L")
  # 2C63;LATIN CAPITAL LETTER P WITH STROKE
  replace("Ᵽ", "P")
  # 2C64;LATIN CAPITAL LETTER R WITH TAIL
  replace("Ɽ", "R")
  # 2C65;LATIN SMALL LETTER A WITH STROKE
  replace("ⱥ", "a")
  # 2C66;LATIN SMALL LETTER T WITH DIAGONAL STROKE
  replace("ⱦ", "t")
  # 2C67;LATIN CAPITAL LETTER H WITH DESCENDER
  replace("Ⱨ", "H")
  # 2C68;LATIN SMALL LETTER H WITH DESCENDER
  replace("ⱨ", "h")
  # 2C69;LATIN CAPITAL LETTER K WITH DESCENDER
  replace("Ⱪ", "K")
  # 2C6A;LATIN SMALL LETTER K WITH DESCENDER
  replace("ⱪ", "k")
  # 2C6B;LATIN CAPITAL LETTER Z WITH DESCENDER
  replace("Ⱬ", "Z")
  # 2C6C;LATIN SMALL LETTER Z WITH DESCENDER
  replace("ⱬ", "z")
  # 2C6E;LATIN CAPITAL LETTER M WITH HOOK
  replace("Ɱ", "M")
  # 2C71;LATIN SMALL LETTER V WITH RIGHT HOOK
  replace("ⱱ", "v")
  # 2C72;LATIN CAPITAL LETTER W WITH HOOK
  replace("Ⱳ", "W")
  # 2C73;LATIN SMALL LETTER W WITH HOOK
  replace("ⱳ", "w")
  # 2C74;LATIN SMALL LETTER V WITH CURL
  replace("ⱴ", "v")
  # 2C78;LATIN SMALL LETTER E WITH NOTCH
  replace("ⱸ", "e")
  # 2C7A;LATIN SMALL LETTER O WITH LOW RING INSIDE
  replace("ⱺ", "o")
  # 2C7E;LATIN CAPITAL LETTER S WITH SWASH TAIL
  replace("Ȿ", "S")
  # 2C7F;LATIN CAPITAL LETTER Z WITH SWASH TAIL
  replace("Ɀ", "Z")
  # A730;LATIN LETTER SMALL CAPITAL F
  replace("ꜰ", "F")
  # A731;LATIN LETTER SMALL CAPITAL S
  replace("ꜱ", "S")
  # A732;LATIN CAPITAL LETTER AA
  replace("Ꜳ", "AA")
  # A733;LATIN SMALL LETTER AA
  replace("ꜳ", "aa")
  # A734;LATIN CAPITAL LETTER AO
  replace("Ꜵ", "AO")
  # A735;LATIN SMALL LETTER AO
  replace("ꜵ", "ao")
  # A736;LATIN CAPITAL LETTER AU
  replace("Ꜷ", "AU")
  # A737;LATIN SMALL LETTER AU
  replace("ꜷ", "au")
  # A738;LATIN CAPITAL LETTER AV
  replace("Ꜹ", "AV")
  # A739;LATIN SMALL LETTER AV
  replace("ꜹ", "av")
  # A73A;LATIN CAPITAL LETTER AV WITH HORIZONTAL BAR
  replace("Ꜻ", "AV")
  # A73B;LATIN SMALL LETTER AV WITH HORIZONTAL BAR
  replace("ꜻ", "av")
  # A73C;LATIN CAPITAL LETTER AY
  replace("Ꜽ", "AY")
  # A73D;LATIN SMALL LETTER AY
  replace("ꜽ", "ay")
  # A740;LATIN CAPITAL LETTER K WITH STROKE
  replace("Ꝁ", "K")
  # A741;LATIN SMALL LETTER K WITH STROKE
  replace("ꝁ", "k")
  # A742;LATIN CAPITAL LETTER K WITH DIAGONAL STROKE
  replace("Ꝃ", "K")
  # A743;LATIN SMALL LETTER K WITH DIAGONAL STROKE
  replace("ꝃ", "k")
  # A744;LATIN CAPITAL LETTER K WITH STROKE AND DIAGONAL STROKE
  replace("Ꝅ", "K")
  # A745;LATIN SMALL LETTER K WITH STROKE AND DIAGONAL STROKE
  replace("ꝅ", "k")
  # A746;LATIN CAPITAL LETTER BROKEN L
  replace("Ꝇ", "L")
  # A747;LATIN SMALL LETTER BROKEN L
  replace("ꝇ", "l")
  # A748;LATIN CAPITAL LETTER L WITH HIGH STROKE
  replace("Ꝉ", "L")
  # A749;LATIN SMALL LETTER L WITH HIGH STROKE
  replace("ꝉ", "l")
  # A74A;LATIN CAPITAL LETTER O WITH LONG STROKE OVERLAY
  replace("Ꝋ", "O")
  # A74B;LATIN SMALL LETTER O WITH LONG STROKE OVERLAY
  replace("ꝋ", "o")
  # A74C;LATIN CAPITAL LETTER O WITH LOOP
  replace("Ꝍ", "O")
  # A74D;LATIN SMALL LETTER O WITH LOOP
  replace("ꝍ", "o")
  # A74E;LATIN CAPITAL LETTER OO
  replace("Ꝏ", "OO")
  # A74F;LATIN SMALL LETTER OO
  replace("ꝏ", "oo")
  # A750;LATIN CAPITAL LETTER P WITH STROKE THROUGH DESCENDER
  replace("Ꝑ", "P")
  # A751;LATIN SMALL LETTER P WITH STROKE THROUGH DESCENDER
  replace("ꝑ", "p")
  # A752;LATIN CAPITAL LETTER P WITH FLOURISH
  replace("Ꝓ", "P")
  # A753;LATIN SMALL LETTER P WITH FLOURISH
  replace("ꝓ", "p")
  # A754;LATIN CAPITAL LETTER P WITH SQUIRREL TAIL
  replace("Ꝕ", "P")
  # A755;LATIN SMALL LETTER P WITH SQUIRREL TAIL
  replace("ꝕ", "p")
  # A756;LATIN CAPITAL LETTER Q WITH STROKE THROUGH DESCENDER
  replace("Ꝗ", "Q")
  # A757;LATIN SMALL LETTER Q WITH STROKE THROUGH DESCENDER
  replace("ꝗ", "q")
  # A758;LATIN CAPITAL LETTER Q WITH DIAGONAL STROKE
  replace("Ꝙ", "Q")
  # A759;LATIN SMALL LETTER Q WITH DIAGONAL STROKE
  replace("ꝙ", "q")
  # A75E;LATIN CAPITAL LETTER V WITH DIAGONAL STROKE
  replace("Ꝟ", "V")
  # A75F;LATIN SMALL LETTER V WITH DIAGONAL STROKE
  replace("ꝟ", "v")
  # A760;LATIN CAPITAL LETTER VY
  replace("Ꝡ", "VY")
  # A761;LATIN SMALL LETTER VY
  replace("ꝡ", "vy")
  # A764;LATIN CAPITAL LETTER THORN WITH STROKE
  replace("Ꝥ", "TH")
  # A765;LATIN SMALL LETTER THORN WITH STROKE
  replace("ꝥ", "th")
  # A766;LATIN CAPITAL LETTER THORN WITH STROKE THROUGH DESCENDER
  replace("Ꝧ", "TH")
  # A767;LATIN SMALL LETTER THORN WITH STROKE THROUGH DESCENDER
  replace("ꝧ", "th")
  # A771;LATIN SMALL LETTER DUM
  replace("ꝱ", "d")
  # A772;LATIN SMALL LETTER LUM
  replace("ꝲ", "l")
  # A773;LATIN SMALL LETTER MUM
  replace("ꝳ", "m")
  # A774;LATIN SMALL LETTER NUM
  replace("ꝴ", "n")
  # A775;LATIN SMALL LETTER RUM
  replace("ꝵ", "r")
  # A776;LATIN LETTER SMALL CAPITAL RUM
  replace("ꝶ", "R")
  # A777;LATIN SMALL LETTER TUM
  replace("ꝷ", "t")
  # A779;LATIN CAPITAL LETTER INSULAR D
  replace("Ꝺ", "D")
  # A77A;LATIN SMALL LETTER INSULAR D
  replace("ꝺ", "d")
  # A77B;LATIN CAPITAL LETTER INSULAR F
  replace("Ꝼ", "F")
  # A77C;LATIN SMALL LETTER INSULAR F
  replace("ꝼ", "f")
  # A786;LATIN CAPITAL LETTER INSULAR T
  replace("Ꞇ", "T")
  # A787;LATIN SMALL LETTER INSULAR T
  replace("ꞇ", "t")
  # A790;LATIN CAPITAL LETTER N WITH DESCENDER
  replace("Ꞑ", "N")
  # A791;LATIN SMALL LETTER N WITH DESCENDER
  replace("ꞑ", "n")
  # A792;LATIN CAPITAL LETTER C WITH BAR
  replace("Ꞓ", "C")
  # A793;LATIN SMALL LETTER C WITH BAR
  replace("ꞓ", "c")
  # A7A0;LATIN CAPITAL LETTER G WITH OBLIQUE STROKE
  replace("Ꞡ", "G")
  # A7A1;LATIN SMALL LETTER G WITH OBLIQUE STROKE
  replace("ꞡ", "g")
  # A7A2;LATIN CAPITAL LETTER K WITH OBLIQUE STROKE
  replace("Ꞣ", "K")
  # A7A3;LATIN SMALL LETTER K WITH OBLIQUE STROKE
  replace("ꞣ", "k")
  # A7A4;LATIN CAPITAL LETTER N WITH OBLIQUE STROKE
  replace("Ꞥ", "N")
  # A7A5;LATIN SMALL LETTER N WITH OBLIQUE STROKE
  replace("ꞥ", "n")
  # A7A6;LATIN CAPITAL LETTER R WITH OBLIQUE STROKE
  replace("Ꞧ", "R")
  # A7A7;LATIN SMALL LETTER R WITH OBLIQUE STROKE
  replace("ꞧ", "r")
  # A7A8;LATIN CAPITAL LETTER S WITH OBLIQUE STROKE
  replace("Ꞩ", "S")
  # A7A9;LATIN SMALL LETTER S WITH OBLIQUE STROKE
  replace("ꞩ", "s")
  # A7AA;LATIN CAPITAL LETTER H WITH HOOK
  replace("Ɦ", "H")
  # Presentation forms
  # FB00;LATIN SMALL LIGATURE FF (compat)
  replace("ﬀ", "ff")
  # FB01;LATIN SMALL LIGATURE FI (compat)
  replace("ﬁ", "fi")
  # FB02;LATIN SMALL LIGATURE FL (compat)
  replace("ﬂ", "fl")
  # FB03;LATIN SMALL LIGATURE FFI (compat)
  replace("ﬃ", "ffi")
  # FB04;LATIN SMALL LIGATURE FFL (compat)
  replace("ﬄ", "ffl")
  # FB05;LATIN SMALL LIGATURE LONG S T (compat)
  replace("ﬅ", "st")
  # FB06;LATIN SMALL LIGATURE ST (compat)
  replace("ﬆ", "st")
  # Fullwidth
  # FF21;FULLWIDTH LATIN CAPITAL LETTER A (compat)
  replace("Ａ", "A")
  # FF22;FULLWIDTH LATIN CAPITAL LETTER B (compat)
  replace("Ｂ", "B")
  # FF23;FULLWIDTH LATIN CAPITAL LETTER C (compat)
  replace("Ｃ", "C")
  # FF24;FULLWIDTH LATIN CAPITAL LETTER D (compat)
  replace("Ｄ", "D")
  # FF25;FULLWIDTH LATIN CAPITAL LETTER E (compat)
  replace("Ｅ", "E")
  # FF26;FULLWIDTH LATIN CAPITAL LETTER F (compat)
  replace("Ｆ", "F")
  # FF27;FULLWIDTH LATIN CAPITAL LETTER G (compat)
  replace("Ｇ", "G")
  # FF28;FULLWIDTH LATIN CAPITAL LETTER H (compat)
  replace("Ｈ", "H")
  # FF29;FULLWIDTH LATIN CAPITAL LETTER I (compat)
  replace("Ｉ", "I")
  # FF2A;FULLWIDTH LATIN CAPITAL LETTER J (compat)
  replace("Ｊ", "J")
  # FF2B;FULLWIDTH LATIN CAPITAL LETTER K (compat)
  replace("Ｋ", "K")
  # FF2C;FULLWIDTH LATIN CAPITAL LETTER L (compat)
  replace("Ｌ", "L")
  # FF2D;FULLWIDTH LATIN CAPITAL LETTER M (compat)
  replace("Ｍ", "M")
  # FF2E;FULLWIDTH LATIN CAPITAL LETTER N (compat)
  replace("Ｎ", "N")
  # FF2F;FULLWIDTH LATIN CAPITAL LETTER O (compat)
  replace("Ｏ", "O")
  # FF30;FULLWIDTH LATIN CAPITAL LETTER P (compat)
  replace("Ｐ", "P")
  # FF31;FULLWIDTH LATIN CAPITAL LETTER Q (compat)
  replace("Ｑ", "Q")
  # FF32;FULLWIDTH LATIN CAPITAL LETTER R (compat)
  replace("Ｒ", "R")
  # FF33;FULLWIDTH LATIN CAPITAL LETTER S (compat)
  replace("Ｓ", "S")
  # FF34;FULLWIDTH LATIN CAPITAL LETTER T (compat)
  replace("Ｔ", "T")
  # FF35;FULLWIDTH LATIN CAPITAL LETTER U (compat)
  replace("Ｕ", "U")
  # FF36;FULLWIDTH LATIN CAPITAL LETTER V (compat)
  replace("Ｖ", "V")
  # FF37;FULLWIDTH LATIN CAPITAL LETTER W (compat)
  replace("Ｗ", "W")
  # FF38;FULLWIDTH LATIN CAPITAL LETTER X (compat)
  replace("Ｘ", "X")
  # FF39;FULLWIDTH LATIN CAPITAL LETTER Y (compat)
  replace("Ｙ", "Y")
  # FF3A;FULLWIDTH LATIN CAPITAL LETTER Z (compat)
  replace("Ｚ", "Z")
  # FF41;FULLWIDTH LATIN SMALL LETTER A (compat)
  replace("ａ", "a")
  # FF42;FULLWIDTH LATIN SMALL LETTER B (compat)
  replace("ｂ", "b")
  # FF43;FULLWIDTH LATIN SMALL LETTER C (compat)
  replace("ｃ", "c")
  # FF44;FULLWIDTH LATIN SMALL LETTER D (compat)
  replace("ｄ", "d")
  # FF45;FULLWIDTH LATIN SMALL LETTER E (compat)
  replace("ｅ", "e")
  # FF46;FULLWIDTH LATIN SMALL LETTER F (compat)
  replace("ｆ", "f")
  # FF47;FULLWIDTH LATIN SMALL LETTER G (compat)
  replace("ｇ", "g")
  # FF48;FULLWIDTH LATIN SMALL LETTER H (compat)
  replace("ｈ", "h")
  # FF49;FULLWIDTH LATIN SMALL LETTER I (compat)
  replace("ｉ", "i")
  # FF4A;FULLWIDTH LATIN SMALL LETTER J (compat)
  replace("ｊ", "j")
  # FF4B;FULLWIDTH LATIN SMALL LETTER K (compat)
  replace("ｋ", "k")
  # FF4C;FULLWIDTH LATIN SMALL LETTER L (compat)
  replace("ｌ", "l")
  # FF4D;FULLWIDTH LATIN SMALL LETTER M (compat)
  replace("ｍ", "m")
  # FF4E;FULLWIDTH LATIN SMALL LETTER N (compat)
  replace("ｎ", "n")
  # FF4F;FULLWIDTH LATIN SMALL LETTER O (compat)
  replace("ｏ", "o")
  # FF50;FULLWIDTH LATIN SMALL LETTER P (compat)
  replace("ｐ", "p")
  # FF51;FULLWIDTH LATIN SMALL LETTER Q (compat)
  replace("ｑ", "q")
  # FF52;FULLWIDTH LATIN SMALL LETTER R (compat)
  replace("ｒ", "r")
  # FF53;FULLWIDTH LATIN SMALL LETTER S (compat)
  replace("ｓ", "s")
  # FF54;FULLWIDTH LATIN SMALL LETTER T (compat)
  replace("ｔ", "t")
  # FF55;FULLWIDTH LATIN SMALL LETTER U (compat)
  replace("ｕ", "u")
  # FF56;FULLWIDTH LATIN SMALL LETTER V (compat)
  replace("ｖ", "v")
  # FF57;FULLWIDTH LATIN SMALL LETTER W (compat)
  replace("ｗ", "w")
  # FF58;FULLWIDTH LATIN SMALL LETTER X (compat)
  replace("ｘ", "x")
  # FF59;FULLWIDTH LATIN SMALL LETTER Y (compat)
  replace("ｙ", "y")
  # FF5A;FULLWIDTH LATIN SMALL LETTER Z (compat)
  replace("ｚ", "z")
  #
  # Currency and letterlike
  #
  # 00A9;COPYRIGHT SIGN (from ‹character-fallback›)
  replace("©", "(C)")
  # 00AE;REGISTERED SIGN (from ‹character-fallback›)
  replace("®", "(R)")
  # 20A0;EURO-CURRENCY SIGN (from ‹character-fallback›)
  replace("₠", "CE")
  # 20A2;CRUZEIRO SIGN (from ‹character-fallback›)
  replace("₢", "Cr")
  # 20A3;FRENCH FRANC SIGN (from ‹character-fallback›)
  replace("₣", "Fr.")
  # 20A4;LIRA SIGN (from ‹character-fallback›)
  replace("₤", "L.")
  # 20A7;PESETA SIGN (from ‹character-fallback›)
  replace("₧", "Pts")
  # 20B9;INDIAN RUPEE SIGN (from ‹character-fallback›)
  replace("₹", "Rs")
  # 20BA;TURKISH LIRA SIGN (from ‹character-fallback›)
  replace("₺", "TL")
  # 2100;ACCOUNT OF (compat)
  replace("℀", "a/c")
  # 2101;ADDRESSED TO THE SUBJECT (compat)
  replace("℁", "a/s")
  # 2102;DOUBLE-STRUCK CAPITAL C (compat)
  replace("ℂ", "C")
  # 2105;CARE OF (compat)
  replace("℅", "c/o")
  # 2106;CADA UNA (compat)
  replace("℆", "c/u")
  # 210A;SCRIPT SMALL G (compat)
  replace("ℊ", "g")
  # 210B;SCRIPT CAPITAL H (compat)
  replace("ℋ", "H")
  # 210C;BLACK-LETTER CAPITAL H (compat)
  replace("ℌ", "x")
  # 210D;DOUBLE-STRUCK CAPITAL H (compat)
  replace("ℍ", "H")
  # 210E;PLANCK CONSTANT (compat)
  replace("ℎ", "h")
  # 2110;SCRIPT CAPITAL I (compat)
  replace("ℐ", "I")
  # 2111;BLACK-LETTER CAPITAL I (compat)
  replace("ℑ", "I")
  # 2112;SCRIPT CAPITAL L (compat)
  replace("ℒ", "L")
  # 2113;SCRIPT SMALL L (compat)
  replace("ℓ", "l")
  # 2115;DOUBLE-STRUCK CAPITAL N (compat)
  replace("ℕ", "N")
  # 2116;NUMERO SIGN (compat)
  replace("№", "No")
  # 2117;SOUND RECORDING COPYRIGHT (later addition)
  replace("℗", "(P)")
  # 2118;SCRIPT CAPITAL P (later addition)
  replace("℘", "P")
  # 2119;DOUBLE-STRUCK CAPITAL P (compat)
  replace("ℙ", "P")
  # 211A;DOUBLE-STRUCK CAPITAL Q (compat)
  replace("ℚ", "Q")
  # 211B;SCRIPT CAPITAL R (compat)
  replace("ℛ", "R")
  # 211C;BLACK-LETTER CAPITAL R (compat)
  replace("ℜ", "R")
  # 211D;DOUBLE-STRUCK CAPITAL R (compat)
  replace("ℝ", "R")
  # 211E;PRESCRIPTION TAKE (from ‹character-fallback›)
  replace("℞", "Rx")
  # 2121;TELEPHONE SIGN (compat)
  replace("℡", "TEL")
  # 2124;DOUBLE-STRUCK CAPITAL Z (compat)
  replace("ℤ", "Z")
  # 2128;BLACK-LETTER CAPITAL Z (compat)
  replace("ℨ", "Z")
  # 212C;SCRIPT CAPITAL B (compat)
  replace("ℬ", "B")
  # 212D;BLACK-LETTER CAPITAL C (compat)
  replace("ℭ", "C")
  # 212F;SCRIPT SMALL E (compat)
  replace("ℯ", "e")
  # 2130;SCRIPT CAPITAL E (compat)
  replace("ℰ", "E")
  # 2131;SCRIPT CAPITAL F (compat)
  replace("ℱ", "F")
  # 2133;SCRIPT CAPITAL M (compat)
  replace("ℳ", "M")
  # 2134;SCRIPT SMALL O (compat)
  replace("ℴ", "o")
  # 2139;INFORMATION SOURCE (compat)
  replace("ℹ", "i")
  # 213B;FACSIMILE SIGN (compat)
  replace("℻", "FAX")
  # 2145;DOUBLE-STRUCK ITALIC CAPITAL D (compat)
  replace("ⅅ", "D")
  # 2146;DOUBLE-STRUCK ITALIC SMALL D (compat)
  replace("ⅆ", "d")
  # 2147;DOUBLE-STRUCK ITALIC SMALL E (compat)
  replace("ⅇ", "e")
  # 2148;DOUBLE-STRUCK ITALIC SMALL I (compat)
  replace("ⅈ", "i")
  # 2149;DOUBLE-STRUCK ITALIC SMALL J (compat)
  replace("ⅉ", "j")
  #
  # Squared Latin
  #
  # 3371;SQUARE HPA (compat)
  replace("㍱", "hPa")
  # 3372;SQUARE DA (compat)
  replace("㍲", "da")
  # 3373;SQUARE AU (compat)
  replace("㍳", "AU")
  # 3374;SQUARE BAR (compat)
  replace("㍴", "bar")
  # 3375;SQUARE OV (compat)
  replace("㍵", "oV")
  # 3376;SQUARE PC (compat)
  replace("㍶", "pc")
  # 3377;SQUARE DM (compat)
  replace("㍷", "dm")
  # 337A;SQUARE IU (compat)
  replace("㍺", "IU")
  # 3380;SQUARE PA AMPS (compat)
  replace("㎀", "pA")
  # 3381;SQUARE NA (compat)
  replace("㎁", "nA")
  # 3383;SQUARE MA (compat)
  replace("㎃", "mA")
  # 3384;SQUARE KA (compat)
  replace("㎄", "kA")
  # 3385;SQUARE KB (compat)
  replace("㎅", "KB")
  # 3386;SQUARE MB (compat)
  replace("㎆", "MB")
  # 3387;SQUARE GB (compat)
  replace("㎇", "GB")
  # 3388;SQUARE CAL (compat)
  replace("㎈", "cal")
  # 3389;SQUARE KCAL (compat)
  replace("㎉", "kcal")
  # 338A;SQUARE PF (compat)
  replace("㎊", "pF")
  # 338B;SQUARE NF (compat)
  replace("㎋", "nF")
  # 338E;SQUARE MG (compat)
  replace("㎎", "mg")
  # 338F;SQUARE KG (compat)
  replace("㎏", "kg")
  # 3390;SQUARE HZ (compat)
  replace("㎐", "Hz")
  # 3391;SQUARE KHZ (compat)
  replace("㎑", "kHz")
  # 3392;SQUARE MHZ (compat)
  replace("㎒", "MHz")
  # 3393;SQUARE GHZ (compat)
  replace("㎓", "GHz")
  # 3394;SQUARE THZ (compat)
  replace("㎔", "THz")
  # 3399;SQUARE FM (compat)
  replace("㎙", "fm")
  # 339A;SQUARE NM (compat)
  replace("㎚", "nm")
  # 339C;SQUARE MM (compat)
  replace("㎜", "mm")
  # 339D;SQUARE CM (compat)
  replace("㎝", "cm")
  # 339E;SQUARE KM (compat)
  replace("㎞", "km")
  # 33A7;SQUARE M OVER S (compat) (from ‹character-fallback›)
  replace("㎧", "m/s")
  # 33A9;SQUARE PA (compat)
  replace("㎩", "Pa")
  # 33AA;SQUARE KPA (compat)
  replace("㎪", "kPa")
  # 33AB;SQUARE MPA (compat)
  replace("㎫", "MPa")
  # 33AC;SQUARE GPA (compat)
  replace("㎬", "GPa")
  # 33AD;SQUARE RAD (compat)
  replace("㎭", "rad")
  # 33AE;SQUARE RAD OVER S (compat) (from ‹character-fallback›)
  replace("㎮", "rad/s")
  # 33B0;SQUARE PS (compat)
  replace("㎰", "ps")
  # 33B1;SQUARE NS (compat)
  replace("㎱", "ns")
  # 33B3;SQUARE MS (compat)
  replace("㎳", "ms")
  # 33B4;SQUARE PV (compat)
  replace("㎴", "pV")
  # 33B5;SQUARE NV (compat)
  replace("㎵", "nV")
  # 33B7;SQUARE MV (compat)
  replace("㎷", "mV")
  # 33B8;SQUARE KV (compat)
  replace("㎸", "kV")
  # 33B9;SQUARE MV MEGA (compat)
  replace("㎹", "MV")
  # 33BA;SQUARE PW (compat)
  replace("㎺", "pW")
  # 33BB;SQUARE NW (compat)
  replace("㎻", "nW")
  # 33BD;SQUARE MW (compat)
  replace("㎽", "mW")
  # 33BE;SQUARE KW (compat)
  replace("㎾", "kW")
  # 33BF;SQUARE MW MEGA (compat)
  replace("㎿", "MW")
  # 33C2;SQUARE AM (compat)
  replace("㏂", "a.m.")
  # 33C3;SQUARE BQ (compat)
  replace("㏃", "Bq")
  # 33C4;SQUARE CC (compat) (from ‹character-fallback›, adj)
  replace("㏄", "cc")
  # 33C5;SQUARE CD (compat)
  replace("㏅", "cd")
  # 33C6;SQUARE C OVER KG (compat) (from ‹character-fallback›)
  replace("㏆", "C/kg")
  # 33C7;SQUARE CO (compat)
  replace("㏇", "Co.")
  # 33C8;SQUARE DB (compat)
  replace("㏈", "dB")
  # 33C9;SQUARE GY (compat)
  replace("㏉", "Gy")
  # 33CA;SQUARE HA (compat)
  replace("㏊", "ha")
  # 33CB;SQUARE HP (compat)
  replace("㏋", "HP")
  # 33CC;SQUARE IN (compat)
  replace("㏌", "in")
  # 33CD;SQUARE KK (compat)
  replace("㏍", "KK")
  # 33CE;SQUARE KM CAPITAL (compat)
  replace("㏎", "KM")
  # 33CF;SQUARE KT (compat)
  replace("㏏", "kt")
  # 33D0;SQUARE LM (compat)
  replace("㏐", "lm")
  # 33D1;SQUARE LN (compat)
  replace("㏑", "ln")
  # 33D2;SQUARE LOG (compat)
  replace("㏒", "log")
  # 33D3;SQUARE LX (compat)
  replace("㏓", "lx")
  # 33D4;SQUARE MB SMALL (compat)
  replace("㏔", "mb")
  # 33D5;SQUARE MIL (compat)
  replace("㏕", "mil")
  # 33D6;SQUARE MOL (compat)
  replace("㏖", "mol")
  # 33D7;SQUARE PH (compat) (from ‹character-fallback›)
  replace("㏗", "pH")
  # 33D8;SQUARE PM (compat)
  replace("㏘", "p.m.")
  # 33D9;SQUARE PPM (compat)
  replace("㏙", "PPM")
  # 33DA;SQUARE PR (compat)
  replace("㏚", "PR")
  # 33DB;SQUARE SR (compat)
  replace("㏛", "sr")
  # 33DC;SQUARE SV (compat)
  replace("㏜", "Sv")
  # 33DD;SQUARE WB (compat)
  replace("㏝", "Wb")
  # 33DE;SQUARE V OVER M (compat) (from ‹character-fallback›)
  replace("㏞", "V/m")
  # 33DF;SQUARE A OVER M (compat) (from ‹character-fallback›)
  replace("㏟", "A/m")
  #
  # Enclosed Latin
  #
  # 249C;PARENTHESIZED LATIN SMALL LETTER A (compat)
  replace("⒜", "(a)")
  # 249D;PARENTHESIZED LATIN SMALL LETTER B (compat)
  replace("⒝", "(b)")
  # 249E;PARENTHESIZED LATIN SMALL LETTER C (compat)
  replace("⒞", "(c)")
  # 249F;PARENTHESIZED LATIN SMALL LETTER D (compat)
  replace("⒟", "(d)")
  # 24A0;PARENTHESIZED LATIN SMALL LETTER E (compat)
  replace("⒠", "(e)")
  # 24A1;PARENTHESIZED LATIN SMALL LETTER F (compat)
  replace("⒡", "(f)")
  # 24A2;PARENTHESIZED LATIN SMALL LETTER G (compat)
  replace("⒢", "(g)")
  # 24A3;PARENTHESIZED LATIN SMALL LETTER H (compat)
  replace("⒣", "(h)")
  # 24A4;PARENTHESIZED LATIN SMALL LETTER I (compat)
  replace("⒤", "(i)")
  # 24A5;PARENTHESIZED LATIN SMALL LETTER J (compat)
  replace("⒥", "(j)")
  # 24A6;PARENTHESIZED LATIN SMALL LETTER K (compat)
  replace("⒦", "(k)")
  # 24A7;PARENTHESIZED LATIN SMALL LETTER L (compat)
  replace("⒧", "(l)")
  # 24A8;PARENTHESIZED LATIN SMALL LETTER M (compat)
  replace("⒨", "(m)")
  # 24A9;PARENTHESIZED LATIN SMALL LETTER N (compat)
  replace("⒩", "(n)")
  # 24AA;PARENTHESIZED LATIN SMALL LETTER O (compat)
  replace("⒪", "(o)")
  # 24AB;PARENTHESIZED LATIN SMALL LETTER P (compat)
  replace("⒫", "(p)")
  # 24AC;PARENTHESIZED LATIN SMALL LETTER Q (compat)
  replace("⒬", "(q)")
  # 24AD;PARENTHESIZED LATIN SMALL LETTER R (compat)
  replace("⒭", "(r)")
  # 24AE;PARENTHESIZED LATIN SMALL LETTER S (compat)
  replace("⒮", "(s)")
  # 24AF;PARENTHESIZED LATIN SMALL LETTER T (compat)
  replace("⒯", "(t)")
  # 24B0;PARENTHESIZED LATIN SMALL LETTER U (compat)
  replace("⒰", "(u)")
  # 24B1;PARENTHESIZED LATIN SMALL LETTER V (compat)
  replace("⒱", "(v)")
  # 24B2;PARENTHESIZED LATIN SMALL LETTER W (compat)
  replace("⒲", "(w)")
  # 24B3;PARENTHESIZED LATIN SMALL LETTER X (compat)
  replace("⒳", "(x)")
  # 24B4;PARENTHESIZED LATIN SMALL LETTER Y (compat)
  replace("⒴", "(y)")
  # 24B5;PARENTHESIZED LATIN SMALL LETTER Z (compat)
  replace("⒵", "(z)")
  # 1F110;PARENTHESIZED LATIN CAPITAL LETTER A (compat)
  replace("🄐", "(A)")
  # 1F111;PARENTHESIZED LATIN CAPITAL LETTER B (compat)
  replace("🄑", "(B)")
  # 1F112;PARENTHESIZED LATIN CAPITAL LETTER C (compat)
  replace("🄒", "(C)")
  # 1F113;PARENTHESIZED LATIN CAPITAL LETTER D (compat)
  replace("🄓", "(D)")
  # 1F114;PARENTHESIZED LATIN CAPITAL LETTER E (compat)
  replace("🄔", "(E)")
  # 1F115;PARENTHESIZED LATIN CAPITAL LETTER F (compat)
  replace("🄕", "(F)")
  # 1F116;PARENTHESIZED LATIN CAPITAL LETTER G (compat)
  replace("🄖", "(G)")
  # 1F117;PARENTHESIZED LATIN CAPITAL LETTER H (compat)
  replace("🄗", "(H)")
  # 1F118;PARENTHESIZED LATIN CAPITAL LETTER I (compat)
  replace("🄘", "(I)")
  # 1F119;PARENTHESIZED LATIN CAPITAL LETTER J (compat)
  replace("🄙", "(J)")
  # 1F11A;PARENTHESIZED LATIN CAPITAL LETTER K (compat)
  replace("🄚", "(K)")
  # 1F11B;PARENTHESIZED LATIN CAPITAL LETTER L (compat)
  replace("🄛", "(L)")
  # 1F11C;PARENTHESIZED LATIN CAPITAL LETTER M (compat)
  replace("🄜", "(M)")
  # 1F11D;PARENTHESIZED LATIN CAPITAL LETTER N (compat)
  replace("🄝", "(N)")
  # 1F11E;PARENTHESIZED LATIN CAPITAL LETTER O (compat)
  replace("🄞", "(O)")
  # 1F11F;PARENTHESIZED LATIN CAPITAL LETTER P (compat)
  replace("🄟", "(P)")
  # 1F120;PARENTHESIZED LATIN CAPITAL LETTER Q (compat)
  replace("🄠", "(Q)")
  # 1F121;PARENTHESIZED LATIN CAPITAL LETTER R (compat)
  replace("🄡", "(R)")
  # 1F122;PARENTHESIZED LATIN CAPITAL LETTER S (compat)
  replace("🄢", "(S)")
  # 1F123;PARENTHESIZED LATIN CAPITAL LETTER T (compat)
  replace("🄣", "(T)")
  # 1F124;PARENTHESIZED LATIN CAPITAL LETTER U (compat)
  replace("🄤", "(U)")
  # 1F125;PARENTHESIZED LATIN CAPITAL LETTER V (compat)
  replace("🄥", "(V)")
  # 1F126;PARENTHESIZED LATIN CAPITAL LETTER W (compat)
  replace("🄦", "(W)")
  # 1F127;PARENTHESIZED LATIN CAPITAL LETTER X (compat)
  replace("🄧", "(X)")
  # 1F128;PARENTHESIZED LATIN CAPITAL LETTER Y (compat)
  replace("🄨", "(Y)")
  # 1F129;PARENTHESIZED LATIN CAPITAL LETTER Z (compat)
  replace("🄩", "(Z)")
  #
  #
  #
  # Roman numerals
  #
  # 2160;ROMAN NUMERAL ONE (compat)
  replace("Ⅰ", "I")
  # 2161;ROMAN NUMERAL TWO (compat)
  replace("Ⅱ", "II")
  # 2162;ROMAN NUMERAL THREE (compat)
  replace("Ⅲ", "III")
  # 2163;ROMAN NUMERAL FOUR (compat)
  replace("Ⅳ", "IV")
  # 2164;ROMAN NUMERAL FIVE (compat)
  replace("Ⅴ", "V")
  # 2165;ROMAN NUMERAL SIX (compat)
  replace("Ⅵ", "VI")
  # 2166;ROMAN NUMERAL SEVEN (compat)
  replace("Ⅶ", "VII")
  # 2167;ROMAN NUMERAL EIGHT (compat)
  replace("Ⅷ", "VIII")
  # 2168;ROMAN NUMERAL NINE (compat)
  replace("Ⅸ", "IX")
  # 2169;ROMAN NUMERAL TEN (compat)
  replace("Ⅹ", "X")
  # 216A;ROMAN NUMERAL ELEVEN (compat)
  replace("Ⅺ", "XI")
  # 216B;ROMAN NUMERAL TWELVE (compat)
  replace("Ⅻ", "XII")
  # 216C;ROMAN NUMERAL FIFTY (compat)
  replace("Ⅼ", "L")
  # 216D;ROMAN NUMERAL ONE HUNDRED (compat)
  replace("Ⅽ", "C")
  # 216E;ROMAN NUMERAL FIVE HUNDRED (compat)
  replace("Ⅾ", "D")
  # 216F;ROMAN NUMERAL ONE THOUSAND (compat)
  replace("Ⅿ", "M")
  # 2170;SMALL ROMAN NUMERAL ONE (compat)
  replace("ⅰ", "i")
  # 2171;SMALL ROMAN NUMERAL TWO (compat)
  replace("ⅱ", "ii")
  # 2172;SMALL ROMAN NUMERAL THREE (compat)
  replace("ⅲ", "iii")
  # 2173;SMALL ROMAN NUMERAL FOUR (compat)
  replace("ⅳ", "iv")
  # 2174;SMALL ROMAN NUMERAL FIVE (compat)
  replace("ⅴ", "v")
  # 2175;SMALL ROMAN NUMERAL SIX (compat)
  replace("ⅵ", "vi")
  # 2176;SMALL ROMAN NUMERAL SEVEN (compat)
  replace("ⅶ", "vii")
  # 2177;SMALL ROMAN NUMERAL EIGHT (compat)
  replace("ⅷ", "viii")
  # 2178;SMALL ROMAN NUMERAL NINE (compat)
  replace("ⅸ", "ix")
  # 2179;SMALL ROMAN NUMERAL TEN (compat)
  replace("ⅹ", "x")
  # 217A;SMALL ROMAN NUMERAL ELEVEN (compat)
  replace("ⅺ", "xi")
  # 217B;SMALL ROMAN NUMERAL TWELVE (compat)
  replace("ⅻ", "xii")
  # 217C;SMALL ROMAN NUMERAL FIFTY (compat)
  replace("ⅼ", "l")
  # 217D;SMALL ROMAN NUMERAL ONE HUNDRED (compat)
  replace("ⅽ", "c")
  # 217E;SMALL ROMAN NUMERAL FIVE HUNDRED (compat)
  replace("ⅾ", "d")
  # 217F;SMALL ROMAN NUMERAL ONE THOUSAND (compat)
  replace("ⅿ", "m")
  #
  # Fractions
  #
  # 00BC;VULGAR FRACTION ONE QUARTER (from ‹character-fallback›)
  replace("¼", "1/4")
  # 00BD;VULGAR FRACTION ONE HALF (from ‹character-fallback›)
  replace("½", "1/2")
  # 00BE;VULGAR FRACTION THREE QUARTERS (from ‹character-fallback›)
  replace("¾", "3/4")
  # 2150;VULGAR FRACTION ONE SEVENTH
  replace("⅐", "1/7")
  # 2151;VULGAR FRACTION ONE NINTH
  replace("⅑", "1/9")
  # 2151;VULGAR FRACTION ONE TENTH
  replace("⅒", "1/10")
  # 2153;VULGAR FRACTION ONE THIRD (from ‹character-fallback›)
  replace("⅓", "1/3")
  # 2154;VULGAR FRACTION TWO THIRDS (from ‹character-fallback›)
  replace("⅔", "2/3")
  # 2155;VULGAR FRACTION ONE FIFTH (from ‹character-fallback›)
  replace("⅕", "1/5")
  # 2156;VULGAR FRACTION TWO FIFTHS (from ‹character-fallback›)
  replace("⅖", "2/5")
  # 2157;VULGAR FRACTION THREE FIFTHS (from ‹character-fallback›)
  replace("⅗", "3/5")
  # 2158;VULGAR FRACTION FOUR FIFTHS (from ‹character-fallback›)
  replace("⅘", "4/5")
  # 2159;VULGAR FRACTION ONE SIXTH (from ‹character-fallback›)
  replace("⅙", "1/6")
  # 215A;VULGAR FRACTION FIVE SIXTHS (from ‹character-fallback›)
  replace("⅚", "5/6")
  # 215B;VULGAR FRACTION ONE EIGHTH (from ‹character-fallback›)
  replace("⅛", "1/8")
  # 215C;VULGAR FRACTION THREE EIGHTHS (from ‹character-fallback›)
  replace("⅜", "3/8")
  # 215D;VULGAR FRACTION FIVE EIGHTHS (from ‹character-fallback›)
  replace("⅝", "5/8")
  # 215E;VULGAR FRACTION SEVEN EIGHTHS (from ‹character-fallback›)
  replace("⅞", "7/8")
  # 215F;FRACTION NUMERATOR ONE (from ‹character-fallback›)
  replace("⅟", "1/")
  # 2189;VULGAR FRACTION ZERO THIRDS
  replace("↉", "0/3")
  #
  # Enclosed numeric
  #
  # 2474;PARENTHESIZED DIGIT ONE (compat)
  replace("⑴", "(1)")
  # 2475;PARENTHESIZED DIGIT TWO (compat)
  replace("⑵", "(2)")
  # 2476;PARENTHESIZED DIGIT THREE (compat)
  replace("⑶", "(3)")
  # 2477;PARENTHESIZED DIGIT FOUR (compat)
  replace("⑷", "(4)")
  # 2478;PARENTHESIZED DIGIT FIVE (compat)
  replace("⑸", "(5)")
  # 2479;PARENTHESIZED DIGIT SIX (compat)
  replace("⑹", "(6)")
  # 247A;PARENTHESIZED DIGIT SEVEN (compat)
  replace("⑺", "(7)")
  # 247B;PARENTHESIZED DIGIT EIGHT (compat)
  replace("⑻", "(8)")
  # 247C;PARENTHESIZED DIGIT NINE (compat)
  replace("⑼", "(9)")
  # 247D;PARENTHESIZED NUMBER TEN (compat)
  replace("⑽", "(10)")
  # 247E;PARENTHESIZED NUMBER ELEVEN (compat)
  replace("⑾", "(11)")
  # 247F;PARENTHESIZED NUMBER TWELVE (compat)
  replace("⑿", "(12)")
  # 2480;PARENTHESIZED NUMBER THIRTEEN (compat)
  replace("⒀", "(13)")
  # 2481;PARENTHESIZED NUMBER FOURTEEN (compat)
  replace("⒁", "(14)")
  # 2482;PARENTHESIZED NUMBER FIFTEEN (compat)
  replace("⒂", "(15)")
  # 2483;PARENTHESIZED NUMBER SIXTEEN (compat)
  replace("⒃", "(16)")
  # 2484;PARENTHESIZED NUMBER SEVENTEEN (compat)
  replace("⒄", "(17)")
  # 2485;PARENTHESIZED NUMBER EIGHTEEN (compat)
  replace("⒅", "(18)")
  # 2486;PARENTHESIZED NUMBER NINETEEN (compat)
  replace("⒆", "(19)")
  # 2487;PARENTHESIZED NUMBER TWENTY (compat)
  replace("⒇", "(20)")
  # 1F100;DIGIT ZERO FULL STOP (compat)
  replace("🄀", "0.")
  # 2488;DIGIT ONE FULL STOP (compat)
  replace("⒈", "1.")
  # 2489;DIGIT TWO FULL STOP (compat)
  replace("⒉", "2.")
  # 248A;DIGIT THREE FULL STOP (compat)
  replace("⒊", "3.")
  # 248B;DIGIT FOUR FULL STOP (compat)
  replace("⒋", "4.")
  # 248C;DIGIT FIVE FULL STOP (compat)
  replace("⒌", "5.")
  # 248D;DIGIT SIX FULL STOP (compat)
  replace("⒍", "6.")
  # 248E;DIGIT SEVEN FULL STOP (compat)
  replace("⒎", "7.")
  # 248F;DIGIT EIGHT FULL STOP (compat)
  replace("⒏", "8.")
  # 2490;DIGIT NINE FULL STOP (compat)
  replace("⒐", "9.")
  # 2491;NUMBER TEN FULL STOP (compat)
  replace("⒑", "10.")
  # 2492;NUMBER ELEVEN FULL STOP (compat)
  replace("⒒", "11.")
  # 2493;NUMBER TWELVE FULL STOP (compat)
  replace("⒓", "12.")
  # 2494;NUMBER THIRTEEN FULL STOP (compat)
  replace("⒔", "13.")
  # 2495;NUMBER FOURTEEN FULL STOP (compat)
  replace("⒕", "14.")
  # 2496;NUMBER FIFTEEN FULL STOP (compat)
  replace("⒖", "15.")
  # 2497;NUMBER SIXTEEN FULL STOP (compat)
  replace("⒗", "16.")
  # 2498;NUMBER SEVENTEEN FULL STOP (compat)
  replace("⒘", "17.")
  # 2499;NUMBER EIGHTEEN FULL STOP (compat)
  replace("⒙", "18.")
  # 249A;NUMBER NINETEEN FULL STOP (compat)
  replace("⒚", "19.")
  # 249B;NUMBER TWENTY FULL STOP (compat)
  replace("⒛", "20.")
  # 1F101;DIGIT ZERO COMMA (compat)
  replace("🄁", "0,")
  # 1F102;DIGIT ONE COMMA (compat)
  replace("🄂", "1,")
  # 1F103;DIGIT TWO COMMA (compat)
  replace("🄃", "2,")
  # 1F104;DIGIT THREE COMMA (compat)
  replace("🄄", "3,")
  # 1F105;DIGIT FOUR COMMA (compat)
  replace("🄅", "4,")
  # 1F106;DIGIT FIVE COMMA (compat)
  replace("🄆", "5,")
  # 1F107;DIGIT SIX COMMA (compat)
  replace("🄇", "6,")
  # 1F108;DIGIT SEVEN COMMA (compat)
  replace("🄈", "7,")
  # 1F109;DIGIT EIGHT COMMA (compat)
  replace("🄉", "8,")
  # 1F10A;DIGIT NINE COMMA (compat)
  replace("🄊", "9,")
  #
  # Other numeric (ideographic and fullwidth)
  #
  # 3007;IDEOGRAPHIC NUMBER ZERO
  replace("〇", "0")
  # FF10;FULLWIDTH DIGIT ZERO (compat)
  replace("０", "0")
  # FF11;FULLWIDTH DIGIT ONE (compat)
  replace("１", "1")
  # FF12;FULLWIDTH DIGIT TWO (compat)
  replace("２", "2")
  # FF13;FULLWIDTH DIGIT THREE (compat)
  replace("３", "3")
  # FF14;FULLWIDTH DIGIT FOUR (compat)
  replace("４", "4")
  # FF15;FULLWIDTH DIGIT FIVE (compat)
  replace("５", "5")
  # FF16;FULLWIDTH DIGIT SIX (compat)
  replace("６", "6")
  # FF17;FULLWIDTH DIGIT SEVEN (compat)
  replace("７", "7")
  # FF18;FULLWIDTH DIGIT EIGHT (compat)
  replace("８", "8")
  # FF19;FULLWIDTH DIGIT NINE (compat)
  replace("９", "9")
  #
  # Spaces
  #
  # 00A0;NO-BREAK SPACE
  replace("\u00A0", " ")
  # 2002;EN SPACE (compat)
  replace("\u2002", " ")
  # 2003;EM SPACE (compat)
  replace("\u2003", " ")
  # 2004;THREE-PER-EM SPACE (compat)
  replace("\u2004", " ")
  # 2005;FOUR-PER-EM SPACE (compat)
  replace("\u2005", " ")
  # 2006;SIX-PER-EM SPACE (compat)
  replace("\u2006", " ")
  # 2007;FIGURE SPACE (compat)
  replace("\u2007", " ")
  # 2008;PUNCTUATION SPACE (compat)
  replace("\u2008", " ")
  # 2009;THIN SPACE (compat)
  replace("\u2009", " ")
  # 200A;HAIR SPACE (compat)
  replace("\u200A", " ")
  # 205F;MEDIUM MATHEMATICAL SPACE (compat)
  replace("\u205F", " ")
  # 3000;IDEOGRAPHIC SPACE (from ‹character-fallback›)
  replace("\u3000", " ")
  #
  # Quotes, apostrophes
  #
  # 02B9;MODIFIER LETTER PRIME
  replace("ʹ", "\'")
  # 02BA;MODIFIER LETTER DOUBLE PRIME
  replace("ʺ", "\"")
  # 02BB;MODIFIER LETTER TURNED COMMA
  replace("ʻ", "\'")
  # 02BC;MODIFIER LETTER APOSTROPHE
  replace("ʼ", "\'")
  # 02BD;MODIFIER LETTER REVERSED COMMA
  replace("ʽ", "\'")
  # 02C8;MODIFIER LETTER VERTICAL LINE
  replace("ˈ", "\'")
  # 02CB;MODIFIER LETTER GRAVE ACCENT
  replace("ˋ", "`")
  # 2018;LEFT SINGLE QUOTATION MARK (from ‹character-fallback›)
  replace("‘", "\'")
  # 2019;RIGHT SINGLE QUOTATION MARK (from ‹character-fallback›)
  replace("’", "\'")
  # 201A;SINGLE LOW-9 QUOTATION MARK (from ‹character-fallback›)
  replace("‚", ",")
  # 201B;SINGLE HIGH-REVERSED-9 QUOTATION MARK (from ‹character-fallback›)
  replace("‛", "\'")
  # 201C;LEFT DOUBLE QUOTATION MARK (from ‹character-fallback›)
  replace("“", "\"")
  # 201D;RIGHT DOUBLE QUOTATION MARK (from ‹character-fallback›)
  replace("”", "\"")
  # 201E;DOUBLE LOW-9 QUOTATION MARK (from ‹character-fallback›)
  replace("„", ",,")
  # 201F;DOUBLE HIGH-REVERSED-9 QUOTATION MARK (from ‹character-fallback›)
  replace("‟", "\"")
  # 2032;PRIME
  replace("′", "\'")
  # 2033;DOUBLE PRIME
  replace("″", "\"")
  # 301D;REVERSED DOUBLE PRIME QUOTATION MARK
  replace("〝", "\"")
  # 301E;DOUBLE PRIME QUOTATION MARK
  replace("〞", "\"")
  # FF02;FULLWIDTH QUOTATION MARK (compat)
  replace("＂", "\"")
  # FF07;FULLWIDTH APOSTROPHE (compat)
  replace("＇", "\'")
  # 00AB;LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (from ‹character-fallback›)
  replace("«", "<<")
  # 00BB;RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (from ‹character-fallback›)
  replace("»", ">>")
  # 2039;SINGLE LEFT-POINTING ANGLE QUOTATION MARK
  replace("‹", "<")
  # 203A;SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
  replace("›", ">")
  #
  # Dashes, hyphens...
  #
  # 00AD;SOFT HYPHEN (from ‹character-fallback›)
  replace("\u00AD", "-")
  # 2010;HYPHEN (from ‹character-fallback›)
  replace("‐", "-")
  # 2011;NON-BREAKING HYPHEN (from ‹character-fallback›)
  replace("‑", "-")
  # 2012;FIGURE DASH (from ‹character-fallback›)
  replace("‒", "-")
  # 2013;EN DASH (from ‹character-fallback›)
  replace("–", "-")
  # 2014;EM DASH (from ‹character-fallback›)
  replace("—", "-")
  # 2015;HORIZONTAL BAR (from ‹character-fallback›)
  replace("―", "-")
  # FE31;PRESENTATION FORM FOR VERTICAL EM DASH (compat)
  replace("︱", "-")
  # FE32;PRESENTATION FORM FOR VERTICAL EN DASH (compat)
  replace("︲", "-")
  # FE58;SMALL EM DASH (compat)
  replace("﹘", "-")
  # FE63;SMALL HYPHEN-MINUS (compat)
  replace("﹣", "-")
  # FF0D;FULLWIDTH HYPHEN-MINUS (compat)
  replace("－", "-")
  #
  # Other misc punctuation and symbols
  #
  # 00A1;INVERTED EXCLAMATION MARK
  replace("¡", "!")
  # 00BF;INVERTED QUESTION MARK
  replace("¿", "?")
  # 02C2;MODIFIER LETTER LEFT ARROWHEAD
  replace("˂", "<")
  # 02C3;MODIFIER LETTER RIGHT ARROWHEAD
  replace("˃", ">")
  # 02C4;MODIFIER LETTER UP ARROWHEAD
  replace("˄", "^")
  # 02C6;MODIFIER LETTER CIRCUMFLEX ACCENT
  replace("ˆ", "^")
  # 02D0;MODIFIER LETTER TRIANGULAR COLON
  replace("ː", ":")
  # 02DC;SMALL TILDE
  replace("˜", "~")
  # 2016;DOUBLE VERTICAL LINE
  replace("‖", "||")
  # 2024;ONE DOT LEADER (compat)
  replace("․", ".")
  # 2025;TWO DOT LEADER (compat)
  replace("‥", "..")
  # 2026;HORIZONTAL ELLIPSIS (compat)
  replace("…", "...")
  # 203C;DOUBLE EXCLAMATION MARK (compat)
  replace("‼", "!!")
  # 2044;FRACTION SLASH (from ‹character-fallback›)
  replace("⁄", "/")
  # 2045;LEFT SQUARE BRACKET WITH QUILL
  replace("⁅", "[")
  # 2046;RIGHT SQUARE BRACKET WITH QUILL
  replace("⁆", "]")
  # 2047;DOUBLE QUESTION MARK (compat)
  replace("⁇", "??")
  # 2048;QUESTION EXCLAMATION MARK (compat)
  replace("⁈", "?!")
  # 2049;EXCLAMATION QUESTION MARK (compat)
  replace("⁉", "!?")
  # 204E;LOW ASTERISK
  replace("⁎", "*")
  # 2190;LEFTWARDS ARROW
  replace("\←", "<-")
  # 2192;RIGHTWARDS ARROW
  replace("\→", "->")
  # 2194;LEFT RIGHT ARROW
  replace("\↔", "<->")
  # FFE9;HALFWIDTH LEFTWARDS ARROW
  replace("￩", "<-")
  # FFEB;HALFWIDTH RIGHTWARDS ARROW
  replace("￫", "->")
  # CJK
  # 3001;IDEOGRAPHIC COMMA
  replace("、", ",")
  # 3002;IDEOGRAPHIC FULL STOP
  replace("。", ".")
  # 3008;LEFT ANGLE BRACKET
  replace("〈", "<")
  # 3009;RIGHT ANGLE BRACKET
  replace("〉", ">")
  # 300A;LEFT DOUBLE ANGLE BRACKET
  replace("《", "<<")
  # 300B;RIGHT DOUBLE ANGLE BRACKET
  replace("》", ">>")
  # 3014;LEFT TORTOISE SHELL BRACKET
  replace("〔", "[")
  # 3015;RIGHT TORTOISE SHELL BRACKET
  replace("〕", "]")
  # 3018;LEFT WHITE TORTOISE SHELL BRACKET
  replace("〘", "[")
  # 3019;RIGHT WHITE TORTOISE SHELL BRACKET
  replace("〙", "]")
  # 301A;LEFT WHITE SQUARE BRACKET
  replace("〚", "[")
  # 301B;RIGHT WHITE SQUARE BRACKET
  replace("〛", "]")
  # Vertical and small forms
  # FE10;PRESENTATION FORM FOR VERTICAL COMMA (compat)
  replace("︐", ",")
  # FE11;PRESENTATION FORM FOR VERTICAL IDEOGRAPHIC COMMA (compat)
  replace("︑", ",")
  # FE12;PRESENTATION FORM FOR VERTICAL IDEOGRAPHIC FULL STOP (compat)
  replace("︒", ".")
  # FE13;PRESENTATION FORM FOR VERTICAL COLON (compat)
  replace("︓", ":")
  # FE14;PRESENTATION FORM FOR VERTICAL SEMICOLON (compat)
  replace("︔", ";")
  # FE15;PRESENTATION FORM FOR VERTICAL EXCLAMATION MARK (compat)
  replace("︕", "!")
  # FE16;PRESENTATION FORM FOR VERTICAL QUESTION MARK (compat)
  replace("︖", "?")
  # FE19;PRESENTATION FORM FOR VERTICAL HORIZONTAL ELLIPSIS (compat)
  replace("︙", "...")
  # FE30;PRESENTATION FORM FOR VERTICAL TWO DOT LEADER (compat)
  replace("︰", "..")
  # FE35;PRESENTATION FORM FOR VERTICAL LEFT PARENTHESIS (compat)
  replace("︵", "(")
  # FE36;PRESENTATION FORM FOR VERTICAL RIGHT PARENTHESIS (compat)
  replace("︶", ")")
  # FE37;PRESENTATION FORM FOR VERTICAL LEFT CURLY BRACKET (compat)
  replace("︷", "{")
  # FE38;PRESENTATION FORM FOR VERTICAL RIGHT CURLY BRACKET (compat)
  replace("︸", "}")
  # FE39;PRESENTATION FORM FOR VERTICAL LEFT TORTOISE SHELL BRACKET (compat)
  replace("︹", "[")
  # FE3A;PRESENTATION FORM FOR VERTICAL RIGHT TORTOISE SHELL BRACKET (compat)
  replace("︺", "]")
  # FE3D;PRESENTATION FORM FOR VERTICAL LEFT DOUBLE ANGLE BRACKET (compat)
  replace("︽", "<<")
  # FE3E;PRESENTATION FORM FOR VERTICAL RIGHT DOUBLE ANGLE BRACKET (compat)
  replace("︾", ">>")
  # FE3F;PRESENTATION FORM FOR VERTICAL LEFT ANGLE BRACKET (compat)
  replace("︿", "<")
  # FE40;PRESENTATION FORM FOR VERTICAL RIGHT ANGLE BRACKET (compat)
  replace("﹀", ">")
  # FE47;PRESENTATION FORM FOR VERTICAL LEFT SQUARE BRACKET (compat)
  replace("﹇", "[")
  # FE48;PRESENTATION FORM FOR VERTICAL RIGHT SQUARE BRACKET (compat)
  replace("﹈", "]")
  # FE50;SMALL COMMA (compat)
  replace("﹐", ",")
  # FE51;SMALL IDEOGRAPHIC COMMA (compat)
  replace("﹑", ",")
  # FE52;SMALL FULL STOP (compat)
  replace("﹒", ".")
  # FE54;SMALL SEMICOLON (compat)
  replace("﹔", ";")
  # FE55;SMALL COLON (compat)
  replace("﹕", ":")
  # FE56;SMALL QUESTION MARK (compat)
  replace("﹖", "?")
  # FE57;SMALL EXCLAMATION MARK (compat)
  replace("﹗", "!")
  # FE59;SMALL LEFT PARENTHESIS (compat)
  replace("﹙", "(")
  # FE5A;SMALL RIGHT PARENTHESIS (compat)
  replace("﹚", ")")
  # FE5B;SMALL LEFT CURLY BRACKET (compat)
  replace("﹛", "{")
  # FE5C;SMALL RIGHT CURLY BRACKET (compat)
  replace("﹜", "}")
  # FE5D;SMALL LEFT TORTOISE SHELL BRACKET (compat)
  replace("﹝", "[")
  # FE5E;SMALL RIGHT TORTOISE SHELL BRACKET (compat)
  replace("﹞", "]")
  # FE5F;SMALL NUMBER SIGN (compat)
  replace("﹟", "#")
  # FE60;SMALL AMPERSAND (compat)
  replace("﹠", "&")
  # FE61;SMALL ASTERISK (compat)
  replace("﹡", "*")
  # FE62;SMALL PLUS SIGN (compat)
  replace("﹢", "+")
  # FE64;SMALL LESS-THAN SIGN (compat)
  replace("﹤", "<")
  # FE65;SMALL GREATER-THAN SIGN (compat)
  replace("﹥", ">")
  # FE66;SMALL EQUALS SIGN (compat)
  replace("﹦", "=")
  # FE68;SMALL REVERSE SOLIDUS (compat)
  replace("﹨", "'")
  # FE69;SMALL DOLLAR SIGN (compat)
  replace("﹩", "$")
  # FE6A;SMALL PERCENT SIGN (compat)
  replace("﹪", "%")
  # FE6B;SMALL COMMERCIAL AT (compat)
  replace("﹫", "@")
  # Fullwidth and halfwidth
  # FF01;FULLWIDTH EXCLAMATION MARK (compat)
  replace("！", "!")
  # FF03;FULLWIDTH NUMBER SIGN (compat)
  replace("＃", "#")
  # FF04;FULLWIDTH DOLLAR SIGN (compat)
  replace("＄", "$")
  # FF05;FULLWIDTH PERCENT SIGN (compat)
  replace("％", "%")
  # FF06;FULLWIDTH AMPERSAND (compat)
  replace("＆", "&")
  # FF08;FULLWIDTH LEFT PARENTHESIS (compat)
  replace("（", "(")
  # FF09;FULLWIDTH RIGHT PARENTHESIS (compat)
  replace("）", ")")
  # FF0A;FULLWIDTH ASTERISK (compat)
  replace("＊", "*")
  # FF0B;FULLWIDTH PLUS SIGN (compat)
  replace("＋", "+")
  # FF0C;FULLWIDTH COMMA (compat)
  replace("，", ",")
  # FF0E;FULLWIDTH FULL STOP (compat)
  replace("．", ".")
  # FF0F;FULLWIDTH SOLIDUS (compat)
  replace("／", "/")
  # FF1A;FULLWIDTH COLON (compat)
  replace("：", ":")
  # FF1B;FULLWIDTH SEMICOLON (compat)
  replace("；", ";")
  # FF1C;FULLWIDTH LESS-THAN SIGN (compat)
  replace("＜", "<")
  # FF1D;FULLWIDTH EQUALS SIGN (compat)
  replace("＝", "=")
  # FF1E;FULLWIDTH GREATER-THAN SIGN (compat)
  replace("＞", ">")
  # FF1F;FULLWIDTH QUESTION MARK (compat)
  replace("？", "?")
  # FF20;FULLWIDTH COMMERCIAL AT (compat)
  replace("＠", "@")
  # FF3B;FULLWIDTH LEFT SQUARE BRACKET (compat)
  replace("［", "[")
  # FF3C;FULLWIDTH REVERSE SOLIDUS (compat)
  replace("＼", "'")
  # FF3D;FULLWIDTH RIGHT SQUARE BRACKET (compat)
  replace("］", "]")
  # FF3E;FULLWIDTH CIRCUMFLEX ACCENT (compat)
  replace("＾", "^")
  # FF3F;FULLWIDTH LOW LINE (compat)
  replace("＿", "_")
  # FF40;FULLWIDTH GRAVE ACCENT (compat)
  replace("｀", "`")
  # FF5B;FULLWIDTH LEFT CURLY BRACKET (compat)
  replace("｛", "{")
  # FF5C;FULLWIDTH VERTICAL LINE (compat)
  replace("｜", "|")
  # FF5D;FULLWIDTH RIGHT CURLY BRACKET (compat)
  replace("｝", "}")
  # FF5E;FULLWIDTH TILDE (compat)
  replace("～", "~")
  # FF5F;FULLWIDTH LEFT WHITE PARENTHESIS (compat)(from ‹character-fallback›)
  replace("｟", "((")
  # FF60;FULLWIDTH RIGHT WHITE PARENTHESIS (compat)(from ‹character-fallback›)
  replace("｠", "))")
  # FF61;HALFWIDTH IDEOGRAPHIC FULL STOP (compat)
  replace("｡", ".")
  # FF64;HALFWIDTH IDEOGRAPHIC COMMA (compat)
  replace("､", ",")
  #
  # Other math operators (non-ASCII-range)
  #
  # 00B1;PLUS-MINUS SIGN
  replace("±", "+/-")
  # 00D7;MULTIPLICATION SIGN
  replace("×", "*")
  # 00F7;DIVISION SIGN
  replace("÷", "/")
  # 02D6;MODIFIER LETTER PLUS SIGN
  replace("˖", "+")
  # 02D7;MODIFIER LETTER MINUS SIGN
  replace("˗", "-")
  # 2212;MINUS SIGN (from ‹character-fallback›)
  replace("−", "-")
  # 2215;DIVISION SLASH (from ‹character-fallback›)
  replace("∕", "/")
  # 2216;SET MINUS (from ‹character-fallback›)
  replace("∖", "'")
  # 2223;DIVIDES (from ‹character-fallback›)
  replace("∣", "|")
  # 2225;PARALLEL TO (from ‹character-fallback›)
  replace("∥", "||")
  # 226A;MUCH LESS-THAN
  replace("≪", "<<")
  # 226B;MUCH GREATER-THAN
  replace("≫", ">>")
  # 2985;LEFT WHITE PARENTHESIS
  replace("⦅", "((")
  # 2986;RIGHT WHITE PARENTHESIS
  replace("⦆", "))")
  # 2A74;DOUBLE COLON EQUAL (compat)
  replace("⩴", "::=")
  # 2A75;TWO CONSECUTIVE EQUALS SIGNS (compat)
  replace("⩵", "==")
  # 2A76;THREE CONSECUTIVE EQUALS SIGNS (compat)
  replace("⩶", "===")
  #
end