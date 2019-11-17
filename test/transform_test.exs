defmodule TransformTest do
  use ExUnit.Case
  alias Unicode.Transform
  doctest Unicode.Transform

  test "parsing filters" do
    assert {:ok, _, "", %{}, _, _} = Transform.parse(":: [ሀ-᎙] ;")

    assert {:ok, _, "", %{}, _, _} =
             Transform.parse(
               ":: [[:arabic:][:block=ARABIC:][ءآابةتثجحخدذرزسشصضطظعغفقكلمنهوىيًٌٍَُِّْ٠١٢٣٤٥٦٧٨٩ٱ]] ;"
             )

    assert {:ok, _, "", %{}, _, _} =
             Transform.parse(
               "::[ԱԲԳԴԵԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔՕՖաբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆև։];"
             )

    assert {:ok, _, "", %{}, _, _} =
             Transform.parse(
               ":: [АБВГҒДЕӘЖЗИЫЈКҜЛМНОӨПРСТУҮФХҺЧҸШЙЭЮЯабвгғдеәжзиыјкҝлмноөпрстуүфхһчҹш’йэюя] ;"
             )

    assert {:ok, _, "", %{}, _, _} =
             Transform.parse(
               "::[АБВГДЕЁЖЗІЙКЛМНОПРСТУЎФХЦЧШЩЪЫЬЭЮЯҐабвгдеёжзійклмнопрстуўфхцчшщъыьэюя’ґ] ;"
             )

    assert {:ok, _, "", %{}, _, _} = Transform.parse("::[।-॥ঁ-ঃঅ-ঌএ-ঐও-নপ-রলশ-হ়-ৄে-ৈো-্ৗড়-ঢ়য়-ৣ০-৺ৎ];")
    assert {:ok, _, "", %{}, _, _} = Transform.parse("::[ँ-ःऄअ-ह़-्ॐ-॔क़-९ॽ];")

    assert {:ok, _, "", %{"wordBoundary" => [category: {:not, :L}, category: :M, category: :N]},
            _, _} = Transform.parse("$wordBoundary =  [[^:L:][:M:][:N:]] ;")
  end
end
