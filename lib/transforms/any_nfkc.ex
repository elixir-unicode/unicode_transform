defmodule Unicode.Transform.AnyNfkc do
  def transform(string) do
    String.normalize(string, :nfkc)
  end
end
