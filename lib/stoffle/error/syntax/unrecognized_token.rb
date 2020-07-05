module Stoffle
  module Error
    module Syntax
      class UnrecognizedToken < StandardError
        attr_reader :unrecognized_token

        def initialize(token)
          @unrecognized_token = token
          message = "Unrecognized token #{unrecognized_token.lexeme}"
          super(message)
        end
      end
    end
  end
end
