defmodule Unicode.Transform.DeAscii do
  use Unicode.Transform

  # This file is generated. Manual changes are not recommended
  # Source: de
  # Target: ASCII
  # Transform direction: forward
  # Transform alias: de-t-de-d0-ascii

  #
  define("$AE", "[Ä {A u0308}]")
  define("$OE", "[Ö {O u0308}]")
  define("$UE", "[Ü {U u0308}]")
  #
  replace("[ä {a \u0308}]", "ae")
  replace("[ö {o \u0308}]", "oe")
  replace("[ü {u \u0308}]", "ue")
  #
  replace("$AE", "Ae", followed_by: "[:Lowercase:]")
  replace("$OE", "Oe", followed_by: "[:Lowercase:]")
  replace("$UE", "Ue", followed_by: "[:Lowercase:]")
  #
  replace("$AE", "AE")
  replace("$OE", "OE")
  replace("$UE", "UE")
  #
  #
  transform("Any-ASCII")
  #
end