# frozen_string_literal: true

module SystemRDL
  module Node
    class BinaryOperation
      def initialize(operator, left, right)
        @operator = operator.to_sym
        @left = left
        @right = right
        @position = operator.position
      end

      attr_reader :operator
      attr_reader :left
      attr_reader :right
      attr_reader :position
    end
  end
end
