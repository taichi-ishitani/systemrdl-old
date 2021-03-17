# frozen_string_literal: true

module SystemRDL
  class Parser
    [
      'longint', 'bit', 'boolean'
    ].each do |type|
      parse_rule("#{type}_type".to_sym) do
        str(type).as(:type_keyword)
      end
    end

    transform_rule(type_keyword: simple(:type_keyword)) do
      Node::Identifier.new(type_keyword, keyword: true)
    end

    parse_rule(:integer_type) do
      longint_type | bit_type
    end

    parse_rule(:simple_type) do
      integer_type
    end
  end
end
