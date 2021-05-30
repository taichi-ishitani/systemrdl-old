# frozen_string_literal: true

module SystemRDL
  class Parser
    #
    # instance_ref
    #
    parse_rule(:instance_ref_element) do
      (id.as(:instance_id) >> array.as(:array).maybe).as(:instance_ref_element)
    end

    transform_rule(instance_ref_element: { instance_id: simple(:id) }) do
      Node::InstanceRefElement.new(id, nil)
    end

    transform_rule(instance_ref_element: {
      instance_id: simple(:id), array: simple(:array)
    }) do
      Node::InstanceRefElement.new(id, array)
    end

    parse_rule(:array) do
      str('[').ignore >> constant_expression >> str(']').ignore
    end

    parse_rule(:instance_ref) do
      (
        instance_ref_element >> (str('.').ignore >> instance_ref_element).repeat
      ).as(:instance_ref)
    end

    transform_rule(instance_ref: simple(:instance_ref_element)) do
      Node::InstanceRef.new([instance_ref_element])
    end

    transform_rule(instance_ref: sequence(:instance_ref_elements)) do
      Node::InstanceRef.new(instance_ref_elements)
    end

    #
    # property ref
    #

    parse_rule(:prop_keyword) do
      ['sw', 'hw', 'rclr', 'rset', 'woclr', 'woset']
        .map(&method(:keyword))
        .inject(:|)
    end

    parse_rule(:property_ref) do
      (
        instance_ref.as(:instance_ref) >>
          str('->').ignore >> (prop_keyword | id).as(:property)
      ).as(:property_ref)
    end

    transform_rule(property_ref: {
      instance_ref: simple(:instance_ref), property: simple(:property)
    }) do
      Node::PropertyRef.new(instance_ref, property)
    end
  end
end
