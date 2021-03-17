# frozen_string_literal: true

module SystemRDL
  module Node
    class Concatenation < Base
      def initialize(expressions, position)
        @expressions = expressions
        super(position)
      end

      attr_reader :expressions

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
