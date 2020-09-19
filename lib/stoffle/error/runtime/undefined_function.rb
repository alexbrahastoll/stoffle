module Stoffle
  module Error
    module Runtime
      class UndefinedFunction < StandardError
        def initialize(fn_name)
          super("Undefined function #{fn_name}")
        end
      end
    end
  end
end
