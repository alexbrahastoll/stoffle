require 'spec_helper'

RSpec.describe Stoffle::Parser do
  sfe_prog = Stoffle::AST::Program
  sfe_expr = Stoffle::AST::Expression
  sfe_var_binding = Stoffle::AST::VarBinding
  sfe_ident = Stoffle::AST::Identifier

  describe '#parse' do
    context 'variable binding' do
      it 'does generate the expected AST when the syntax is followed' do
        ident = sfe_ident.new('my_var')
        var_binding = sfe_var_binding.new(ident, sfe_expr.new)
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(var_binding)
        parser = Stoffle::Parser.new(tokens_from_source('var_binding_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does result in syntax errors when the syntax is not respected' do
      end
    end
  end

  def tokens_from_source(filename)
    source = File.read(Pathname.new(__dir__).join('..', '..', 'fixtures', filename))

    Stoffle::Lexer.new(source).start_tokenization
  end
end
