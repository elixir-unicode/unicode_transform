defmodule Unicode.Transform.AnyNull do
  @behaviour Unicode.Transform

  def transform(string, _filter \\ nil) do
    string
  end
end
