defmodule Unicode.Transform.Utils do
  import SweetXml

  def file(transform_file) do
    transform_file
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//transform",
      source: ~x"./@source"s,
      target: ~x"./@target"s,
      direction: ~x"./@direction"s,
      alias: ~x"./@alias"s,
      rules: ~x"./tRule/text()"s
    )
  end
end
