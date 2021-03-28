defmodule Unicode.Transform.AnyNfc do
  def transform(string) do
    String.normalize(string, :nfc)
  end
end
