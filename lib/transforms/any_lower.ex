defmodule Unicode.Transform.AnyLower do
  @behaviour Unicode.Transform

  def transform(string, _filter \\ nil) do
    String.downcase(string)
  end
end
