# frozen_string_literal: true

module SystemRDL
  class Parser
    parse_rule(:id) do
      (non_escaped_identifier | escaped_identifier).as(:id)
    end

    parse_rule(:simple_identifier) do
      match('[_a-zA-Z]') >> match('[_a-zA-Z0-9]').repeat
    end

    parse_rule(:non_escaped_identifier) do
      simple_identifier
    end

    parse_rule(:escaped_identifier) do
      str('\\') >> simple_identifier
    end

    transform_rule(id: simple(:id)) do
      Node::Identifier.new(id)
    end
  end
end
