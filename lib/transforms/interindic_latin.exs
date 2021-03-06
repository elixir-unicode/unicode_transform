defmodule Unicode.Transform.InterindicLatin do
  use Unicode.Transform

  # This file is generated. Manual changes are not recommended
  # Source: InterIndic
  # Target: Latin
  # Transform direction: forward
  # Transform alias: 

  #
  # InterIndic-Latin
  # \u0E00 reserved
  # consonants
  define("$chandrabindu", "uE001")
  define("$anusvara", "uE002")
  define("$visarga", "uE003")
  # \u0E004 reserved
  # w←vowel→ represents the stand-alone form
  define("$wa", "uE005")
  define("$waa", "uE006")
  define("$wi", "uE007")
  define("$wii", "uE008")
  define("$wu", "uE009")
  define("$wuu", "uE00A")
  define("$wr", "uE00B")
  define("$wl", "uE00C")
  # LETTER CANDRA E
  define("$wce", "uE00D")
  # LETTER SHORT E
  define("$wse", "uE00E")
  # ए LETTER E
  define("$we", "uE00F")
  define("$wai", "uE010")
  # LETTER CANDRA O
  define("$wco", "uE011")
  # LETTER SHORT O
  define("$wso", "uE012")
  # ओ LETTER O
  define("$wo", "uE013")
  define("$wau", "uE014")
  define("$ka", "uE015")
  define("$kha", "uE016")
  define("$ga", "uE017")
  define("$gha", "uE018")
  define("$nga", "uE019")
  define("$ca", "uE01A")
  define("$cha", "uE01B")
  define("$ja", "uE01C")
  define("$jha", "uE01D")
  define("$nya", "uE01E")
  define("$tta", "uE01F")
  define("$ttha", "uE020")
  define("$dda", "uE021")
  define("$ddha", "uE022")
  define("$nna", "uE023")
  define("$ta", "uE024")
  define("$tha", "uE025")
  define("$da", "uE026")
  define("$dha", "uE027")
  define("$na", "uE028")
  # compatibility
  define("$ena", "uE029")
  define("$pa", "uE02A")
  define("$pha", "uE02B")
  define("$ba", "uE02C")
  define("$bha", "uE02D")
  define("$ma", "uE02E")
  define("$ya", "uE02F")
  define("$ra", "uE030")
  define("$vva", "uE081")
  define("$rra", "uE031")
  define("$la", "uE032")
  define("$lla", "uE033")
  # compatibility
  define("$ela", "uE034")
  define("$va", "uE035")
  define("$sha", "uE036")
  define("$ssa", "uE037")
  define("$sa", "uE038")
  define("$ha", "uE039")
  # \u093A Reserved
  # \u093B Reserved
  define("$nukta", "uE03C")
  # SIGN AVAGRAHA
  define("$avagraha", "uE03D")
  # ←vowel→ represents the dependent form
  define("$aa", "uE03E")
  define("$i", "uE03F")
  define("$ii", "uE040")
  define("$u", "uE041")
  define("$uu", "uE042")
  define("$rh", "uE043")
  define("$rrh", "uE044")
  # VOWEL SIGN CANDRA E
  define("$ce", "uE045")
  # VOWEL SIGN SHORT E
  define("$se", "uE046")
  define("$e", "uE047")
  define("$ai", "uE048")
  # VOWEL SIGN CANDRA O
  define("$co", "uE049")
  # VOWEL SIGN SHORT O
  define("$so", "uE04A")
  # ो
  define("$o", "uE04B")
  define("$au", "uE04C")
  define("$virama", "uE04D")
  # \u094E Reserved
  # \u094F Reserved
  # OM
  define("$om", "uE050")
  # UNMAPPED STRESS SIGN UDATTA
  replace("\uE051", "")
  # UNMAPPED STRESS SIGN ANUDATTA
  replace("\uE052", "")
  # UNMAPPED GRAVE ACCENT
  replace("\uE053", "")
  # UNMAPPED ACUTE ACCENT
  replace("\uE054", "")
  # Telugu Length Mark
  define("$lm", "uE055")
  # AI Length Mark
  define("$ailm", "uE056")
  # AU Length Mark
  define("$aulm", "uE057")
  # urdu compatibity forms
  define("$uka", "uE058")
  define("$ukha", "uE059")
  define("$ugha", "uE05A")
  define("$ujha", "uE05B")
  define("$uddha", "uE05C")
  define("$udha", "uE05D")
  define("$ufa", "uE05E")
  define("$uya", "uE05F")
  define("$wrr", "uE060")
  define("$wll", "uE061")
  define("$lh", "uE062")
  define("$llh", "uE063")
  define("$danda", "uE064")
  define("$doubleDanda", "uE065")
  # DIGIT ZERO
  define("$zero", "uE066")
  # DIGIT ONE
  define("$one", "uE067")
  # DIGIT TWO
  define("$two", "uE068")
  # DIGIT THREE
  define("$three", "uE069")
  # DIGIT FOUR
  define("$four", "uE06A")
  # DIGIT FIVE
  define("$five", "uE06B")
  # DIGIT SIX
  define("$six", "uE06C")
  # DIGIT SEVEN
  define("$seven", "uE06D")
  # DIGIT EIGHT
  define("$eight", "uE06E")
  # DIGIT NINE
  define("$nine", "uE06F")
  # Glottal stop
  define("$dgs", "uE082")
  # Khanda-ta
  define("$kta", "uE083")
  define("$depVowelAbove", "[uE03E-uE040uE045-uE04C]")
  define("$depVowelBelow", "[uE041-uE044]")
  # $x was originally called '§'; $z was '%'
  define("$x", "[$aa$ai$au$ii$i$uu$u$rrh$rh$lh$llh$e$o$se$ce$so$co]")
  define("$z", "[bcdfghjklmnpqrstvwxyz]")
  define("$vowels", "[aeiour̥̄̆]")
  define("$forceIndependentMatra", "[^[[:L:][̀-͌]]]")
  # #####################################################################
  # convert from Native letters to Latin letters
  # #####################################################################
  # transliterations for anusvara
  replace("$anusvara", "ṅ", followed_by: "[$ka$kha$ga$gha$nga]")
  replace("$anusvara", "n̄", followed_by: "[$ca$cha$ja$jha$nya]")
  replace("$anusvara", "ṇ", followed_by: "[$tta$ttha$dda$ddha$nna]")
  replace("$anusvara", "n", followed_by: "[$ta$tha$da$dha$na]")
  replace("$anusvara", "m", followed_by: "[$pa$pha$ba$bha$ma]")
  replace("$anusvara", "n", followed_by: "[$ya$ra$lla$la$va$ssa$sha$sa$ha]")
  replace("$anusvara", "ṁ")
  # Urdu compatibility
  replace("$ya$nukta", "ẏ", followed_by: "$x")
  replace("$ya$nukta$virama", "ẏ")
  replace("$ya$nukta", "ẏa")
  replace("$la$nukta", "ḻ", followed_by: "$x")
  replace("$la$nukta$virama", "ḻ")
  replace("$la$nukta", "ḻa")
  replace("$na$nukta", "ṉ", followed_by: "$x")
  replace("$na$nukta$virama", "ṉ")
  replace("$na$nukta", "ṉa")
  replace("$ena", "ṉ", followed_by: "$x")
  replace("$ena$virama", "ṉ")
  replace("$ena", "ṉa")
  replace("$uka", "qa")
  replace("$ka$nukta", "q", followed_by: "$x")
  replace("$ka$nukta$virama", "q")
  replace("$ka$nukta", "qa")
  replace("$kha$nukta", "ḵẖ", followed_by: "$x")
  replace("$kha$nukta$virama", "ḵẖ")
  replace("$kha$nukta", "ḵẖa")
  replace("$ukha$virama", "ḵẖ")
  replace("$ukha", "ḵẖa")
  replace("$ugha", "ġa")
  replace("$ga$nukta", "ġ", followed_by: "$x")
  replace("$ga$nukta$virama", "ġ")
  replace("$ga$nukta", "ġa")
  replace("$ujha", "za")
  replace("$ja$nukta", "z", followed_by: "$x")
  replace("$ja$nukta$virama", "z")
  replace("$ja$nukta", "za")
  replace("$ddha$nukta", "ṛh", followed_by: "$x")
  replace("$ddha$nukta$virama", "ṛh")
  replace("$ddha$nukta", "ṛha")
  replace("$uddha", "ṛ", followed_by: "$x")
  replace("$uddha$virama", "ṛ")
  replace("$uddha", "ṛa")
  replace("$udha", "ṛa")
  replace("$dda$nukta", "ṛ", followed_by: "$x")
  replace("$dda$nukta$virama", "ṛ")
  replace("$dda$nukta", "ṛa")
  replace("$pha$nukta", "f", followed_by: "$x")
  replace("$pha$nukta$virama", "f")
  replace("$pha$nukta", "fa")
  replace("$ufa", "f", followed_by: "$x")
  replace("$ufa$virama", "f")
  replace("$ufa", "fa")
  replace("$ra$nukta", "ṟ", followed_by: "$x")
  replace("$ra$nukta$virama", "ṟ")
  replace("$ra$nukta", "ṟa")
  replace("$lla$nukta", "ḻ", followed_by: "$x")
  replace("$lla$nukta$virama", "ḻ")
  replace("$lla$nukta", "ḻa")
  replace("$ela", "ḻ", followed_by: "$x")
  replace("$ela$virama", "ḻ")
  replace("$ela", "ḻa")
  replace("$uya", "ẏ", followed_by: "$x")
  replace("$uya$virama", "ẏ")
  replace("$uya", "ẏa")
  # normal consonants
  replace("$ka$virama", "k", followed_by: "$ha")
  replace("$ka", "k", followed_by: "$x")
  replace("$ka$virama", "k")
  replace("$ka", "ka")
  replace("$kha", "kh", followed_by: "$x")
  replace("$kha$virama", "kh")
  replace("$kha", "kha")
  replace("$ga$virama", "g", followed_by: "$ha")
  replace("$ga", "g", followed_by: "$x")
  replace("$ga$virama", "g")
  replace("$ga", "ga")
  replace("$gha", "gh", followed_by: "$x")
  replace("$gha$virama", "gh")
  replace("$gha", "gha")
  replace("$nga", "ṅ", followed_by: "$x")
  replace("$nga$virama", "ṅ")
  replace("$nga", "ṅa")
  replace("$ca$virama", "c", followed_by: "$ha")
  replace("$ca", "c", followed_by: "$x")
  replace("$ca$virama", "c")
  replace("$ca", "ca")
  replace("$cha", "ch", followed_by: "$x")
  replace("$cha$virama", "ch")
  replace("$cha", "cha")
  replace("$ja$virama", "j", followed_by: "$ha")
  replace("$ja", "j", followed_by: "$x")
  replace("$ja$virama", "j")
  replace("$ja", "ja")
  replace("$jha", "jh", followed_by: "$x")
  replace("$jha$virama", "jh")
  replace("$jha", "jha")
  replace("$nya", "ñ", followed_by: "$x")
  replace("$nya$virama", "ñ")
  replace("$nya", "ña")
  replace("$tta$virama", "ṭ", followed_by: "$ha")
  replace("$tta", "ṭ", followed_by: "$x")
  replace("$tta$virama", "ṭ")
  replace("$tta", "ṭa")
  replace("$ttha", "ṭh", followed_by: "$x")
  replace("$ttha$virama", "ṭh")
  replace("$ttha", "ṭha")
  replace("$dda", "ḍ", followed_by: "$x$ha")
  replace("$dda", "ḍ", followed_by: "$x")
  replace("$dda$virama", "ḍ")
  replace("$dda", "ḍa")
  replace("$ddha", "ḍh", followed_by: "$x")
  replace("$ddha$virama", "ḍh")
  replace("$ddha", "ḍha")
  replace("$nna", "ṇ", followed_by: "$x")
  replace("$nna$virama", "ṇ")
  replace("$nna", "ṇa")
  replace("$ta$virama", "t", followed_by: "$ha")
  replace("$ta$virama", "t", followed_by: "$ttha")
  replace("$ta$virama", "t", followed_by: "$tta")
  replace("$ta$virama", "t", followed_by: "$tha")
  replace("$ta", "t", followed_by: "$x")
  replace("$ta$virama", "t")
  replace("$ta", "ta")
  replace("$tha", "th", followed_by: "$x")
  replace("$tha$virama", "th")
  replace("$tha", "tha")
  replace("$da$virama", "d", followed_by: "$ha")
  replace("$da$virama", "d", followed_by: "$ddha")
  replace("$da$virama", "d", followed_by: "$dda")
  replace("$da$virama", "d", followed_by: "$dha")
  replace("$da", "d", followed_by: "$x")
  replace("$da$virama", "d")
  replace("$da", "da")
  replace("$dha", "dh", followed_by: "$x")
  replace("$dha$virama", "dh")
  replace("$dha", "dha")
  replace("$na$virama", "n", followed_by: "$ga")
  replace("$na$virama", "n", followed_by: "$ya")
  replace("$na", "n", followed_by: "$x")
  replace("$na$virama", "n")
  replace("$na", "na")
  replace("$pa$virama", "p", followed_by: "$ha")
  replace("$pa", "p", followed_by: "$x")
  replace("$pa$virama", "p")
  replace("$pa", "pa")
  replace("$pha", "ph", followed_by: "$x")
  replace("$pha$virama", "ph")
  replace("$pha", "pha")
  replace("$ba$virama", "b", followed_by: "$ha")
  replace("$ba", "b", followed_by: "$x")
  replace("$ba$virama", "b")
  replace("$ba", "ba")
  replace("$bha", "bh", followed_by: "$x")
  replace("$bha$virama", "bh")
  replace("$bha", "bha")
  replace("$ma$virama", "m", followed_by: "$ma")
  replace("$ma", "m", followed_by: "$x")
  replace("$ma$virama", "m")
  replace("$ma", "ma")
  replace("$ya", "y", followed_by: "$x")
  replace("$ya$virama", "y")
  replace("$ya", "ya")
  replace("$ra$virama", "r", followed_by: "$ha")
  replace("$ra", "r", followed_by: "$x")
  replace("$ra$virama", "r")
  replace("$ra", "ra")
  replace("$vva$virama", "ẇ", followed_by: "$ha")
  replace("$vva", "ẇ", followed_by: "$x")
  replace("$vva$virama", "ẇ")
  replace("$vva", "ẇa")
  replace("$rra$virama", "ṟ", followed_by: "$ha")
  replace("$rra", "ṟ", followed_by: "$x")
  replace("$rra$virama", "ṟ")
  replace("$rra", "ṟa")
  replace("$la$virama", "l", followed_by: "$ha")
  replace("$la", "l", followed_by: "$x")
  replace("$la$virama", "l")
  replace("$la", "la")
  replace("$lla$virama", "ḷ", followed_by: "$ha")
  replace("$lla", "ḷ", followed_by: "$x")
  replace("$lla$virama", "ḷ")
  replace("$lla", "ḷa")
  replace("$va", "v", followed_by: "$x")
  replace("$va$virama", "v")
  replace("$va", "va")
  replace("$sa$virama", "s", followed_by: "$ha")
  replace("$sa$virama", "s", followed_by: "$sha")
  replace("$sa$virama", "s", followed_by: "$ssa")
  replace("$sa$virama", "s", followed_by: "$sa")
  replace("$sa", "s", followed_by: "$x")
  replace("$sa$virama", "s")
  # for gurmukhi
  replace("$sa$nukta", "ś", followed_by: "$x")
  replace("$sa$nukta$virama", "ś")
  replace("$sa$nukta", "śa")
  replace("$sa", "sa")
  replace("$sha", "ś", followed_by: "$x")
  replace("$sha$virama", "ś")
  replace("$sha", "śa")
  replace("$ssa", "ṣ", followed_by: "$x")
  replace("$ssa$virama", "ṣ")
  replace("$ssa", "ṣa")
  replace("$ha", "h", followed_by: "$x")
  replace("$ha$virama", "h")
  replace("$ha", "ha")
  # dependent vowels (should never occur except following consonants)
  replace("$aa", "̔ā", preceeded_by: "$forceIndependentMatra")
  replace("$ai", "̔ai", preceeded_by: "$forceIndependentMatra")
  replace("$au", "̔au", preceeded_by: "$forceIndependentMatra")
  replace("$ii", "̔ī", preceeded_by: "$forceIndependentMatra")
  replace("$i", "̔i", preceeded_by: "$forceIndependentMatra")
  replace("$uu", "̔ū", preceeded_by: "$forceIndependentMatra")
  replace("$u", "̔u", preceeded_by: "$forceIndependentMatra")
  replace("$rrh", "̔r̥̄", preceeded_by: "$forceIndependentMatra")
  replace("$rh", "̔r̥", preceeded_by: "$forceIndependentMatra")
  replace("$llh", "̔l̥̄", preceeded_by: "$forceIndependentMatra")
  replace("$lh", "̔l̥", preceeded_by: "$forceIndependentMatra")
  replace("$e", "̔ē", preceeded_by: "$forceIndependentMatra")
  replace("$o", "̔ō", preceeded_by: "$forceIndependentMatra")
  # extra vowels
  replace("$ce", "̔ĕ", preceeded_by: "$forceIndependentMatra")
  replace("$co", "̔ŏ", preceeded_by: "$forceIndependentMatra")
  replace("$se", "̔e", preceeded_by: "$forceIndependentMatra")
  replace("$so", "̔o", preceeded_by: "$forceIndependentMatra")
  # Nukta cannot appear independently or as first character
  replace("$nukta", "", preceeded_by: "$forceIndependentMatra")
  # Virama cannot appear independently or as first character
  replace("$virama", "", preceeded_by: "$forceIndependentMatra")
  replace("$aa", "ā")
  replace("$ai", "ai")
  replace("$au", "au")
  replace("$ii", "ī")
  replace("$i", "i")
  replace("$uu", "ū")
  replace("$u", "u")
  replace("$rrh", "r̥̄")
  replace("$rh", "r̥")
  replace("$llh", "l̥̄")
  replace("$lh", "l̥")
  replace("$e", "ē")
  replace("$o", "ō")
  # extra vowels
  replace("$ce", "ĕ")
  replace("$co", "ŏ")
  replace("$se", "e")
  replace("$so", "o")
  # dependent vowels when following independent vowels. Generally Illegal only for roundtripping
  replace("$waa", "ā̔", followed_by: "$x")
  replace("$wai", "ai̔", followed_by: "$x")
  replace("$wau", "au̔", followed_by: "$x")
  replace("$wii", "ī̔", followed_by: "$x")
  replace("$wi", "i̔", followed_by: "$x")
  replace("$wuu", "ū̔", followed_by: "$x")
  replace("$wu", "u̔", followed_by: "$x")
  replace("$wrr", "r̥̄̔", followed_by: "$x")
  replace("$wr", "r̥̔", followed_by: "$x")
  replace("$wll", "l̥̄̔", followed_by: "$x")
  replace("$wl", "l̥̔", followed_by: "$x")
  replace("$we", "ē̔", followed_by: "$x")
  replace("$wo", "ō̔", followed_by: "$x")
  replace("$wa", "a̔", followed_by: "$x")
  # extra vowels
  replace("$wce", "ĕ̔", followed_by: "$x")
  replace("$wco", "ŏ̔", followed_by: "$x")
  replace("$wse", "e̔", followed_by: "$x")
  replace("$wso", "o̔", followed_by: "$x")
  replace("$om", "om̔", followed_by: "$x")
  # independent vowels when preceeded by vowels
  replace("$waa", "ā", preceeded_by: "$vowels")
  replace("$wai", "ai", preceeded_by: "$vowels")
  replace("$wau", "au", preceeded_by: "$vowels")
  replace("$wii", "ī", preceeded_by: "$vowels")
  replace("$wi", "i", preceeded_by: "$vowels")
  replace("$wuu", "ū", preceeded_by: "$vowels")
  replace("$wu", "u", preceeded_by: "$vowels")
  replace("$wrr", "r̥̄", preceeded_by: "$vowels")
  replace("$wr", "r̥", preceeded_by: "$vowels")
  replace("$wll", "l̥̄", preceeded_by: "$vowels")
  replace("$wl", "l̥", preceeded_by: "$vowels")
  replace("$we", "ē", preceeded_by: "$vowels")
  replace("$wo", "ō", preceeded_by: "$vowels")
  replace("$wa", "a", preceeded_by: "$vowels")
  # extra vowels
  replace("$wce", "ĕ", preceeded_by: "$vowels")
  replace("$wco", "ŏ", preceeded_by: "$vowels")
  replace("$wse", "e", preceeded_by: "$vowels")
  replace("$wso", "o", preceeded_by: "$vowels")
  # independent vowels (otherwise)
  replace("$waa", "ā")
  replace("$wai", "ai")
  replace("$wau", "au")
  replace("$wii", "ī")
  replace("$wi", "i")
  replace("$wuu", "ū")
  replace("$wu", "u")
  replace("$wrr", "r̥̄")
  replace("$wr", "r̥")
  replace("$wll", "l̥̄")
  replace("$wl", "l̥")
  replace("$we", "ē")
  replace("$wo", "ō")
  replace("$wa", "a")
  # extra vowels
  replace("$wce", "ĕ")
  replace("$wco", "ŏ")
  replace("$wse", "e")
  replace("$wso", "o")
  replace("$om", "om")
  # stress marks
  replace("$avagraha", "̕")
  replace("$chandrabindu$anusvara", "̃")
  replace("$chandrabindu", "m̐")
  replace("$visarga", "ḥ")
  # numbers
  replace("$zero", "0")
  replace("$one", "1")
  replace("$two", "2")
  replace("$three", "3")
  replace("$four", "4")
  replace("$five", "5")
  replace("$six", "6")
  replace("$seven", "7")
  replace("$eight", "8")
  replace("$nine", "9")
  replace("$lm", "")
  replace("$ailm", "")
  replace("$aulm", "")
  replace("$dgs", "ʔ")
  replace("$kta", "ṯ")
  replace("$danda", ".")
  replace("$doubleDanda", ".")
  # ABBREVIATION SIGN
  replace("\uE070", "")
  # LETTER RA WITH MIDDLE DIAGONAL
  replace("\uE071", "ra", followed_by: "$x")
  replace("\uE071$virama", "r")
  replace("\uE071", "ra")
  # LETTER RA WITH LOWER DIAGONAL
  replace("\uE072", "ra", followed_by: "$x")
  replace("\uE072$virama", "r")
  replace("\uE072", "ra")
  # RUPEE MARK
  replace("\uE073", "")
  # RUPEE SIGN
  replace("\uE074", "")
  # CURRENCY NUMERATOR ONE
  replace("\uE075", "")
  # CURRENCY NUMERATOR TWO
  replace("\uE076", "")
  # CURRENCY NUMERATOR THREE
  replace("\uE077", "")
  # CURRENCY NUMERATOR FOUR
  replace("\uE078", "")
  # CURRENCY NUMERATOR ONE LESS THAN THE DENOMINATOR
  replace("\uE079", "")
  # CURRENCY DENOMINATOR SIXTEEN
  replace("\uE07A", "")
  # ISSHAR
  replace("\uE07B", "")
  # TIPPI
  replace("\uE07C", "")
  # ADDAK
  replace("\uE07D", "")
  # IRI
  replace("\uE07E", "")
  # URA
  replace("\uE07F", "")
  # EK ONKAR
  replace("\uE080", "")
  # DEVANAGARI VOWEL SIGN SHORT A
  replace("\uE004", "")
  #
end