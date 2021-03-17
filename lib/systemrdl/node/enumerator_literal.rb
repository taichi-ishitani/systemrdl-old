# frozen_string_literal: true

module SystemRDL
  module Node
    class EnumeratorLiteral < Literal
      def initialize(type_name, mnemonic_name)
        super(:enumerator, nil, type_name.position)
        @type_name = type_name
        @mnemonic_name = mnemonic_name
      end

      attr_reader :type_name
      attr_reader :mnemonic_name

      def ==(other)
        case other
        when EnumeratorLiteral then match?(other.type_name, other.mnemonic_name)
        when Array then match?(*other)
        else false
        end
      end

      private

      def match?(type_name, mnemonic_name)
        self.type_name == type_name && self.mnemonic_name == mnemonic_name
      end
    end
  end
end
