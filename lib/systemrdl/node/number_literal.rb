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
        when NumberLiteral then super && width == other.width
        else super
        end
      end
    end
  end
end
