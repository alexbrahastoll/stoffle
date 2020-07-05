class Stoffle::AST::UnaryOperator < Stoffle::AST::Expression
  attr_accessor :operator, :operand

  def initialize(operator, operand = nil)
    @operator = operator
    @operand = operand
  end

  def ==(other)
    operator == other&.operator && children == other&.children
  end

  def children
    [operand]
  end
end
