# frozen_string_literal: true

module SystemRDL
  module Node
    class NumberLiteral < Literal
      def initialize(value, width, position)
        super(:number, value, position)
        @width = width
      end

      attr_reader :width

      def ==(other)
        case other
        when NumberLiteral then match?(other.value, other.width)
        when Array then match?(*other)
        else super
        end
      end

      private

      def match?(value, width)
        self.value == value && self.width == width
      end
    end
  end
end
