# frozen_string_literal: true

module SystemRDL
  module Node
    class MultipleConcatenation
      def initialize(multiplier, concatenation, position)
        @multiplier = multiplier
        @concatenation = concatenation
        @position = position
      end

      attr_reader :multiplier
      attr_reader :concatenation
      attr_reader :position
    end
  end
end
