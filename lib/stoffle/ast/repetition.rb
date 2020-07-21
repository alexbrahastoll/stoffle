class Stoffle::AST::Repetition < Stoffle::AST::Expression
  attr_accessor :condition, :block

  def initialize(cond_expr = nil, repetition_block = nil)
    @condition = cond_expr
    @block = repetition_block
  end

  def ==(other)
    children == other&.children
  end

  def children
    [condition, block]
  end
end
