# frozen_string_literal: true

module SystemRDL
  class Parser
    #
    # Simple literals
    #

    SIMPLE_LITERALS = {
      boolean: ['true', 'false'],
      accesstype: ['na', 'rw1', 'rw', 'wr', 'r', 'w1', 'w'],
      onreadtype: ['rclr', 'rset', 'ruser'],
      onwritetype: ['woset', 'woclr', 'wot', 'wzs', 'wzc', 'wzt', 'wclr', 'wset', 'wuser'],
      addressingtype: ['compact', 'regalign', 'fullalign'],
      precedencetype: ['hw', 'sw']
    }.map { |type, values| values.product([type]) }.flatten(1).to_h

    parse_rule(:simple_literal) do
      SIMPLE_LITERALS
        .keys.sort.reverse
        .map { |literal| str(literal).as(:simple_literal) }
        .inject(:|)
    end

    transform_rule(simple_literal: simple(:simple_literal)) do
      type = SIMPLE_LITERALS[simple_literal.str]
      value =
        if type == :boolean
          { 'true' => true, 'false' => false }[simple_literal.str]
        else
          simple_literal.to_sym
        end
      Node::Literal.new(type, value, simple_literal.position)
    end

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

    transform_rule(string_literal: simple(:value)) do
      string = value.str.slice(1..-2).gsub('\\"', '"')
      Node::Literal.new(:string, string, value.position)
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
      (non_zero_decimal_digit >> (underscore? >> decimal_digit).repeat) | decimal_digit
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
      (simple_hexadecimal | simple_decimal).as(:simple_number)
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
      (verilog_sytle_binary | verilog_sytle_decimal | verilog_sytle_hexadecimal)
        .as(:verilog_sytle_number)
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
      verilog_sytle_number | simple_number
    end

    #
    # Enumerator literal
    #

    parse_rule(:enumerator_literal) do
      (id.as(:type_name) >> str('::') >> id.as(:mnemonic_name))
        .as(:enumerator_literal)
    end

    transform_rule(
      enumerator_literal: {
        type_name: simple(:type_name), mnemonic_name: simple(:mnemonic_name)
      }
    ) do
      Node::EnumeratorLiteral.new(type_name, mnemonic_name)
    end
  end
end
