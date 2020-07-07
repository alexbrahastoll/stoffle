require 'spec_helper'

RSpec.describe Stoffle::Parser do
  sfe_prog = Stoffle::AST::Program
  sfe_expr = Stoffle::AST::Expression
  sfe_var_binding = Stoffle::AST::VarBinding
  sfe_ident = Stoffle::AST::Identifier
  sfe_num = Stoffle::AST::Number
  sfe_bool = Stoffle::AST::Boolean
  sfe_return = Stoffle::AST::Return
  sfe_unary_op = Stoffle::AST::UnaryOperator
  sfe_binary_op = Stoffle::AST::BinaryOperator

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

    context 'standalone boolean' do
      it 'does generate the expected AST' do
        expected_prog = sfe_prog.new
        expected_prog.expressions.append(sfe_bool.new(true), sfe_bool.new(false))
        parser = Stoffle::Parser.new(tokens_from_source('standalone_boolean_ok.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'boolean expressions' do
      it 'does generate the expected AST for 1 == 1' do
        expected_prog = sfe_prog.new
        comparison_op = sfe_binary_op.new(:'==', sfe_num.new(1.0), sfe_num.new(1.0))

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_7.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 2 != 1' do
        expected_prog = sfe_prog.new
        comparison_op = sfe_binary_op.new(:'!=', sfe_num.new(2.0), sfe_num.new(1.0))

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_6.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 2 + 2 > 3' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))
        comparison_op = sfe_binary_op.new(:'>', plus_op, sfe_num.new(3.0))

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_5.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 2 + 2 >= 3' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))
        comparison_op = sfe_binary_op.new(:'>=', plus_op, sfe_num.new(3.0))

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_4.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 3 < 2 + 2' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))
        comparison_op = sfe_binary_op.new(:'<', sfe_num.new(3.0), plus_op)

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_3.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 3 <= 2 + 2' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))
        comparison_op = sfe_binary_op.new(:'<=', sfe_num.new(3.0), plus_op)

        expected_prog.expressions.append(comparison_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_2.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for true != false' do
        expected_prog = sfe_prog.new
        not_eq_op = sfe_binary_op.new(:'!=', sfe_bool.new(true), sfe_bool.new(false))
        expected_prog.expressions.append(not_eq_op)
        parser = Stoffle::Parser.new(tokens_from_source('boolean_expr_ok_1.sfe'))

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

    context 'binary operators' do
      it 'does generate the expected AST for 2 + 2' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))
        expected_prog.expressions.append(plus_op)
        parser = Stoffle::Parser.new(tokens_from_source('binary_operator_ok_1.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 2 + 2 * 3' do
        expected_prog = sfe_prog.new
        multiplication_op = sfe_binary_op.new(:'*', sfe_num.new(2.0), sfe_num.new(3.0))
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), multiplication_op)
        expected_prog.expressions.append(plus_op)
        parser = Stoffle::Parser.new(tokens_from_source('binary_operator_ok_2.sfe'))

        parser.parse

        # expected: 2 + (2 * 3)
        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for 2 + 2 * 3 / 3' do
        expected_prog = sfe_prog.new
        multiplication_op = sfe_binary_op.new(:'*', sfe_num.new(2.0), sfe_num.new(3.0))
        division_op = sfe_binary_op.new(:'/', multiplication_op, sfe_num.new(3.0))
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(2.0), division_op)
        expected_prog.expressions.append(plus_op)
        parser = Stoffle::Parser.new(tokens_from_source('binary_operator_ok_3.sfe'))

        parser.parse

        # expected: 2 + ((2 * 3) / 3)
        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'mixed operators' do
      it 'does generate the expected AST for -10 + 2 + 2 * 3 / 3' do
        expected_prog = sfe_prog.new
        inversion_op = sfe_unary_op.new(:'-', sfe_num.new(10.0))
        plus_op_1 = sfe_binary_op.new(:'+', inversion_op, sfe_num.new(2.0))
        multiplication_op = sfe_binary_op.new(:'*', sfe_num.new(2.0), sfe_num.new(3.0))
        division_op = sfe_binary_op.new(:'/', multiplication_op, sfe_num.new(3.0))
        plus_op_2 = sfe_binary_op.new(:'+', plus_op_1, division_op)
        expected_prog.expressions.append(plus_op_2)
        parser = Stoffle::Parser.new(tokens_from_source('mixed_operator_ok_1.sfe'))

        parser.parse

        # expected: (-10 + 2) + ((2 * 3) / 3)
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
