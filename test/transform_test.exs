defmodule TransformTest do
  use ExUnit.Case
  doctest Unicode.Transform

  test "parsing filters" do
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule(":: [ሀ-᎙] ;")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule(":: [[:arabic:][:block=ARABIC:][ءآابةتثجحخدذرزسشصضطظعغفقكلمنهوىيًٌٍَُِّْ٠١٢٣٤٥٦٧٨٩ٱ]] ;")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule("::[ԱԲԳԴԵԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔՕՖաբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆև։];")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule(":: [АБВГҒДЕӘЖЗИЫЈКҜЛМНОӨПРСТУҮФХҺЧҸШЙЭЮЯабвгғдеәжзиыјкҝлмноөпрстуүфхһчҹш’йэюя] ;")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule("::[АБВГДЕЁЖЗІЙКЛМНОПРСТУЎФХЦЧШЩЪЫЬЭЮЯҐабвгдеёжзійклмнопрстуўфхцчшщъыьэюя’ґ] ;")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule("::[।-॥ঁ-ঃঅ-ঌএ-ঐও-নপ-রলশ-হ়-ৄে-ৈো-্ৗড়-ঢ়য়-ৣ০-৺ৎ];")
    assert {:ok, _, "", %{}, _, _} = Unicode.Transform.rule("::[ँ-ःऄअ-ह़-्ॐ-॔क़-९ॽ];")
  end
end
