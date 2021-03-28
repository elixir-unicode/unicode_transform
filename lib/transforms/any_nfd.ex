defmodule Unicode.Transform.AnyNfd do
  def transform(string) do
    String.normalize(string, :nfd)
  end
end
