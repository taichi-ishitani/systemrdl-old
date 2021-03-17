# frozen_string_literal: true

module SystemRDL
  module Node
    class MultipleConcatenation < Base
      def initialize(multiplier, concatenation, position)
        @multiplier = multiplier
        @concatenation = concatenation
        super(position)
      end

      attr_reader :multiplier
      attr_reader :concatenation

      def ==(other)
        case other
        when MultipleConcatenation then match?(other.multiplier, other.concatenation)
        when Array then match?(*other)
        end
      end

      private

      def match?(multiplier, concatenation)
        self.multiplier == multiplier && self.concatenation == concatenation
      end
    end
  end
end
