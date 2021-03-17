# frozen_string_literal: true

module SystemRDL
  module Node
    class BinaryOperation < Base
      def initialize(operator, left, right)
        @operator = operator.to_sym
        @left = left
        @right = right
        super(operator.position)
      end

      attr_reader :operator
      attr_reader :left
      attr_reader :right

      def ==(other)
        case other
        when BinaryOperation then match?(other.operator, other.left, other.right_rhs)
        when Array then match?(*other)
        else false
        end
      end

      private

      def match?(oparator, left, right)
        self.operator == oparator && self.left == left && self.right == right
      end
    end
  end
end
