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

    #
    # Simple literals
    #

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

    #
    # String literal
    #

    parse_rule(:string_literal) do
      (
        str('"') >>
        (str('\\"') | str('"').absent? >> any).repeat >>
        str('"')
      ).as(:string_literal)
    end

    literal_transform_rule(:string_literal, :string) do |value|
      value.str.slice(1...-1).gsub('\\"', '"')
    end

    #
    # Number literal
    #

    parse_rule(:underscore?) do
      str('_').maybe
    end

    parse_rule(:binary_digit) do
      str('0') | str('1')
    end

    parse_rule(:decimal_digit) do
      match('[0-9]')
    end

    parse_rule(:non_zero_decimal_digit) do
      match('[1-9]')
    end

    parse_rule(:hexadecimal_digit) do
      match('[0-9a-fA-F]')
    end

    parse_rule(:binary_number) do
      binary_digit >> (underscore? >> binary_digit).repeat
    end

    parse_rule(:decimal_number) do
      decimal_digit |
        (non_zero_decimal_digit >> (underscore? >> decimal_digit).repeat)
    end

    parse_rule(:hexadecimal_number) do
      hexadecimal_digit >> (underscore? >> hexadecimal_digit).repeat
    end

    parse_rule(:simple_decimal) do
      decimal_number
    end

    parse_rule(:simple_hexadecimal) do
      (str('0x') | (str('0X'))) >> hexadecimal_number
    end

    parse_rule(:simple_number) do
      (simple_decimal | simple_hexadecimal).as(:simple_number)
    end

    transform_rule(simple_number: simple(:number)) do
      Node::NumberLiteral.new(Integer(number.str), nil, number.position)
    end

    parse_rule(:verilog_sytle_width) do
      non_zero_decimal_digit >> decimal_digit.repeat
    end

    parse_rule(:verilog_sytle_binary) do
      verilog_sytle_width.as(:width) >>
        str("'") >> match('[bB]').as(:radix) >> binary_number.as(:number)
    end

    parse_rule(:verilog_sytle_decimal) do
      verilog_sytle_width.as(:width) >>
        str("'") >> match('[dD]').as(:radix) >> decimal_number.as(:number)
    end

    parse_rule(:verilog_sytle_hexadecimal) do
      verilog_sytle_width.as(:width) >>
        str("'") >> match('[hH]').as(:radix) >> hexadecimal_number.as(:number)
    end

    parse_rule(:verilog_sytle_number) do
      (
        verilog_sytle_binary | verilog_sytle_decimal | verilog_sytle_hexadecimal
      ).as(:verilog_sytle_number)
    end

    transform_rule(
      verilog_sytle_number: {
        width: simple(:width), radix: simple(:radix), number: simple(:number)
      }
    ) do
      radix_value = {
        'b' => 2, 'd' => 10, 'h' => 16
      }[radix.str.downcase]
      Node::NumberLiteral.new(number.str.to_i(radix_value), width.to_i, width.position)
    end

    parse_rule(:number_literal) do
      simple_number | verilog_sytle_number
    end
  end
end
