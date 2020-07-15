class Stoffle::AST::Conditional < Stoffle::AST::Expression
  attr_accessor :condition, :when_true, :when_false

  def initialize(cond_expr = nil, true_block = nil, false_block = nil)
    @condition = cond_expr
    @when_true = true_block
    @when_false = false_block
  end

  def ==(other)
    children == other&.children
  end

  def children
    [condition, when_true, when_false]
  end
end
