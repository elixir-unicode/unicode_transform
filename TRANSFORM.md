  #### 10.3.5 <a name="Rule_Syntax" href="#Rule_Syntax">Rule Syntax</a>

  The following describes the full format of the list of rules used to create a transform. Each rule in the list is terminated by a semicolon. The list consists of the following:

  * an optional filter rule
  * zero or more transform rules
  * zero or more variable-definition rules
  * zero or more conversion rules
  * an optional inverse filter rule

  The filter rule, if present, must appear at the beginning of the list, before any of the other rules.  The inverse filter rule, if present, must appear at the end of the list, after all of the other rules.  The other rules may occur in any order and be freely intermixed.

  The rule list can also generate the inverse of the transform. In that case, the inverse of each of the rules is used, as described below.

  #### 10.3.6 <a name="Transform_Rules" href="#Transform_Rules">Transform Rules</a>

  Each transform rule consists of two colons followed by a transform name, which is of the form source-target. For example:

  ```
  :: NFD ;
  :: und_Latn-und_Greek ;
  :: Latin-Greek; # alternate form
  ```

  If either the source or target is 'und', it can be omitted, thus 'und_NFC' is equivalent to 'NFC'. For compatibility, the English names for scripts can be used instead of the und_Latn locale name, and "Any" can be used instead of "und". Case is not significant.

  The following transforms are defined not by rules, but by the operations in the Unicode Standard, and may be used in building any other transform:

  > **Any-NFC, Any-NFD, Any-NFKD, Any-NFKC** - the normalization forms defined by [[UAX15](https://www.unicode.org/reports/tr41/#UAX15)].
  >
  > **Any-Lower, Any-Upper, Any-Title** - full case transformations, defined by [[Unicode](tr35.md#Unicode)] Chapter 3.

  In addition, the following special cases are defined:

  > **Any-Null** - has no effect; that is, each character is left alone.
  > **Any-Remove** - maps each character to the empty string; this, removes each character.

  The inverse of a transform rule uses parentheses to indicate what should be done when the inverse transform is used. For example:

  ```
  :: lower () ; # only executed for the normal
  :: (lower) ; # only executed for the inverse
  :: lower ; # executed for both the normal and the inverse
  ```

  #### 10.3.7 <a name="Variable_Definition_Rules" href="#Variable_Definition_Rules">Variable Definition Rules</a>

  Each variable definition is of the following form:

  ```
  $variableName = contents ;
  ```

  The variable name can contain letters and digits, but must start with a letter. More precisely, the variable names use Unicode identifiers as defined by [[UAX31](https://www.unicode.org/reports/tr41/#UAX31)]. The identifier properties allow for the use of foreign letters and numbers.

  The contents of a variable definition is any sequence of Unicode sets and characters or characters. For example:

  ```
  $mac = M [aA] [cC] ;
  ```

  Variables are only replaced within other variable definition rules and within conversion rules. They have no effect on transliteration rules.

  #### 10.3.8 <a name="Filter_Rules" href="#Filter_Rules">Filter Rules</a>

  A filter rule consists of two colons followed by a UnicodeSet. This filter is global in that only the characters matching the filter will be affected by any transform rules or conversion rules. The inverse filter rule consists of two colons followed by a UnicodeSet in parentheses. This filter is also global for the inverse transform.

  For example, the Hiragana-Latin transform can be implemented by "pivoting" through the Katakana converter, as follows:

  ```
  :: [:^Katakana:] ; # do not touch any katakana that was in the text!
  :: Hiragana-Katakana;
  :: Katakana-Latin;
  :: ([:^Katakana:]) ; # do not touch any katakana that was in the text
                       # for the inverse either!
  ```

  The filters keep the transform from mistakenly converting any of the "pivot" characters. Note that this is a case where a rule list contains no conversion rules at all, just transform rules and filters.

  #### 10.3.9 <a name="Conversion_Rules" href="#Conversion_Rules">Conversion Rules</a>

  Conversion rules can be forward, backward, or double. The complete conversion rule syntax is described below:

  **Forward**

  > A forward conversion rule is of the following form:
  > ```
  > before_context { text_to_replace } after_context → completed_result | result_to_revisit ;
  > ```
  > If there is no before_context, then the "{" can be omitted. If there is no after_context, then the "}" can be omitted. If there is no result_to_revisit, then the "|" can be omitted. A forward conversion rule is only executed for the normal transform and is ignored when generating the inverse transform.

  **Backward**

  > A backward conversion rule is of the following form:
  > ```
  > completed_result | result_to_revisit ← before_context { text_to_replace } after_context ;
  > ```
  > The same omission rules apply as in the case of forward conversion rules. A backward conversion rule is only executed for the inverse transform and is ignored when generating the normal transform.

  **Dual**

  > A dual conversion rule combines a forward conversion rule and a backward conversion rule into one, as discussed above. It is of the form:
  >
  > ```
  > a { b | c } d ↔ e { f | g } h ;
  > ```
  >
  > When generating the normal transform and the inverse, the revisit mark "|" and the before and after contexts are ignored on the sides where they do not belong. Thus, the above is exactly equivalent to the sequence of the following two rules:
  >
  > ```
  > a { b c } d → f | g  ;
  > b | c  ←  e { f g } h ;
  > ```

  #### 10.3.10 <a name="Intermixing_Transform_Rules_and_Conversion_Rules" href="#Intermixing_Transform_Rules_and_Conversion_Rules">Intermixing Transform Rules and Conversion Rules</a>

  Transform rules and conversion rules may be freely intermixed. Inserting a transform rule into the middle of a set of conversion rules has an important side effect.

  Normally, conversion rules are considered together as a group.  The only time their order in the rule set is important is when more than one rule matches at the same point in the string.  In that case, the one that occurs earlier in the rule set wins.  In all other situations, when multiple rules match overlapping parts of the string, the one that matches earlier wins.

  Transform rules apply to the whole string.  If you have several transform rules in a row, the first one is applied to the whole string, then the second one is applied to the whole string, and so on.  To reconcile this behavior with the behavior of conversion rules, transform rules have the side effect of breaking a surrounding set of conversion rules into two groups: First all of the conversion rules before the transform rule are applied as a group to the whole string in the usual way, then the transform rule is applied to the whole string, and then the conversion rules after the transform rule are applied as a group to the whole string.  For example, consider the following rules:

  ```
  abc → xyz;
  xyz → def;
  ::Upper;
  ```

  If you apply these rules to “abcxyz”, you get “XYZDEF”. If you move the “::Upper;” to the middle of the rule set and change the cases accordingly, then applying this to “abcxyz” produces “DEFDEF”.

  ```
  abc → xyz;
  ::Upper;
  XYZ → DEF;
  ```

  This is because “::Upper;” causes the transliterator to reset to the beginning of the string. The first rule turns the string into “xyzxyz”, the second rule upper cases the whole thing to “XYZXYZ”, and the third rule turns this into “DEFDEF”.

  This can be useful when a transform naturally occurs in multiple “passes.”  Consider this rule set:

  ```
  [:Separator:]* → ' ';
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  If you apply this rule to “high school”, you get “H.S.”, but if you apply it to “high  school” (with two spaces), you just get “high school” (with one space). To have “high school” (with two spaces) turn into “H.S.”, you'd either have to have the first rule back up some arbitrary distance (far enough to see “elementary”, if you want all the rules to work), or you have to include the whole left-hand side of the first rule in the other rules, which can make them hard to read and maintain:

  ```
  $space = [:Separator:]*;
  high $space school → 'H.S.';
  middle $space school → 'M.S.';
  elementary $space school → 'E.S.';
  ```

  Instead, you can simply insert “ `::Null;` ” in order to get things to work right:

  ```
  [:Separator:]* → ' ';
  ::Null;
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  The “::Null;” has no effect of its own (the null transform, by definition, does not do anything), but it splits the other rules into two “passes”: The first rule is applied to the whole string, normalizing all runs of white space into single spaces, and then we start over at the beginning of the string to look for the phrases. “high    school” (with four spaces) gets correctly converted to “H.S.”.

  This can also sometimes be useful with rules that have overlapping domains.  Consider this rule set from before:

  ```
  sch → sh ;
  ss → z ;
  ```

  Apply this rule to “bassch” results in “bazch” because “ss” matches earlier in the string than “sch”. If you really wanted “bassh”—that is, if you wanted the first rule to win even when the second rule matches earlier in the string, you'd either have to add another rule for this special case...

  ```
  sch → sh ;
  ssch → ssh;
  ss → z ;
  ```

  ...or you could use a transform rule to apply the conversions in two passes:

  ```
  sch → sh ;
  ::Null;
  ss → z ;
  ```

  #### 10.3.11 <a name="Inverse_Summary" href="#Inverse_Summary">Inverse Summary</a>

  The following table shows how the same rule list generates two different transforms, where the inverse is restated in terms of forward rules (this is a contrived example, simply to show the reordering):

  <!-- HTML: blocks in cells -->
  <table>
  <tr>
      <th>Original Rules</th>
      <th>Forward</th>
      <th>Inverse</th>
  </tr>
  <tr>
      <td><pre><code>:: [:Uppercase Letter:] ;
  :: latin-greek ;
  :: greek-japanese ;
  x ↔ y ;
  z → w ;
  r ← m ;
  :: upper;
  a → b ;
  c ↔ d ;
  :: any-publishing ;
  :: ([:Number:]) ;</code></pre></td>
      <td><pre><code>:: [:Uppercase Letter:] ;
  :: latin-greek ;
  :: greek-japanese ;
  x → y ;
  z → w ;
  :: upper ;
  a → b ;
  c → d ;
  :: any-publishing ;</code></pre></td>
      <td><pre><code>:: [:Number:] ;
  :: publishing-any ;
  d → c ;
  :: lower ;
  y → x ;
  m → r ;
  :: japanese-greek ;
  :: greek-latin ;</code></pre></td>
  </tr>
  </table>

  Note how the irrelevant rules (the inverse filter rule and the rules containing ←) are omitted (ignored, actually) in the forward direction, and notice how things are reversed: the transform rules are inverted and happen in the opposite order, and the groups of conversion rules are also executed in the opposite relative order (although the rules within each group are executed in the same order).
