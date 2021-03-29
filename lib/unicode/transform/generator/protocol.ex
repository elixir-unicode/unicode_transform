defprotocol Unicode.Transform.Rule do
  @spec to_forward_code(t) :: [any()]
  def to_forward_code(t)

  @spec to_backward_code(t) :: [any()]
  def to_backward_code(t)
end
