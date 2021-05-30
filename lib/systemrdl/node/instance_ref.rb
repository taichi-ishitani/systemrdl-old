# frozen_string_literal: true

module SystemRDL
  module Node
    InstanceRefElement = Struct.new(:id, :array) do
      def ==(other)
        id_rhs, array_rhs =
          case other
          when InstanceRefElement
            [other.id, other.array]
          else
            Array(other)[0..1]
          end
        id == id_rhs && array == array_rhs
      end
    end

    class InstanceRef < Base
      def initialize(ref_elements)
        @elements = create_ref_elemetns(ref_elements)
        super(@elements.first.id.position)
      end

      attr_reader :elements

      def ==(other)
        case other
        when InstanceRef
          @elements == other.elements
        else
          @elements == other
        end
      end

      private

      def create_ref_elemetns(ref_elements)
        ref_elements.map { |e| InstanceRefElement.new(*Array(e)[0..1]) }
      end
    end
  end
end
