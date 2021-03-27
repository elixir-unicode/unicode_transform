defmodule Unicode.Transform.AnyNFKD do
  def transform(string) do
    String.normalize(string, :nfkd)
  end

end