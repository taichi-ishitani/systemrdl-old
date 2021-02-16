# frozen_string_literal: true

module SystemRDL
  module Node
    class UnaryOperation
      def initialize(operator, operand)
        @operator = operator.to_sym
        @operand = operand
        @position = operator.position
      end

      attr_reader :operator
      attr_reader :operand
      attr_reader :position
    end
  end
end
