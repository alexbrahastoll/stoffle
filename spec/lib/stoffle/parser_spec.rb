require 'spec_helper'

RSpec.describe Stoffle::Parser do
  sfe_prog = Stoffle::AST::Program
  sfe_expr = Stoffle::AST::Expression
  sfe_var_binding = Stoffle::AST::VarBinding
  sfe_ident = Stoffle::AST::Identifier
  sfe_num = Stoffle::AST::Number
  sfe_return = Stoffle::AST::Return
  sfe_unary_op = Stoffle::AST::UnaryOperator

  describe '#parse' do
    context 'variable binding' do
      it 'does generate the expected AST when the syntax is followed' do
        ident = sfe_ident.new('my_var')
        num = sfe_num.new(1.0)
        var_binding = sfe_var_binding.new(ident, num)
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(var_binding)
        parser = Stoffle::Parser.new(tokens_from_source('var_binding_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does result in a syntax error when the syntax is not respected' do
        parser = Stoffle::Parser.new(tokens_from_source('var_binding_err.sfe'))

        parser.parse

        expect(parser.errors.length).to eq(1)
        expect(parser.errors.last.next_token.lexeme).to eq('1')
      end
    end

    context 'standalone identifier' do
      it 'does generate the expected AST' do
        ident = sfe_ident.new('my_var')
        var_binding = sfe_var_binding.new(ident, sfe_num.new(1.0))
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(var_binding, ident)
        parser = Stoffle::Parser.new(tokens_from_source('standalone_identifier_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'standalone number' do
      it 'does generate the expected AST' do
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(sfe_num.new(1991.0), sfe_num.new(7.0), sfe_num.new(28.28))
        parser = Stoffle::Parser.new(tokens_from_source('standalone_number_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'unary operators' do
      it 'does generate the expected AST' do
        expected_prog = sfe_prog.new
        minus_op_1 = sfe_unary_op.new(:'-', sfe_num.new(28.0))
        minus_op_2 = sfe_unary_op.new(:'-', sfe_num.new(24.42))
        bang_op = sfe_unary_op.new(:'!', sfe_num.new(7.0))
        expected_prog.expressions.append(minus_op_1, minus_op_2, bang_op)
        parser = Stoffle::Parser.new(tokens_from_source('unary_operator_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'return' do
      it 'does generate the expected AST' do
        ret = sfe_return.new(sfe_num.new(1.0))
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(ret)
        parser = Stoffle::Parser.new(tokens_from_source('return_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end
  end

  def tokens_from_source(filename)
    source = File.read(Pathname.new(__dir__).join('..', '..', 'fixtures', filename))

    Stoffle::Lexer.new(source).start_tokenization
  end
end
