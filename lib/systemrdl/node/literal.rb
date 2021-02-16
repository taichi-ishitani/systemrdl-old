# frozen_string_literal: true

module SystemRDL
  module Node
    class Literal
      def initialize(type, value, position)
        @type = type
        @value = value
        @position = position
      end

      attr_reader :type
      attr_reader :value
      attr_reader :position

      def ==(other)
        case other
        when Literal then type == other.type && value == other.value
        else value == other
        end
      end
    end
  end
end
