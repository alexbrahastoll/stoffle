require 'spec_helper'

RSpec.describe Stoffle::Interpreter do
  describe '#interpret' do
    context 'arithmetic expressions' do
      it 'does correctly evaluate a simple arithmetic expression' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('arithmetic_expr_ok_1.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('4.0')
      end

      it 'does correctly evaluate a complex arithmetic expression' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('arithmetic_expr_ok_2.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('5.0')
      end
    end

    context 'variable bindings' do
      it 'does correctly assign and reassign values to a variable' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('var_binding_ok_2.sfe'))

        expect(interpreter.output.length).to eq(2)
        expect(interpreter.output[0]).to eq('-2.0')
        expect(interpreter.output[1]).to eq('hey')
        expect(interpreter.env['my_var']).to eq('hey')
      end
    end

    context 'function definitions' do
      it 'does correctly define a function' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('fn_def_ok_1.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('0.0')
      end
    end

    context 'function calls' do
      it 'does correctly call a defined function' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('fn_call_ok_1.sfe'))

        expect(interpreter.env['result']).to eq('my_fn was called.')
      end

      it 'does raise an error if the function was not defined' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('fn_call_err_1.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::UndefinedFunction)
      end

      it 'does raise an error if the function was called before its definition' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('fn_call_err_2.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::UndefinedFunction)
      end

      it 'does raise an error when the wrong number of arguments is given' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('fn_call_err_3.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::WrongNumArg)
      end
    end

    context 'recursive function calls' do
      it 'does correctly handle recursive function calls' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('recursion_ok_1.sfe'))

        expect(interpreter.env['f12']).to eq(144.0)
      end
    end

    context 'scope of variables' do
      it 'does assign to an existing global variable when inside a function' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('scope_ok_1.sfe'))

        expect(interpreter.env['my_global_var']).to eq('Value given inside my_func()')
      end

      it 'does declare and assign to a local variable when there is no global with the same name' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('scope_ok_2.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::UndefinedVariable)
        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output[0]).to eq('A local variable')
      end

      it 'does create a local var for each function param when there is no global using the same names' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('scope_ok_3.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::UndefinedVariable)
        expect(interpreter.env['param_3']).to eq('A global var')
        expect(interpreter.output.length).to eq(2)
        expect(interpreter.output[0]).to eq('param_1')
        expect(interpreter.output[1]).to eq('param_2')
      end

      it 'does assign to a global var when a param uses the same name of an existing global var' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('scope_ok_4.sfe'))

        expect(interpreter.output.length).to eq(3)
        expect(interpreter.output[0]).to eq('A global var')
        expect(interpreter.output[1]).to eq('fn call arg 1')
        expect(interpreter.output[2]).to eq('fn call arg 2')
        expect(interpreter.env['param_1']).to eq('fn call arg 1')
        expect(interpreter.env.has_key?('param_2')).to eq(false)
      end
    end

    context 'return' do
      it 'does correctly abort a function evaluation when a return is detected' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('return_ok_1.sfe'))

        expect(interpreter.env['result']).to eq(true)
      end

      it 'does correctly handle multiple functions returning one after another' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('return_ok_2.sfe'))

        expect(interpreter.env['result']).to eq(true)
      end

      it 'does raise an error when a return is used outside a function' do
        interpreter = Stoffle::Interpreter.new

        expect do
          interpreter.interpret(ast_from_source('return_err_1.sfe'))
        end.to raise_error(Stoffle::Error::Runtime::UnexpectedReturn)
      end
    end

    context 'conditionals with empty blocks' do
      it 'does evaluate the conditional to nil' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_13.sfe'))

        expect(interpreter.env.fetch('cond_result')).to be_nil
      end
    end

    context 'conditionals having only an IF block' do
      it 'does not evaluate the IF block when the condition is false' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_1.sfe'))

        expect(interpreter.output.length).to eq(0)
      end

      it 'does not evaluate the IF block when the condition is falsey' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_2.sfe'))

        expect(interpreter.output.length).to eq(0)
      end

      it 'does evaluate the IF block when the condition is true' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_3.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end

      it 'does evaluate the IF block when the condition is truthy' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_4.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end
    end

    context 'conditionals having IF / ELSE blocks' do
      it 'does evaluate the IF block when the condition is truthy' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_5.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end

      it 'does evaluate the ELSE block when the condition is falsey - example 1' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_6.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('ELSE block evaluated.')
      end

      it 'does evaluate the ELSE block when the condition is falsey - example 2' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_16.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('The number is less than or equal to zero.')
      end
    end

    context 'conditionals using logical operators' do
      it 'does evaluate the IF block when an expression using AND is truthy' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_7.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end

      it 'does evaluate the ELSE block when an expression using AND is falsey' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_8.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('ELSE block evaluated.')
      end

      it 'does short-circuit when the left operand of AND is falsey' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_14.sfe'))

        expect(interpreter.output.length).to eq(0)
      end

      it 'does evaluate the IF block when an expression using OR is truthy' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_9.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end

      it 'does evaluate the ELSE block when an expression using OR is falsey' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_10.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('ELSE block evaluated.')
      end

      it 'does short-circuit when the left operand of OR is truthy' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_15.sfe'))

        expect(interpreter.output.length).to eq(0)
        expect(interpreter.env['short_circuited']).to eq(true)
      end

      it 'does correctly interpret conditionals using both AND and OR' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_12.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('IF block evaluated.')
      end
    end

    context 'nested conditionals' do
      it 'does correctly interpret nested conditionals' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('conditional_ok_11.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('ELSE IF block evaluated.')
      end
    end

    context 'repetitions (aka loops)' do
      it 'does correctly evaluate a repetition' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('repetition_ok_1.sfe'))

        expect(interpreter.env.fetch('i')).to eq(9.0)
      end

      it 'does correctly evaluate a repetition with a complex condition' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('repetition_ok_2.sfe'))

        expect(interpreter.env.fetch('i')).to eq(5.0)
        expect(interpreter.env.fetch('continue_loop')).to eq(false)
      end
    end

    context 'complex programs' do
      it 'does correctly interpret an integer summation program' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('complex_program_ok_1.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('5050.0')
      end
    end
  end

  def ast_from_source(filename)
    source = File.read(Pathname.new(__dir__).join('..', '..', 'fixtures', 'interpreter', filename))
    lexer = Stoffle::Lexer.new(source)
    parser = Stoffle::Parser.new(lexer.start_tokenization)
    parser.parse

    parser.ast
  end
end
