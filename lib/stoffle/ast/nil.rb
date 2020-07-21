class Stoffle::AST::Nil < Stoffle::AST::Expression
  def initialize
    super
  end

  def ==(other)
    self.class == other.class && value == other&.value
  end

  def children
    []
  end
end
