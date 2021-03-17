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

    parse_rule(:expression_with_parenthesis) do
      str('(').ignore >> constant_expression >> str(')').ignore
    end

    parse_rule(:type_based_constant_cast) do
      casting_type = (simple_type | boolean_type).as(:casting_type)
      expression = expression_with_parenthesis.as(:expression)
      casting_type >> str("'").ignore >> expression
    end

    parse_rule(:casting_type_width) do
      [
        constant_literal, expression_with_parenthesis,
        constant_concatenation, constant_multiple_concatenation,
        struct_literal, array_literal, type_based_constant_cast
      ].inject(:|)
    end

    parse_rule(:width_based_constant_cast) do
      casting_type = casting_type_width.as(:casting_type)
      expression = expression_with_parenthesis.as(:expression)
      (
        casting_type >> (str("'").ignore >> expression).repeat
      ).as(:width_based_constant_cast)
    end

    transform_rule(casting_type: simple(:casting_type)) do
      casting_type
    end

    transform_rule(
      casting_type: simple(:casting_type), expression: simple(:expression)
    ) do
      Node::Cast.new(casting_type, expression)
    end

    transform_rule(width_based_constant_cast: subtree(:cast)) do
      if cast.is_a?(Array)
        cast.inject do |casting_type, expression|
          Node::Cast.new(casting_type, expression[:expression])
        end
      else
        cast
      end
    end

    parse_rule(:constant_primary) do
      width_based_constant_cast
    end

    parse_rule(:unary_op) do
      ['!', '+', '-', '&', '~&', '|', '~|', '~^', '^~', '~', '^']
        .map(&method(:str))
        .inject(:|)
    end

    parse_rule(:unary_operation) do
      unary_op.as(:operator).maybe >> constant_primary.as(:operand)
    end

    transform_rule(
      operator: simple(:operator), operand: simple(:operand)
    ) do
      Node::UnaryOperation.new(operator, operand)
    end

    transform_rule(operand: simple(:operand)) do
      operand
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
