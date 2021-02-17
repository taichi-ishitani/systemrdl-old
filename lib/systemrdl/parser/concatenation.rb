# frozen_string_literal: true

module SystemRDL
  class Parser
    parse_rule(:constant_concatenation) do
      expression = constant_expression
      (
        str('{').as(:brace) >>
        (expression >> (str(',').ignore >> expression).repeat).as(:expressions) >>
        str('}').ignore
      )
    end

    transform_rule(brace: simple(:brace), expressions: simple(:expression)) do
      Node::Concatenation.new([expression], brace.position)
    end

    transform_rule(brace: simple(:brace), expressions: sequence(:expressions)) do
      Node::Concatenation.new(expressions, brace.position)
    end

    parse_rule(:constant_multiple_concatenation) do
      expression = constant_expression
      concatenation = constant_concatenation
      (
        str('{').as(:brace) >>
        expression.as(:multiplier) >> concatenation.as(:concatenation) >>
        str('}').ignore
      )
    end

    transform_rule(
      brace: simple(:brace),
      multiplier: simple(:multiplier), concatenation: simple(:concatenation)
    ) do
      Node::MultipleConcatenation.new(multiplier, concatenation, brace.position)
    end
  end
end
