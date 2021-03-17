# frozen_string_literal: true

module SystemRDL
  module Node
    class Cast < Base
      def initialize(casting_type, expression)
        @casting_type = casting_type
        @expression = expression
        super(casting_type.position)
      end

      attr_reader :casting_type
      attr_reader :expression

      def ==(other)
        case other
        when Cast then match?(other.casting_type, other.expression)
        when Array then match?(*other)
        else false
        end
      end

      private

      def match?(casting_type, expression)
        self.casting_type == casting_type && self.expression == expression
      end
    end
  end
end
