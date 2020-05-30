module Stoffle
  class Parser
    attr_accessor :tokens, :ast, :errors

    def initialize(tokens)
      @tokens = tokens
      @ast = AST::Program.new
      @next_p = 0
      @errors = []
    end

    def parse
      while pending_tokens?
        t = consume

        node =
          case t.type
          when :identifier
            parse_identifier
          when :return
            parse_return
          else
            nil
          end

        ast << node if node != nil
      end
    end

    private

    attr_accessor :next_p

    def pending_tokens?
      next_p < tokens.length
    end

    def consume
      t = lookahead
      self.next_p += 1
      t
    end

    def current
      lookahead(0)
    end

    def lookahead(offset = 1)
      lookahead_p = (next_p - 1) + offset
      return nil if lookahead_p >= tokens.length

      tokens[lookahead_p]
    end

    def syntax_error(unexpected_token)
      errors << Error::SyntaxError.new(unexpected_token)
    end

    def parse_identifier
      identifier = AST::Identifier.new(current.lexeme)

      t = consume
      case t.type
      when :'='
        parse_var_binding(identifier)
      when :"\n"
        identifier
      else
        syntax_error(t)
        nil
      end
    end

    def parse_return
      AST::Return.new(parse_expression)
    end

    def parse_var_binding(identifier)
      AST::VarBinding.new(identifier, parse_expression)
    end

    def parse_expression
      AST::Expression.new
    end
  end
end
