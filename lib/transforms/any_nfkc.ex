defmodule Unicode.Transform.AnyNfkc do
  @behaviour Unicode.Transform

  def transform(string, _filter \\ nil) do
    String.normalize(string, :nfkc)
  end
end
