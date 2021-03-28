defmodule Unicode.Transform.AnyNfkd do
  def transform(string) do
    String.normalize(string, :nfkd)
  end
end
