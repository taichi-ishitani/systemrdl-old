# frozen_string_literal: true

module SystemRDL
  module Node
    class TernaryOperation < Base
      def initialize(operator, first, second, third)
        @operator = operator.to_sym
        @first = first
        @second = second
        @third = third
        super(operator.position)
      end

      attr_reader :operator
      attr_reader :first
      attr_reader :second
      attr_reader :third
    end
  end
end
