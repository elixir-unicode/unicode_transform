defmodule Unicode.Transform.AnyNfc do
  @behaviour Unicode.Transform

  @impl Unicode.Transform
  def transform(string, caller \\ nil)

  def transform(string, nil) do
    String.normalize(string, :nfc)
  end

  def transform("", _caller) do
    ""
  end

  def transform(<<char::utf8, rest::binary>>, caller) do
    if caller.filter?(char) do
      String.normalize(<<char::utf8>>, :nfc) <> transform(rest, caller)
    else
      <<char::utf8>> <> transform(rest, caller)
    end
  end
end
