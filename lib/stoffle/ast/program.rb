class Stoffle::AST::Program
  attr_accessor :expressions

  def initialize
    @expressions = []
  end

  def <<(expr)
    expressions << expr
  end

  def ==(other)
    expressions == other&.expressions
  end

  def children
    expressions
  end
end
