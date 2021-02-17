# frozen_string_literal: true

module SystemRDL
  module Node
    class Concatenation
      def initialize(expressions, position)
        @expressions = expressions
        @position = position
      end

      attr_reader :expressions
      attr_reader :position

      def ==(other)
        case other
        when Concatenation then expressions == other.expressions
        when Array then expressions == other
        else false
        end
      end
    end
  end
end
