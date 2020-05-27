class Stoffle::AST::Identifier < Stoffle::AST::Expression
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def ==(other)
    name == other&.name
  end

  def children
    []
  end
end
