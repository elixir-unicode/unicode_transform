defmodule Unicode.Transform.LatinAsciiTest do
  @moduledoc """
  Tests adapted from the master branch's TransformTest module,
  which tested the old `Unicode.Transform.LatinAscii.transform/1` API.
  These now use the new `Unicode.Transform.transform/2` API.
  """
  use ExUnit.Case, async: true

  describe "Latin-ASCII: French text" do
    test "transforms French accented text" do
      text = "Maître Corbeau, sur un arbre perché"
      expected = "Maitre Corbeau, sur un arbre perche"

      assert {:ok, ^expected} = Unicode.Transform.transform(text, from: :latin, to: :ascii)
    end
  end

  describe "Latin-ASCII: German text" do
    test "transforms German text with umlauts and eszett" do
      text =
        "Fach- und Berufsschulunterricht müssen allgemein verfügbar gemacht werden, und der Hochschulunterricht muß allen gleichermaßen entsprechend ihren Fähigkeiten offenstehen."

      expected =
        "Fach- und Berufsschulunterricht mussen allgemein verfugbar gemacht werden, und der Hochschulunterricht muss allen gleichermassen entsprechend ihren Fahigkeiten offenstehen."

      assert {:ok, ^expected} = Unicode.Transform.transform(text, from: :latin, to: :ascii)
    end
  end

  describe "Latin-ASCII: non-Latin text" do
    test "non-Latin text passes through unchanged" do
      text = "英りゃ師目需げ無若力にぱ覚再くふにあ輝筆ヘ気存ノ談対ぞぶ平第ムホ刻嗅がけ谷護供わがッも持受"

      {:ok, result} = Unicode.Transform.transform(text, from: :latin, to: :ascii)
      assert result == text
    end
  end

  describe "Latin-ASCII: non-breaking space" do
    test "non-breaking space becomes ASCII space" do
      assert {:ok, "There and Back Again"} =
               Unicode.Transform.transform("There\u00a0and Back\u00a0Again", from: :latin, to: :ascii)
    end
  end
end
