# frozen_string_literal: true

module SystemRDL
  module Node
    class PropertyRef < Base
      def initialize(instance_ref, property)
        @instance_ref = instance_ref
        @property = property
        super(instance_ref.position)
      end

      attr_reader :instance_ref
      attr_reader :property

      def ==(other)
        instance_ref_rhs, property_rhs =
          case other
          when PropertyRef
            [other.instance_ref, other.property]
          else
            Array(other).yield_self { |rhs| [rhs[0..-2], rhs[-1]] }
          end
        instance_ref == instance_ref_rhs && property == property_rhs
      end
    end
  end
end
