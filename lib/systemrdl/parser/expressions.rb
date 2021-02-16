# frozen_string_literal: true

module SystemRDL
  class Parser
    parse_rule(:constant_literal) do
      [
        number_literal, string_literal, enumerator_literal,
        this_keyword, simple_literal
      ].inject(:|)
    end

    parse_rule(:this_keyword) do
      str('this').as(:this_keyword)
    end

    transform_rule(this_keyword: simple(:this_keyword)) do
      Node::Identifier.new(this_keyword, keyword: true)
    end

    parse_rule(:expression_with_arenthesis) do
      str('(').ignore >> constant_expression >> str(')').ignore
    end

    parse_rule(:constant_pripary) do
      constant_literal | expression_with_arenthesis
    end

    parse_rule(:unary_op) do
      ['!', '+', '-', '&', '~&', '|', '~|', '~^', '^~', '~', '^']
        .map(&method(:str))
        .inject(:|)
    end

    parse_rule(:unary_operation) do
      unary_op.as(:operator).maybe >> constant_pripary.as(:operand)
    end

    transform_rule(
      operator: simple(:operator), operand: simple(:operand)
    ) do
      Node::UnaryOperation.new(operator, operand)
    end

    transform_rule(operand: simple(:operand)) do
      operand
    end

    parse_rule(:power_op) do
      str('**')
    end

    parse_rule(:mul_op) do
      match('[*/%]')
    end

    parse_rule(:add_op) do
      match('[+-]')
    end

    parse_rule(:shift_op) do
      str('>>') | str('<<')
    end

    parse_rule(:relational_op) do
      str('<=') |  str('<') | str('>=') | str('>')
    end

    parse_rule(:eq_op) do
      str('==') | str('!=')
    end

    parse_rule(:bit_and_op) do
      str('&')
    end

    parse_rule(:xor_op) do
      str('~^') | str('^~') | str('^')
    end

    parse_rule(:bit_or_op) do
      str('|')
    end

    parse_rule(:logic_and_op) do
      str('&&')
    end

    parse_rule('logic_or_op') do
      str('||')
    end

    BINARY_OPERATORS = [
      ['**', 11],
      ['*', 10], ['/', 10], ['%', 10],
      ['+', 9], ['-', 9],
      ['<<', 8], ['>>', 8],
      ['<=', 7], ['>=', 7], ['<', 7], ['>', 7],
      ['==', 6], ['!=', 6],
      ['&', 5],
      ['^', 4], ['~^', 4], ['^~', 4],
      ['|', 3],
      ['&&', 2],
      ['||', 1]
    ].sort_by { |op, _| op }.reverse.freeze

    parse_rule(:binary_operation) do
      operations =
        BINARY_OPERATORS
          .map { |op, level| [str(op), level, :left] }
      infix_expression(unary_operation, *operations)
    end

    transform_rule(
      l: simple(:left), o: simple(:operator), r: simple(:right)
    ) do
      Node::BinaryOperation.new(operator, left, right)
    end

    parse_rule(:conditional_operation) do
      binary_operation.as(:condition) >>
        (
          str('?').as(:operator) >>
          conditional_operation.as(:if_value) >>
          str(':') >>
          conditional_operation.as(:else_value)
        ).maybe
    end

    transform_rule(
      condition: simple(:condition), operator: simple(:operator),
      if_value: simple(:if_value), else_value: simple(:else_value)
    ) do
      Node::TernaryOperation.new(operator, condition, if_value, else_value)
    end

    transform_rule(condition: simple(:condition)) do
      condition
    end

    parse_rule(:constant_expression) do
      conditional_operation
    end
  end
end
