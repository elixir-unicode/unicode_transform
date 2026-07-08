defmodule Unicode.Transform.ResolveTest do
  use ExUnit.Case, async: true

  alias Unicode.Transform.Resolve

  doctest Unicode.Transform.Resolve

  describe "resolve_options/1" do
    test "resolves a direct transform id" do
      assert {:ok, "de-ASCII", :forward} = Resolve.resolve_options(transform: "de-ASCII")

      assert {:ok, "de-ASCII", :reverse} =
               Resolve.resolve_options(transform: "de-ASCII", direction: :reverse)
    end

    test "errors when neither :to nor :transform is given" do
      assert {:error, {:missing_option, :to}} = Resolve.resolve_options(from: :latin)
    end

    test "requests detection when from: :detect" do
      assert {:detect, :latin} = Resolve.resolve_options(from: :detect, to: :latin)
    end

    test "errors on an unsupported :from value" do
      assert {:error, {:invalid_option, {:from, 123}}} =
               Resolve.resolve_options(from: 123, to: :latin)
    end

    test "errors on an unsupported :to value" do
      assert {:error, {:invalid_option, {:to, 456}}} =
               Resolve.resolve_options(from: :latin, to: 456)
    end

    test "resolves a builtin target reached from :any" do
      assert {:ok, "Any-Upper", :forward} = Resolve.resolve_options(from: :any, to: :"Any-Upper")
    end
  end

  describe "script/name conversion" do
    test "converts between BCP47 codes and Unicode script names" do
      assert Resolve.bcp47_script_to_unicode("Grek") == "Greek"
      assert Resolve.unicode_script_to_bcp47("Greek") == "Grek"
    end

    test "resolves target names from atoms and strings" do
      assert Resolve.resolve_to_name(:greek) == "Greek"
      assert Resolve.resolve_to_name("ASCII") == "ASCII"
    end
  end
end
