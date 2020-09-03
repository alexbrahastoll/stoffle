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

    def interpret_function_definition(fn_def)
      env[fn_def.function_name_as_str] = fn_def
    end

    def interpret_function_call(fn_call)
      if fn_call.function_name_as_str == 'println'
        result = interpret_node(fn_call.args.first).to_s
        output << result
        puts result
        return
      end

      # TODO Deal with scopes.
      # TODO Check if the function was actually defined.
      # TODO Check if the number of args match the number of params.
      # TODO Deal with return inside functions (ideia: return (with the expression result) from the evaluation when a return node is detected).
      fn_def = env[fn_call.function_name_as_str]
      # Applying the values passed in to the respective function parameters.
      if fn_def.params != nil
        fn_def.params.each_with_index { |param, i| env[param.name] = interpret_node(fn_call.args[i]) }
      end
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

      # TODO Add type verification (e.g. the operator '*' cannot have strings as its operands)
      interpret_node(binary_op.left).send(binary_op.operator, interpret_node(binary_op.right))
    end

    def interpret_number(number)
      number.value
    end

    def interpret_string(string)
      string.value
    end
  end
end
