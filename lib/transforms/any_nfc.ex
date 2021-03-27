defmodule Unicode.Transform.AnyNFC do
  def transform(string) do
    String.normalize(string, :nfc)
  end

end