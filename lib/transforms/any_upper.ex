defmodule Unicode.Transform.AnyUpper do
  @behaviour Unicode.Transform

  def transform(string, _filter \\ nil) do
    String.upcase(string)
  end
end
