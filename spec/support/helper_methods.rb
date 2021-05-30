# frozen_string_literal: true

module SystemRDL
  module HelperMethods
    def identifier(id)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Identifier) &&
          result == id
      end
    end

    def literal(type, value)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Literal) &&
          result.type == type && result == value
      end
    end

    def number_literal(value, width: nil)
      lambda do |result|
        result.is_a?(SystemRDL::Node::NumberLiteral) &&
          result == [value, width]
      end
    end

    def enumerator_literal(type_name, mnemonic_name)
      lambda do |result|
        result.is_a?(SystemRDL::Node::EnumeratorLiteral) &&
          result == [type_name, mnemonic_name]
      end
    end

    def struct_literal(type_name_and_members)
      lambda do |result|
        result.is_a?(SystemRDL::Node::StructLiteral) && result == type_name_and_members
      end
    end

    def array_literal(expressions)
      lambda do |result|
        result.is_a?(SystemRDL::Node::ArrayLiteral) && result == expressions
      end
    end

    def concatenation(expressions)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Concatenation) && result == expressions
      end
    end

    def multiple_concatenation(multiplier, expressions)
      lambda do |result|
        result.is_a?(SystemRDL::Node::MultipleConcatenation) &&
          result == [multiplier, expressions]
      end
    end

    def constant_cast(casting_type, expression)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Cast) &&
          result == [casting_type, expression]
      end
    end

    def instance_ref(*ref_elements)
      lambda do |result|
        result.is_a?(SystemRDL::Node::InstanceRef) &&
          result == ref_elements
      end
    end

    def property_ref(*instance_ref, property)
      lambda do |result|
        result.is_a?(SystemRDL::Node::PropertyRef) &&
          result == [*instance_ref, property]
      end
    end
  end
end
