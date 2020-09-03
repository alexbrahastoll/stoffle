require 'spec_helper'

RSpec.describe Stoffle::Interpreter do
  describe '#interpret' do
    context 'arithmetic expressions' do
      it 'does correctly evaluate a simple arithmetic expression' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('fn_call_ok_4.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('4.0')
      end

      it 'does correctly evaluate a complex arithmetic expression' do
        interpreter = Stoffle::Interpreter.new

        interpreter.interpret(ast_from_source('fn_call_ok_5.sfe'))

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

        interpreter.interpret(ast_from_source('fn_def_ok_4.sfe'))

        expect(interpreter.output.length).to eq(1)
        expect(interpreter.output.first).to eq('0.0')
      end
    end
  end

  def ast_from_source(filename)
    source = File.read(Pathname.new(__dir__).join('..', '..', 'fixtures', filename))
    lexer = Stoffle::Lexer.new(source)
    parser = Stoffle::Parser.new(lexer.start_tokenization)
    parser.parse

    parser.ast
  end
end
