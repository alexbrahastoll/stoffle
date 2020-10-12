module Stoffle
  module Runtime
    class StackFrame
      attr_reader :fn_def, :fn_call, :env

      def initialize(fn_def_ast, fn_call_ast)
        @fn_def = fn_def_ast
        @fn_call = fn_call_ast
        @env = {}
      end
    end
  end
end
