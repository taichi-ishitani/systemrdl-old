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
    end
  end
end
