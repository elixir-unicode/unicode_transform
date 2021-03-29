defmodule Unicode.Transform.AnyNfkd do
  @behaviour Unicode.Transform

  def transform(string, _filter \\ nil) do
    String.normalize(string, :nfkd)
  end
end
