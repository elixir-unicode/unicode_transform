defmodule TransformTest do
  use ExUnit.Case

  describe "Unicode.Transform.LatinAscii.transform/1" do
    test "french" do
      text = "Maître Corbeau, sur un arbre perché"
      after_transform = "Maitre Corbeau, sur un arbre perche"

      assert Unicode.Transform.LatinAscii.transform(text) == after_transform
    end

    test "german" do
      text = "Fach- und Berufsschulunterricht müssen allgemein verfügbar gemacht werden, und der Hochschulunterricht muß allen gleichermaßen entsprechend ihren Fähigkeiten offenstehen."
      after_transform = "Fach- und Berufsschulunterricht mussen allgemein verfugbar gemacht werden, und der Hochschulunterricht muss allen gleichermassen entsprechend ihren Fahigkeiten offenstehen."

      assert Unicode.Transform.LatinAscii.transform(text) == after_transform
    end

    test "japanese" do
      # Not latin text should not be changed
      text = "英りゃ師目需げ無若力にぱ覚再くふにあ輝筆ヘ気存ノ談対ぞぶ平第ムホ刻嗅がけ谷護供わがッも持受"
      after_transform = "英りゃ師目需げ無若力にぱ覚再くふにあ輝筆ヘ気存ノ談対ぞぶ平第ムホ刻嗅がけ谷護供わがッも持受"

      assert Unicode.Transform.LatinAscii.transform(text) == after_transform
    end
  end
end
