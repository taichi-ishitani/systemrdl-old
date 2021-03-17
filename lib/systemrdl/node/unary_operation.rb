# frozen_string_literal: true

module SystemRDL
  module Node
    class UnaryOperation < Base
      def initialize(operator, operand)
        @operator = operator.to_sym
        @operand = operand
        super(operand.position)
      end

      attr_reader :operator
      attr_reader :operand
    end
  end
end
