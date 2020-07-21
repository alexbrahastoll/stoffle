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
  sfe_conditional = Stoffle::AST::Conditional
  sfe_block = Stoffle::AST::Block
  sfe_fn_def = Stoffle::AST::FunctionDefinition
  sfe_fn_call = Stoffle::AST::FunctionCall

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

    context 'grouped expressions' do
      it 'does generate the expected AST for (3 + 4) * 2' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(3.0), sfe_num.new(4.0))
        multiplication_op = sfe_binary_op.new(:'*', plus_op, sfe_num.new(2.0))
        expected_prog.expressions.append(multiplication_op)
        parser = Stoffle::Parser.new(tokens_from_source('grouped_expr_ok_1.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for ((4 + 4) / 4) * 2' do
        expected_prog = sfe_prog.new
        plus_op = sfe_binary_op.new(:'+', sfe_num.new(4.0), sfe_num.new(4.0))
        division_op = sfe_binary_op.new(:'/', plus_op, sfe_num.new(4.0))
        multiplication_op = sfe_binary_op.new(:'*', division_op, sfe_num.new(2.0))
        expected_prog.expressions.append(multiplication_op)
        parser = Stoffle::Parser.new(tokens_from_source('grouped_expr_ok_2.sfe'))

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

    context 'conditionals' do
      it 'does generate the expected AST for a IF THEN conditional' do
        expected_prog = sfe_prog.new
        ident = sfe_ident.new('world_still_makes_sense')
        var_binding_outer = sfe_var_binding.new(ident, sfe_bool.new(false))
        eq_op = sfe_binary_op.new(:'==', sfe_num.new(1.0), sfe_num.new(1.0))
        var_binding_inner = sfe_var_binding.new(ident, sfe_bool.new(true))
        true_block = sfe_block.new
        true_block.expressions.append(var_binding_inner)
        conditional = sfe_conditional.new(eq_op, true_block)
        expected_prog.expressions.append(var_binding_outer, conditional)
        parser = Stoffle::Parser.new(tokens_from_source('conditional_ok_1.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a IF THEN ELSE conditional' do
        expected_prog = sfe_prog.new

        ident_1 = sfe_ident.new('world_still_makes_sense')
        ident_2 = sfe_ident.new('world_gone_mad')
        var_binding_1 = sfe_var_binding.new(ident_1, sfe_bool.new(false))
        var_binding_2 = sfe_var_binding.new(ident_2, sfe_bool.new(false))

        eq_op = sfe_binary_op.new(:'==', sfe_num.new(1.0), sfe_num.new(1.0))
        var_binding_3 = sfe_var_binding.new(ident_1, sfe_bool.new(true))
        true_block = sfe_block.new
        true_block.expressions.append(var_binding_3)

        ineq_op = sfe_binary_op.new(:'!=', sfe_num.new(1.0), sfe_num.new(1.0))
        var_binding_4 = sfe_var_binding.new(ident_2, sfe_bool.new(true))
        false_block = sfe_block.new
        false_block.expressions.append(ineq_op, var_binding_4)

        conditional = sfe_conditional.new(eq_op, true_block, false_block)

        expected_prog.expressions.append(var_binding_1, var_binding_2, conditional)
        parser = Stoffle::Parser.new(tokens_from_source('conditional_ok_2.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a IF THEN ELSE IF conditional' do
        expected_prog = sfe_prog.new

        ident_1 = sfe_ident.new('world_still_makes_sense')
        ident_2 = sfe_ident.new('world_gone_mad')
        var_binding_1 = sfe_var_binding.new(ident_1, sfe_bool.new(false))
        var_binding_2 = sfe_var_binding.new(ident_2, sfe_bool.new(false))

        eq_op = sfe_binary_op.new(:'==', sfe_num.new(1.0), sfe_num.new(1.0))
        var_binding_3 = sfe_var_binding.new(ident_1, sfe_bool.new(true))
        true_block = sfe_block.new
        true_block.expressions.append(var_binding_3)

        var_binding_4 = sfe_var_binding.new(ident_2, sfe_bool.new(true))
        true_block_inner = sfe_block.new
        true_block_inner.expressions.append(var_binding_4)
        conditional_inner = sfe_conditional.new(sfe_bool.new(true), true_block_inner)
        false_block = sfe_block.new
        false_block.expressions.append(conditional_inner)

        conditional_outer = sfe_conditional.new(eq_op, true_block, false_block)

        expected_prog.expressions.append(var_binding_1, var_binding_2, conditional_outer)
        parser = Stoffle::Parser.new(tokens_from_source('conditional_ok_3.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'function definition' do
      it 'does generate the expected AST for a function without parameters' do
        expected_prog = sfe_prog.new

        block_1 = sfe_block.new
        block_1 << sfe_num.new(1.0)
        ident_1 = sfe_ident.new('one')
        fn_def_1 = sfe_fn_def.new(ident_1, nil, block_1)

        block_2 = sfe_block.new
        block_2 << sfe_num.new(2.0)
        ident_2 = sfe_ident.new('two')
        fn_def_2 = sfe_fn_def.new(ident_2, nil, block_2)

        expected_prog.expressions.append(fn_def_1, fn_def_2)
        parser = Stoffle::Parser.new(tokens_from_source('fn_def_ok_1.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a function with one parameter' do
        expected_prog = sfe_prog.new
        fn_name = sfe_ident.new('double')
        param = sfe_ident.new('num')
        block = sfe_block.new
        block << sfe_binary_op.new(:'*', param, sfe_num.new(2.0))
        fn_def = sfe_fn_def.new(fn_name, [param], block)
        expected_prog.expressions.append(fn_def)
        parser = Stoffle::Parser.new(tokens_from_source('fn_def_ok_2.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a function with multiple parameters' do
        expected_prog = sfe_prog.new
        fn_name = sfe_ident.new('sum_3')
        param_1 = sfe_ident.new('num_1')
        param_2 = sfe_ident.new('num_2')
        param_3 = sfe_ident.new('num_3')
        plus_op_left = sfe_binary_op.new(:'+', param_1, param_2)
        plus_op_right = sfe_binary_op.new(:'+', plus_op_left, param_3)
        block = sfe_block.new
        block << plus_op_right
        fn_def = sfe_fn_def.new(fn_name, [param_1, param_2, param_3], block)
        expected_prog.expressions.append(fn_def)
        parser = Stoffle::Parser.new(tokens_from_source('fn_def_ok_3.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end
    end

    context 'function call' do
      it 'does generate the expected AST for a call with no arguments' do
        expected_prog = sfe_prog.new
        ident = sfe_ident.new('my_func')
        fn_call = sfe_fn_call.new(ident, [])
        expected_prog.expressions.append(fn_call)
        parser = Stoffle::Parser.new(tokens_from_source('fn_call_ok_1.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a call with one argument' do
        expected_prog = sfe_prog.new
        ident = sfe_ident.new('my_func')
        args = [sfe_num.new(1.0)]
        fn_call = sfe_fn_call.new(ident, args)
        expected_prog.expressions.append(fn_call)
        parser = Stoffle::Parser.new(tokens_from_source('fn_call_ok_2.sfe'))

        parser.parse

        expect(parser.ast).to eq(expected_prog)
      end

      it 'does generate the expected AST for a call with multiple arguments' do
        expected_prog = sfe_prog.new
        ident = sfe_ident.new('my_func')
        args = [sfe_num.new(1.0), sfe_ident.new('my_arg'), sfe_binary_op.new(:'+', sfe_num.new(2.0), sfe_num.new(2.0))]
        fn_call = sfe_fn_call.new(ident, args)
        expected_prog.expressions.append(fn_call)
        parser = Stoffle::Parser.new(tokens_from_source('fn_call_ok_3.sfe'))

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
