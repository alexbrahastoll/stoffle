class Stoffle::AST::FunctionCall < Stoffle::AST::Expression
  attr_accessor :name, :args

  def initialize(fn_name = nil, fn_args = nil)
    @name = fn_name
    @args = fn_args
  end

  def ==(other)
    children == other&.children
  end

  def children
    [name, args]
  end
end
