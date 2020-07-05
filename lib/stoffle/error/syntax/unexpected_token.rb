module Stoffle
  module Error
    module Syntax
      class UnexpectedToken < StandardError
        attr_reader :current_token, :next_token

        def initialize(curr, nxt)
          @current_token = curr
          @next_token = nxt
          message = "Unexpected token #{next_token.lexeme} after #{current_token.lexeme}"
          super(message)
        end
      end
    end
  end
end
