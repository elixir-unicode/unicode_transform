defmodule Unicode.Transform.AnyNFKC do
  def transform(string) do
    String.normalize(string, :nfkc)
  end

end