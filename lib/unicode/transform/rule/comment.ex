defmodule Unicode.Transform.Rule.Comment do
  @moduledoc """
  Parse a comment line
  """

  defstruct [:comment]

  def parse(<< "#" >> <> comment) do
    struct(__MODULE__, comment: String.trim(comment))
  end

  def parse(_other) do
    nil
  end

  @doc false
  def comment_from(%{comment: ""}) do
    ["#", "\n"]
  end

  def comment_from(%{comment: nil}) do
    []
  end

  def comment_from(%{comment: comment}) do
    ["# ", comment, "\n"]
  end

  defimpl Unicode.Transform.Rule do
    def to_forward_code(rule) do
      Unicode.Transform.Rule.Comment.comment_from(rule)
    end

    def to_backward_code(rule) do
      Unicode.Transform.Rule.Comment.comment_from(rule)
    end
  end

end