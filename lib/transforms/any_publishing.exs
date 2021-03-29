defmodule Unicode.Transform.AnyPublishing do
  use Unicode.Transform

  # This file is generated. Manual changes are not recommended
  # Source: Any
  # Target: Publishing
  # Transform direction: both
  # Transform alias: und-t-d0-publish

  #
  # Variables
  define("$single", "'")
  define("$space", "' '")
  define("$double", "\"")
  define("$back", "`")
  define("$tab", "u0008")
  define("$makeRight", "[[:Z:][:Ps:][:Pi:]$]")
  #
  # fix UNIX quotes
  replace("$back $back", "“")
  replace("$back", "‘")
  #
  # fix typewriter quotes, by context
  replace("$double", "“", preceeded_by: "$makeRight")
  replace("$double", "”")
  replace("$single", "‘", preceeded_by: "$makeRight")
  replace("$single", "’")
  #
  replace("$space", "", preceeded_by: "$space")
  replace("<--->", "⟷")
  replace("<---", "⟵")
  replace("--->", "⟶")
  replace("<-->", "↔")
  replace("<--", "←")
  replace("-->", "→")
  replace("<-/->", "↮")
  replace("<-/-", "↚")
  replace("-/->", "↛")
  replace("<===>", "⟺")
  replace("<===", "⟸")
  replace("===>", "⟹")
  replace("<==>", "⇔")
  replace("<==", "⇐")
  replace("==>", "⇒")
  replace("!=", "≠")
  replace("<=", "≤")
  replace(">=", "≥")
  replace("+-", "±")
  replace("-+", "∓")
  replace("~=", "≅")
  replace("--", "—")
  replace("...", "…")
  #
  replace("\(C\)", "©")
  replace("\(c\)", "©")
  replace("\(R\)", "®")
  replace("\(r\)", "®")
  replace("\(TM\)", "™")
  replace("\(tm\)", "™")
  replace("c\/o", "℅")
  #
  replace("1\/2", "½", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("1\/3", "⅓", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("2\/3", "⅔", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("1\/4", "¼", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("3\/4", "¾", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("1\/5", "⅕", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("2\/5", "⅖", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("3\/5", "⅗", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("4\/5", "⅘", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("1\/6", "⅙", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("5\/6", "⅚", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("1\/8", "⅛", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("3\/8", "⅜", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("5\/8", "⅝", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  replace("7\/8", "⅞", preceeded_by: "[^0-9]", followed_by: "[^0-9]")
  #
end