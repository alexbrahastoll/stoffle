module Stoffle
  class Parser
    attr_accessor :tokens, :ast

    def initialize(tokens)
      @tokens = tokens
      @ast = AST::Program.new
      @next_p = 0
    end

    def parse
      while pending_tokens?
        t = consume

        node =
          case t.type
          when :identifier
            parse_identifier
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

    def parse_identifier
      identifier = AST::Identifier.new(current.lexeme)

      t = consume
      case t.type
      when :'='
        parse_var_binding(identifier)
      else
        nil
      end
    end

    def parse_var_binding(identifier)
      AST::VarBinding.new(identifier, parse_expression)
    end

    def parse_expression
      AST::Expression.new
    end
  end
end
