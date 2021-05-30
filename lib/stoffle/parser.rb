module Stoffle
  class Parser
    attr_accessor :tokens, :ast, :errors

    UNARY_OPERATORS = [:'!', :'-'].freeze
    BINARY_OPERATORS = [:'+', :'-', :'*', :'/', :'==', :'!=', :'>', :'<', :'>=', :'<='].freeze
    LOGICAL_OPERATORS = [:or, :and].freeze

    LOWEST_PRECEDENCE = 0
    PREFIX_PRECEDENCE = 7
    OPERATOR_PRECEDENCE = {
      or:   1,
      and:  2,
      '==': 3,
      '!=': 3,
      '>':  4,
      '<':  4,
      '>=': 4,
      '<=': 4,
      '+':  5,
      '-':  5,
      '*':  6,
      '/':  6,
      '(':  8
    }.freeze

    def initialize(tokens)
      @tokens = tokens
      @ast = AST::Program.new
      @next_p = 0
      @errors = []
    end

    def parse
      while pending_tokens?
        consume

        node = parse_expr_recursively
        ast << node if node != nil
      end

      ast
    end

    private

    attr_accessor :next_p

    def build_token(type, lexeme = nil)
      Token.new(type, lexeme, nil, nil)
    end

    def pending_tokens?
      next_p < tokens.length
    end

    def nxt_not_terminator?
      nxt.type != :"\n" && nxt.type != :eof
    end

    def consume(offset = 1)
      t = lookahead(offset)
      self.next_p += offset
      t
    end

    def consume_if_nxt_is(expected)
      if nxt.type == expected.type
        consume
        true
      else
        unexpected_token_error(expected)
        false
      end
    end

    def previous
      lookahead(-1)
    end

    def current
      lookahead(0)
    end

    def nxt
      lookahead
    end

    def lookahead(offset = 1)
      lookahead_p = (next_p - 1) + offset
      return nil if lookahead_p < 0 || lookahead_p >= tokens.length

      tokens[lookahead_p]
    end

    def current_precedence
      OPERATOR_PRECEDENCE[current.type] || LOWEST_PRECEDENCE
    end

    def nxt_precedence
      OPERATOR_PRECEDENCE[nxt.type] || LOWEST_PRECEDENCE
    end

    def unrecognized_token_error
      errors << Error::Syntax::UnrecognizedToken.new(current)
    end

    def unexpected_token_error(expected = nil)
      errors << Error::Syntax::UnexpectedToken.new(current, nxt, expected)
    end

    def check_syntax_compliance(ast_node)
      return if ast_node.expects?(nxt)
      unexpected_token_error
    end

    def determine_parsing_function
      if [:return, :identifier, :number, :string, :true, :false, :nil, :fn,
          :if, :while].include?(current.type)
        "parse_#{current.type}".to_sym
      elsif current.type == :'('
        :parse_grouped_expr
      elsif [:"\n", :eof].include?(current.type)
        :parse_terminator
      elsif UNARY_OPERATORS.include?(current.type)
        :parse_unary_operator
      end
    end

    def determine_infix_function(token = current)
      if (BINARY_OPERATORS + LOGICAL_OPERATORS).include?(token.type)
        :parse_binary_operator
      elsif token.type == :'('
        :parse_function_call
      end
    end

    def parse_identifier
      if lookahead.type == :'='
        parse_var_binding
      else
        ident = AST::Identifier.new(current.lexeme)
        check_syntax_compliance(ident)
        ident
      end
    end

    def parse_string
      AST::String.new(current.literal)
    end

    def parse_number
      AST::Number.new(current.literal)
    end

    def parse_boolean
      AST::Boolean.new(current.lexeme == 'true')
    end

    def parse_nil
      AST::Nil.new
    end

    def parse_function_definition
      return unless consume_if_nxt_is(build_token(:identifier))
      fn = AST::FunctionDefinition.new(AST::Identifier.new(current.lexeme))

      if nxt.type != :"\n" && nxt.type != :':'
        unexpected_token_error
        return
      end

      fn.params = parse_function_params if nxt.type == :':'

      return unless consume_if_nxt_is(build_token(:"\n", "\n"))
      fn.body = parse_block

      fn
    end

    def parse_function_params
      consume
      return unless consume_if_nxt_is(build_token(:identifier))

      identifiers = []
      identifiers << AST::Identifier.new(current.lexeme)

      while nxt.type == :','
        consume
        return unless consume_if_nxt_is(build_token(:identifier))
        identifiers << AST::Identifier.new(current.lexeme)
      end

      identifiers
    end

    def parse_function_call(identifier)
      AST::FunctionCall.new(identifier, parse_function_call_args)
    end

    def parse_function_call_args
      args = []

      # Function call without arguments.
      if nxt.type == :')'
        consume
        return args
      end

      consume
      args << parse_expr_recursively

      while nxt.type == :','
        consume(2)
        args << parse_expr_recursively
      end

      return unless consume_if_nxt_is(build_token(:')', ')'))
      args
    end

    def parse_conditional
      conditional = AST::Conditional.new
      consume
      conditional.condition = parse_expr_recursively
      return unless consume_if_nxt_is(build_token(:"\n", "\n"))

      conditional.when_true = parse_block

      # TODO: Probably is best to use nxt and check directly; ELSE is optional and should not result in errors being added to the parsing. Besides that: think of some sanity checks (e.g., no parser errors) that maybe should be done in EVERY parser test.
      if consume_if_nxt_is(build_token(:else, 'else'))
        return unless consume_if_nxt_is(build_token(:"\n", "\n"))
        conditional.when_false = parse_block
      end

      conditional
    end

    def parse_repetition
      repetition = AST::Repetition.new
      consume
      repetition.condition = parse_expr_recursively
      return unless consume_if_nxt_is(build_token(:"\n", "\n"))

      repetition.block = parse_block
      repetition
    end

    def parse_block
      consume
      block = AST::Block.new
      while current.type != :end && current.type != :eof && nxt.type != :else
        expr = parse_expr_recursively
        block << expr unless expr.nil?
        consume
      end
      unexpected_token_error(build_token(:eof)) if current.type == :eof

      block
    end

    def parse_grouped_expr
      consume

      expr = parse_expr_recursively
      return unless consume_if_nxt_is(build_token(:')', ')'))

      expr
    end

    # TODO Temporary impl; reflect more deeply about the appropriate way of parsing a terminator.
    def parse_terminator
      nil
    end

    def parse_var_binding
      identifier = AST::Identifier.new(current.lexeme)
      consume(2)

      AST::VarBinding.new(identifier, parse_expr_recursively)
    end

    def parse_return
      consume
      AST::Return.new(parse_expr_recursively)
    end

    def parse_unary_operator
      op = AST::UnaryOperator.new(current.type)
      consume
      op.operand = parse_expr_recursively(PREFIX_PRECEDENCE)

      op
    end

    def parse_binary_operator(left)
      op = AST::BinaryOperator.new(current.type, left)
      op_precedence = current_precedence

      consume
      op.right = parse_expr_recursively(op_precedence)

      op
    end

    def parse_expr_recursively(precedence = LOWEST_PRECEDENCE)
      parsing_function = determine_parsing_function
      if parsing_function.nil?
        unrecognized_token_error
        return
      end
      expr = send(parsing_function)
      return if expr.nil? # When expr is nil, it means we have reached a \n or a eof.

      # Note that here we are checking the NEXT token.
      while nxt_not_terminator? && precedence < nxt_precedence
        infix_parsing_function = determine_infix_function(nxt)

        return expr if infix_parsing_function.nil?

        consume
        expr = send(infix_parsing_function, expr)
      end

      expr
    end

    alias_method :parse_true, :parse_boolean
    alias_method :parse_false, :parse_boolean
    alias_method :parse_fn, :parse_function_definition
    alias_method :parse_if, :parse_conditional
    alias_method :parse_while, :parse_repetition
  end
end
