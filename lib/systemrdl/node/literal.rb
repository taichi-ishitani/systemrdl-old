# frozen_string_literal: true

module SystemRDL
  module Node
    class Literal < Base
      def initialize(type, value, position)
        @type = type
        @value = value
        super(position)
      end

      attr_reader :type
      attr_reader :value

      def ==(other)
        case other
        when Literal then type == other.type && value == other.value
        else value == other
        end
      end
    end
  end
end
