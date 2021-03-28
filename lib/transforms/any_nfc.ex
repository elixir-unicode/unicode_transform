defmodule Unicode.Transform.AnyNfc do
  def transform(string, _filter \\ []) do
    String.normalize(string, :nfc)
  end
end
