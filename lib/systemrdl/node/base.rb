# frozen_string_literal: true

module SystemRDL
  module Node
    class Base
      def initialize(position)
        @position = position
      end

      attr_reader :position
    end
  end
end
