# frozen_string_literal: true

module SystemRDL
  module HelperMethods
    def identifier(id)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Identifier) &&
          result.identifier == id
      end
    end

    def literal(type, value)
      lambda do |result|
        result.is_a?(SystemRDL::Node::Literal) &&
          result.type == type && result.value == value
      end
    end

    def number_literal(value, width: nil)
      lambda do |result|
        result.is_a?(SystemRDL::Node::NumberLiteral) &&
          result.value == value && result.width == width
      end
    end

    def enumerator_literal(type_name, mnemonic_name)
      lambda do |result|
        result.is_a?(SystemRDL::Node::EnumeratorLiteral) &&
          result.type_name == type_name && result.mnemonic_name == mnemonic_name
      end
    end
  end
end
