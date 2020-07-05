module Stoffle
  module AST
    class Expression
      attr_accessor :value

      def initialize(val = nil)
        @value = val
      end

      # TODO Both implementations below are temporary. Expression SHOULD NOT have a concrete implementation of these methods.
      def ==(other)
        self.class == other.class
      end

      def children
        []
      end
    end
  end
end
