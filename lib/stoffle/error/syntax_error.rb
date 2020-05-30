module Stoffle
  module Error
    class SyntaxError < StandardError
      attr_reader :unexpected_token

      def initialize(token)
        @unexpected_token = token
        message = "Unexpected character #{unexpected_token.lexeme}"
        super(message)
      end
    end
  end
end
