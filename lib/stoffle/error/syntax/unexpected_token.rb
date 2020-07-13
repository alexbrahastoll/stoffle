module Stoffle
  module Error
    module Syntax
      class UnexpectedToken < StandardError
        attr_reader :current_token, :next_token, :expected_token

        def initialize(curr, nxt, expected = nil)
          @current_token = curr
          @next_token = nxt
          @expected_token = expected
          message = "Unexpected token #{next_token.lexeme} after #{current_token.lexeme}"
          message += "\nExpected: #{expected_token.lexeme}" unless expected_token.nil?
          super(message)
        end
      end
    end
  end
end
