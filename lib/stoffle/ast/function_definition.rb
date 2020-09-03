class Stoffle::AST::FunctionDefinition < Stoffle::AST::Expression
  attr_accessor :name, :params, :body

  def initialize(fn_name = nil, fn_params = nil, fn_body = nil)
    @name = fn_name
    @params = fn_params
    @body = fn_body
  end

  # TODO FunctionCall has an exact copy of this method. Think on how to better extract it.
  def function_name_as_str
    # The instance variable @name is an AST::Identifier.
    name.name
  end

  def ==(other)
    children == other&.children
  end

  def children
    [name, params, body]
  end
end
