# frozen_string_literal: true

module SystemRDL
  class Parser
    class << self
      private

      def literal_parse_rule(rule_name, literals)
        parse_rule(rule_name) do
          literals
            .map(&method(:str))
            .inject(:|)
            .yield_self { |atom| atom.as(rule_name) }
        end
      end

      def literal_transform_rule(rule_name, literal_type, &modifier)
        transform_rule(rule_name => simple(:value)) do
          modified_value =
            if modifier
              modifier.call(value)
            else
              value.to_sym
            end
          Node::Literal.new(literal_type, modified_value, value.position)
        end
      end

      def simple_literal(literal_type, literals, &modifier)
        rule_name = "#{literal_type}_literal".to_sym
        literal_parse_rule(rule_name, literals)
        literal_transform_rule(rule_name, literal_type, &modifier)
      end
    end

    simple_literal(:boolean, ['true', 'false']) do |value|
      { 'true' => true, 'false' => false }[value.str]
    end

    simple_literal(
      :accesstype,
      ['na', 'rw', 'wr', 'r', 'w', 'rw1', 'w1']
    )

    simple_literal(
      :onreadtype,
      ['rclr', 'rset', 'ruser']
    )

    simple_literal(
      :onwritetype,
      ['woset', 'woclr', 'wot', 'wzs', 'wzc', 'wzt', 'wclr', 'wset', 'wuser']
    )

    simple_literal(
      :addressingtype,
      ['compact', 'regalign', 'fullalign']
    )

    simple_literal(
      :precedencetype,
      ['hw', 'sw']
    )
  end
end
