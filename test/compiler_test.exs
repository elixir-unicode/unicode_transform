defmodule Unicode.Transform.CompilerTest do
  use ExUnit.Case, async: true

  alias Unicode.Transform.{Compiler, Parser}
  alias Unicode.Transform.Compiler.CompiledTransform

  describe "compile/2" do
    test "compiles parsed rules with default resolver and context" do
      rules = Parser.parse("a → b ;")
      assert %CompiledTransform{passes: passes} = Compiler.compile(rules, :forward)
      assert is_list(passes)
    end

    test "compiles rules in the reverse direction" do
      rules = Parser.parse("a ↔ b ;")
      assert %CompiledTransform{} = Compiler.compile(rules, :reverse)
    end
  end

  describe "compile_builtin/2" do
    test "keeps the name for the forward direction" do
      assert %CompiledTransform{passes: [{:builtin, "Lower"}]} =
               Compiler.compile_builtin("Lower", :forward)
    end

    test "uses the inverse name for the reverse direction" do
      assert %CompiledTransform{passes: [{:builtin, "Upper"}]} =
               Compiler.compile_builtin("Lower", :reverse)
    end
  end
end
