class Stoffle::AST::VarBinding < Stoffle::AST::Expression
  attr_accessor :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def ==(other)
    children == other&.children
  end

  def children
    [left, right]
  end
end
