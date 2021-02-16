# frozen_string_literal: true

module SystemRDL
  module Node
    class TernaryOperation
      def initialize(operator, first, second, third)
        @operator = operator.to_sym
        @first = first
        @second = second
        @third = third
        @position = operator.position
      end

      attr_reader :operator
      attr_reader :first
      attr_reader :second
      attr_reader :third
      attr_reader :position
    end
  end
end
