# frozen_string_literal: true

module SystemRDL
  module Node
    StructLiteralMember = Struct.new(:name, :value)

    class StructLiteral
      def initialize(type_name, members)
        @type_name = type_name
        @members = members.map(&:to_a).to_h.transform_keys(&:to_s)
        @member_names = members.map(&:name)
        @position = type_name.position
      end

      attr_reader :type_name
      attr_reader :members
      attr_reader :member_names
      attr_reader :position

      def ==(other)
        case other
        when StructLiteral
          type_name == other.type_name && member_names == other.members
        when Array
          other_type_name, other_members = other
          [type_name, members] ==
            [other_type_name.to_s, other_members.transform_keys(&:to_s)]
        else false
        end
      end
    end
  end
end
