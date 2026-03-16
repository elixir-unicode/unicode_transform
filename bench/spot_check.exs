Application.ensure_all_started(:req)

# Sample text for each source script
script_samples = %{
  "Any" => "café résumé ABC 123",
  "Latin" => "café résumé Ä Ö Ü ß Æ œ Ð þ Ł ñ",
  "Greek" => "αβγδεζηθικλμ",
  "Cyrillic" => "абвгдежзиклм",
  "Arabic" => "عربية كتابة",
  "Hebrew" => "שלום עולם",
  "Devanagari" => "हिन्दी नमस्ते",
  "Bengali" => "বাংলা লেখা",
  "Gujarati" => "ગુજરાતી લખાણ",
  "Gurmukhi" => "ਪੰਜਾਬੀ ਲਿਖਤ",
  "Kannada" => "ಕನ್ನಡ ಬರಹ",
  "Malayalam" => "മലയാളം എഴുത്ത്",
  "Oriya" => "ଓଡ଼ିଆ ଲେଖା",
  "Tamil" => "தமிழ் எழுத்து",
  "Telugu" => "తెలుగు రాత",
  "Thai" => "ภาษาไทย กรุงเทพ",
  "Hangul" => "한글 테스트 가나다",
  "Hiragana" => "あいうえおかきくけこ",
  "Katakana" => "アイウエオカキクケコ",
  "Armenian" => "Հայաստան երկիր",
  "Georgian" => "საქართველო ქალაქი",
  "Ethiopic" => "ኢትዮጵያ አዲስ",
  "Syriac" => "ܣܘܪܝܝܐ",
  "Thaana" => "ދިވެހި ބަސް",
  "Myanmar" => "မြန်မာ စာ",
  "Khmer" => "ភាសាខ្មែរ",
  "Lao" => "ພາສາລາວ",
  "Sinhala" => "සිංහල භාෂාව",
  "Han" => "漢字テスト",
  "Bopomofo" => "ㄅㄆㄇㄈㄉ",
  "Fullwidth" => "\uFF21\uFF22\uFF23\uFF24\uFF25",
  "Halfwidth" => "ｱｲｳｴｵ",
  "InterIndic" => "हिन्दी",
  "Jamo" => "ㅎㅏㄴㄱㅡㄹ"
}

# Locale/language-based source text
locale_samples = %{
  "am" => "ኢትዮጵያ",
  "ar" => "عربية كتابة",
  "az" => "Azərbaycan dili",
  "be" => "беларуская мова",
  "bg" => "български език",
  "bn" => "বাংলা ভাষা",
  "byn" => "ብሊን ቋንቋ",
  "cs" => "český jazyk",
  "de" => "Ä Ö Ü ß äöü",
  "el" => "ελληνικά κείμενο",
  "es" => "español texto ñ",
  "fa" => "فارسی نوشتار",
  "gu" => "ગુજરાતી",
  "he" => "עברית",
  "hi" => "हिन्दी भाषा",
  "hy" => "հայերեն լեdelays",
  "ja" => "あいうえお日本語",
  "ka" => "ქართული ენა",
  "kn" => "ಕನ್ನಡ",
  "ko" => "한국어 텍스트",
  "mk" => "македонски јазик",
  "ml" => "മലയാളം",
  "mn" => "монгол хэл",
  "my" => "မြန်မာ ဘာသာ",
  "or" => "ଓଡ଼ିଆ",
  "pa" => "ਪੰਜਾਬੀ",
  "ps" => "پښتو ژبه",
  "ru" => "русский язык",
  "sa" => "संस्कृतम्",
  "si" => "සිංහල",
  "ta" => "தமிழ்",
  "te" => "తెలుగు",
  "th" => "ภาษาไทย",
  "ti" => "ትግርኛ",
  "uk" => "українська мова",
  "uz" => "oʻzbek tili",
  "zh" => "中文文本"
}

defmodule SpotCheck do
  @demo_url "https://util.unicode.org/UnicodeJsps/transform.jsp"
  @max_runs 100

  def run(transforms, script_samples, locale_samples, count \\ @max_runs) do
    :rand.seed(:exsss, {42, 42, 42})
    selected = Enum.take_random(transforms, count)

    IO.puts("Starting #{length(selected)} spot checks against ICU demo site")
    IO.puts("Each check has a 30 second delay. Estimated time: #{div(length(selected) * 30, 60)} minutes\n")

    results =
      selected
      |> Enum.with_index(1)
      |> Enum.map(fn {transform_id, idx} ->
        input = pick_input(transform_id, script_samples, locale_samples)
        IO.write("[#{idx}/#{length(selected)}] #{transform_id} ... ")

        result = check_one(transform_id, input)

        case result do
          {:match, _, _} ->
            IO.puts("MATCH")
          {:mismatch, local, remote} ->
            IO.puts("MISMATCH")
            IO.puts("  Local:  #{inspect(local)}")
            IO.puts("  Remote: #{inspect(remote)}")
          {:error, reason} ->
            IO.puts("ERROR: #{inspect(reason)}")
        end

        if idx < length(selected) do
          Process.sleep(30_000)
        end

        {transform_id, input, result}
      end)

    print_summary(results)
    write_csv(results)
    results
  end

  defp pick_input(transform_id, script_samples, locale_samples) do
    source =
      case String.split(transform_id, "-", parts: 2) do
        [src, _] -> src
        [single] -> single
      end

    cond do
      Map.has_key?(script_samples, source) ->
        Map.get(script_samples, source)

      # Check locale-based names (lowercase 2-3 letter codes)
      String.match?(source, ~r/^[a-z]{2,3}$/) && Map.has_key?(locale_samples, source) ->
        Map.get(locale_samples, source)

      # Default to Latin text
      true ->
        Map.get(script_samples, "Latin")
    end
  end

  defp check_one(transform_id, input) do
    local_result =
      try do
        Unicode.Transform.transform(input, transform: transform_id)
      rescue
        e -> {:error, Exception.message(e)}
      end

    case fetch_remote(transform_id, input) do
      {:ok, remote_output} ->
        case local_result do
          {:ok, local_output} ->
            # Normalize for comparison: trim whitespace and strip bidi markers
            local_normalized = normalize_for_comparison(local_output)
            remote_normalized = normalize_for_comparison(remote_output)

            if local_normalized == remote_normalized do
              {:match, local_output, remote_output}
            else
              {:mismatch, local_output, remote_output}
            end

          {:error, reason} ->
            {:error, {:local_error, reason, remote_output}}
        end

      {:error, reason} ->
        {:error, {:remote_error, reason}}
    end
  end

  defp fetch_remote(transform_id, input) do
    # Convert CLDR names to BCP47 codes for the ICU demo site
    demo_id = Unicode.Transform.to_bcp47_transform_id(transform_id)

    try do
      resp = Req.get!(@demo_url,
        params: [a: demo_id, b: input],
        receive_timeout: 15_000,
        retry: false
      )

      if resp.status == 200 do
        extract_result(resp.body)
      else
        {:error, {:http_status, resp.status}}
      end
    rescue
      e -> {:error, {:http_error, Exception.message(e)}}
    end
  end

  defp extract_result(html) do
    # The result appears after "<h2>Result</h2>" or similar heading
    # and before the next section or footer
    cond do
      String.contains?(html, "Result") ->
        # Split on the Result heading and take what follows
        parts = Regex.split(~r/<h[23][^>]*>\s*Result\s*<\/h[23]>/i, html, parts: 2)

        case parts do
          [_, after_result] ->
            # Extract text content up to the next section/form/footer
            result_text =
              after_result
              |> String.split(~r/<h[23]|<form|<footer|<hr|<div\s+class="(copyright|footer)"/i, parts: 2)
              |> hd()
              |> strip_html_tags()
              |> String.trim()

            {:ok, result_text}

          _ ->
            # Try alternative: look for a textarea or pre with the result
            extract_result_alt(html)
        end

      true ->
        extract_result_alt(html)
    end
  end

  defp extract_result_alt(html) do
    # Try to find result in a textarea or code block
    case Regex.run(~r/<textarea[^>]*name="b"[^>]*>(.*?)<\/textarea>/s, html) do
      [_, content] -> {:ok, HtmlEntities.decode(content)}
      nil ->
        case Regex.run(~r/<pre[^>]*>(.*?)<\/pre>/s, html) do
          [_, content] -> {:ok, strip_html_tags(content) |> String.trim()}
          nil -> {:error, :no_result_found}
        end
    end
  end

  defp strip_html_tags(html) do
    html
    |> String.replace(~r/<[^>]+>/, "")
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.replace("&nbsp;", " ")
  end

  defp print_summary(results) do
    matches = Enum.count(results, fn {_, _, r} -> match?({:match, _, _}, r) end)
    mismatches = Enum.count(results, fn {_, _, r} -> match?({:mismatch, _, _}, r) end)
    errors = Enum.count(results, fn {_, _, r} -> match?({:error, _}, r) end)
    total = length(results)

    IO.puts("\n========== SUMMARY ==========")
    IO.puts("Total:      #{total}")
    IO.puts("Matches:    #{matches}")
    IO.puts("Mismatches: #{mismatches}")
    IO.puts("Errors:     #{errors}")
    IO.puts("Match rate: #{Float.round(matches / max(total - errors, 1) * 100, 1)}%")
    IO.puts("=============================\n")
  end

  defp write_csv(results) do
    path = "bench/spot_check_results.csv"

    rows =
      [["transform", "input", "local_output", "remote_output", "status"] |
       Enum.map(results, fn {transform_id, input, result} ->
         {local, remote, status} =
           case result do
             {:match, l, r} -> {l, r, "match"}
             {:mismatch, l, r} -> {l, r, "mismatch"}
             {:error, {:local_error, reason, r}} -> {inspect(reason), r, "local_error"}
             {:error, {:remote_error, reason}} -> {"", inspect(reason), "remote_error"}
             {:error, reason} -> {"", inspect(reason), "error"}
           end

         [transform_id, csv_escape(input), csv_escape(to_string(local)), csv_escape(to_string(remote)), status]
       end)]

    csv_content = Enum.map_join(rows, "\n", fn row -> Enum.join(row, ",") end)
    File.write!(path, csv_content <> "\n")
    IO.puts("Results written to #{path}")
  end

  defp csv_escape(str) do
    if String.contains?(str, [",", "\"", "\n"]) do
      "\"" <> String.replace(str, "\"", "\"\"") <> "\""
    else
      str
    end
  end

  # Normalize text for comparison by trimming whitespace and stripping
  # directional bidi markers that ICU adds but our library does not.
  # LRM (U+200E) typically appears at the start; RLM (U+200F) at the end.
  defp normalize_for_comparison(text) do
    # U+200E = LRM (Left-to-Right Mark), U+200F = RLM (Right-to-Left Mark)
    lrm = <<0x200E::utf8>>
    rlm = <<0x200F::utf8>>

    text
    |> String.trim()
    |> String.trim_leading(lrm)
    |> String.trim_leading(rlm)
    |> String.trim_trailing(lrm)
    |> String.trim_trailing(rlm)
  end

  # Transform IDs the ICU demo rejects even after BCP47 conversion.
  @icu_demo_rejected MapSet.new(~w(
    Japn-Latn mn-mn_Latn-MNS ru_Latn-ru-BGN gz-Ethi-t-und-sarb
  ))

  # Returns true if the ICU demo site is known to support this transform ID.
  # The demo doesn't support hyphenated BGN-style names, BCP-47 style IDs
  # with "-t-", or certain CLDR-extended script names.
  # Note: CLDR names are converted to BCP47 codes before sending to the demo,
  # so "Hant-Latin" becomes "Hant-Latn" (supported), "Sinhala-Latin" becomes
  # "Sinh-Latn" (supported), etc.
  def icu_demo_supported?(transform_id) do
    # Convert to BCP47 to check the demo-facing ID
    demo_id = Unicode.Transform.to_bcp47_transform_id(transform_id)

    cond do
      MapSet.member?(@icu_demo_rejected, demo_id) -> false

      # BCP-47 style IDs with "-t-" are not supported
      String.contains?(transform_id, "-t-") -> false

      # Hyphenated BGN/variant names with 3+ hyphen-separated segments
      # e.g., "Armenian-Latin-BGN", "Georgian-Latin-BGN_1981"
      length(String.split(transform_id, "-")) > 2 -> false

      true -> true
    end
  end
end

transforms =
  Unicode.Transform.available_transforms()
  |> Enum.filter(&SpotCheck.icu_demo_supported?/1)

IO.puts("#{length(transforms)} transforms after filtering unsupported ICU demo IDs\n")
SpotCheck.run(transforms, script_samples, locale_samples)
