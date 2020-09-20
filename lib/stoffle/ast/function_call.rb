class Stoffle::AST::FunctionCall < Stoffle::AST::Expression
  attr_accessor :name, :args

  def initialize(fn_name = nil, fn_args = [])
    @name = fn_name
    @args = fn_args
  end

  def function_name_as_str
    # The instance variable @name is an AST::Identifier.
    name.name
  end

  def ==(other)
    children == other&.children
  end

  def children
    [name, args]
  end
end
