module Stoffle
  class Parser
    attr_accessor :tokens, :ast, :errors

    UNARY_OPERATORS = [:'!', :'-'].freeze

    LOWEST_PRECEDENCE = 0
    PREFIX_PRECEDENCE = 5
    OPERATOR_PRECEDENCE = {
      '==': 1,
      '!=': 1,
      '<':  2,
      '>':  2,
      '+':  3,
      '-':  3,
      '/':  4,
      '*':  4,
      '(':  6
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

        node =
          parse_var_binding ||
          parse_return ||
          parse_expr_recursively

        ast << node if node != nil
      end
    end

    private

    attr_accessor :next_p

    def pending_tokens?
      next_p < tokens.length
    end

    def consume(offset = 1)
      t = lookahead(offset)
      self.next_p += offset
      t
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

    def unrecognized_token_error
      errors << Error::Syntax::UnrecognizedToken.new(current)
    end

    def unexpected_token_error
      errors << Error::Syntax::UnexpectedToken.new(current, nxt)
    end

    def check_syntax_compliance(ast_node)
      return if ast_node.expects?(nxt)
      unexpected_token_error
    end

    def determine_parsing_function
      # TODO Use metaprogramming to eliminate (or at least reduce) the conditionals.
      if current.type == :identifier
        :parse_identifier
      elsif current.type == :number
        :parse_number
      elsif current.type == :"\n" || current.type == :eof
        :parse_terminator
      end
    end

    def determine_prefix_function
      if UNARY_OPERATORS.include?(current.type)
        :parse_unary_operator
      end
    end

    def determine_infix_function
    end

    def parse_identifier
      ident = AST::Identifier.new(current.lexeme)
      check_syntax_compliance(ident)
      ident
    end

    def parse_number
      AST::Number.new(current.literal)
    end

    # TODO Temporary impl; reflect more deeply about the appropriate way of parsing a terminator.
    def parse_terminator
      nil
    end

    def parse_var_binding
      return unless current.type == :identifier && lookahead.type == :'='

      identifier = AST::Identifier.new(current.lexeme)
      consume(2)

      AST::VarBinding.new(identifier, parse_expr_recursively)
    end

    def parse_return
      return unless current.type == :return

      consume
      AST::Return.new(parse_expr_recursively)
    end

    def parse_unary_operator
      op = AST::UnaryOperator.new(current.type)
      consume
      op.operand = parse_expr_recursively(PREFIX_PRECEDENCE)

      op
    end

    def parse_expression
      AST::Expression.new
    end

    def parse_expr_recursively(precedence = LOWEST_PRECEDENCE)
      parsing_function = determine_parsing_function || determine_prefix_function
      if parsing_function.nil?
        unrecognized_token_error
        return
      end

      expr = send(parsing_function)
    end
  end
end
