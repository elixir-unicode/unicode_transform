defmodule Unicode.Transform.AnyNFD do
  def transform(string) do
    String.normalize(string, :nfd)
  end

end