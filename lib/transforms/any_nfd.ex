defmodule Unicode.Transform.AnyNfd do
  def transform(string, _filter \\ nil) do
    String.normalize(string, :nfd)
  end
end
