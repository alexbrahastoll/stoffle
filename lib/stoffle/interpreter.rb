module Stoffle
  class Interpreter
    attr_reader :program, :output, :env

    def initialize
      @output = []
      @env = {}
    end

    def interpret(ast)
      @program = ast

      program.expressions.each do |expr|
        interpret_node(expr)
      end
    end

    private

    def println(fn_call)
      return false if fn_call.function_name_as_str != 'println'

      result = interpret_node(fn_call.args.first).to_s
      output << result
      puts result
      true
    end

    def fetch_function_definition(fn_name)
      fn_def = env[fn_name]
      raise Stoffle::Error::Runtime::UndefinedFunction.new(fn_name) if fn_def.nil?

      fn_def
    end

    def assign_function_args_to_params(fn_call, fn_def)
      given = fn_call.args.length
      expected = fn_def.params.length
      if given != expected
        raise Stoffle::Error::Runtime::WrongNumArg.new(fn_def.function_name_as_str, given, expected)
      end

      # Applying the values passed in this particular function call to the respective defined parameters.
      if fn_def.params != nil
        fn_def.params.each_with_index { |param, i| env[param.name] = interpret_node(fn_call.args[i]) }
      end
    end

    def interpret_node(node)
      type = node.class.to_s.split('::').last.underscore # e.g., Stoffle::AST::FunctionCall becomes "function_call"
      interpreter_method = "interpret_#{type}"

      send(interpreter_method, node)
    end

    def interpret_identifier(identifier)
      env[identifier.name]
    end

    def interpret_var_binding(var_binding)
      env[var_binding.var_name_as_str] = interpret_node(var_binding.right)
    end

    # TODO Empty blocks are accepted both for the IF and for the ELSE. For the IF, the parser returns a block with an empty collection of expressions. For the else, no block is constructed. The evaluation is already resulting in nil, which is the desired behavior. It would be better, however, if the parser also returned a block with no expressions for an ELSE with an empty block, as is the case in an IF with an empty block. Investigate this nuance of the parser in the future.
    def interpret_conditional(conditional)
      evaluated_cond = interpret_node(conditional.condition)

      # We could implement the line below in a shorter way, but better to be explicit about truthiness in Stoffle.
      if evaluated_cond == nil || evaluated_cond == false
        return nil if conditional.when_false.nil?

        last_value = nil
        conditional.when_false.expressions.each { |expr| last_value = interpret_node(expr) }
        last_value
      else
        last_value = nil
        conditional.when_true.expressions.each { |expr| last_value = interpret_node(expr) }
        last_value
      end
    end

    def interpret_function_definition(fn_def)
      env[fn_def.function_name_as_str] = fn_def
    end

    def interpret_function_call(fn_call)
      return if println(fn_call)

      # TODO Deal with scopes.
      # TODO Deal with return inside functions (ideia: return (with the expression result) from the evaluation when a return node is detected).
      fn_def = fetch_function_definition(fn_call.function_name_as_str)

      assign_function_args_to_params(fn_call, fn_def)

      # Executing the function body.
      last_value = nil
      fn_def.body.expressions.each { |expr| last_value = interpret_node(expr) }
      last_value
    end

    # TODO Is this implementation REALLY the most straightforward in Ruby (apart from using eval)?
    def interpret_unary_operator(unary_op)
      case unary_op.operator
      when :'-'
        -(interpret_node(unary_op.operand))
      else # :'!'
        !(interpret_node(unary_op.operand))
      end
    end

    def interpret_binary_operator(binary_op)
      # Verbose implementation; might be interesting to comment about it in the article.
      # case binary_op.operator
      # when :'+'
      #   interpret_node(binary_op.left) + interpret_node(binary_op.right)
      # end

      case binary_op.operator
      when :and
        interpret_node(binary_op.left) && interpret_node(binary_op.right)
      when :or
        interpret_node(binary_op.left) || interpret_node(binary_op.right)
      else
        # TODO Add type verification (e.g. the operator '*' cannot have strings as its operands)
        interpret_node(binary_op.left).send(binary_op.operator, interpret_node(binary_op.right))
      end
    end

    def interpret_boolean(boolean)
      boolean.value
    end

    def interpret_nil(nil_node)
      nil
    end

    def interpret_number(number)
      number.value
    end

    def interpret_string(string)
      string.value
    end
  end
end
