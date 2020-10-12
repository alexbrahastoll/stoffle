module Stoffle
  module Error
    module Runtime
      class UndefinedVariable < StandardError
        def initialize(variable_name)
          super("Undefined variable #{variable_name}")
        end
      end
    end
  end
end
