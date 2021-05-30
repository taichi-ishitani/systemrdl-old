# frozen_string_literal: true

RSpec.describe 'parser/reference' do
  let(:prop_keywords) do
    ['sw', 'hw', 'rclr', 'rset', 'woclr', 'woset']
  end

  describe 'instance_ref' do
    let(:parser) do
      SystemRDL::Parser.new(:instance_ref)
    end

    def join_elements(elements, illegal_separator: false)
      separator =
        if illegal_separator
          [',', ':', ';', '/', '\\', ' '].sample
        else
          '.'
        end
      elements.join(separator)
    end

    it 'should be parsed by :instance_ref parser' do
      expect(parser).to parse('a', trace: true).as(&instance_ref('a'))
      expect(parser).to parse('regA.a', trace: true).as(&instance_ref('regA', 'a'))
      expect(parser).to parse('regFA[0].regA.a', trace: true).as(&instance_ref(['regFA', 0], 'regA', 'a'))
      expect(parser).to parse('regFA[1].regA.a', trace: true).as(&instance_ref(['regFA', 1], 'regA', 'a'))
    end

    specify 'elements should be separated by dot' do
      expect(parser).not_to parse(join_elements(['regA', 'a'], illegal_separator: true), trace: true)
      expect(parser).not_to parse(join_elements(['regFA[0]', 'regA', 'a'], illegal_separator: true), trace: true)
    end
  end

  describe 'property_ref' do
    let(:parser) do
      SystemRDL::Parser.new(:property_ref)
    end

    it 'should be parsed by :property_ref parser' do
      expect(parser).to parse('a->b', trace: true).as(&property_ref('a', 'b'))
      expect(parser).to parse('regA.a->b', trace: true).as(&property_ref('regA', 'a', 'b'))
      expect(parser).to parse('regFA[0].regA.a->b', trace: true).as(&property_ref(['regFA', 0], 'regA', 'a', 'b'))
      expect(parser).to parse('regFA[1].regA.a->b', trace: true).as(&property_ref(['regFA', 1], 'regA', 'a', 'b'))

      prop_keywords.each do |keyword|
        expect(parser).to parse("regFA[0].regA.a->#{keyword}", trace: true).as(&property_ref(['regFA', 0], 'regA', 'a', keyword))
      end
    end

    specify "instance_ref and property should be seperated by '->'" do
      expect(parser).not_to parse('a-b', trace: true)
      expect(parser).not_to parse('a>b', trace: true)
      expect(parser).not_to parse('a- >b', trace: true)
      expect(parser).not_to parse('a<-b', trace: true)
      expect(parser).not_to parse('a-<b', trace: true)
    end
  end

  specify 'instance_ref and property_ref should be treated as constant_primary' do
    parser = SystemRDL::Parser.new(:constant_expression)

    expect(parser).to parse('a', trace: true).as(&instance_ref('a'))
    expect(parser).to parse('regA.a', trace: true).as(&instance_ref('regA', 'a'))
    expect(parser).to parse('regFA[0].regA.a', trace: true).as(&instance_ref(['regFA', 0], 'regA', 'a'))
    expect(parser).to parse('regFA[1].regA.a', trace: true).as(&instance_ref(['regFA', 1], 'regA', 'a'))

    expect(parser).to parse('a->b', trace: true)#.as(&property_ref('a', 'b'))
    expect(parser).to parse('regA.a->b', trace: true).as(&property_ref('regA', 'a', 'b'))
    expect(parser).to parse('regFA[0].regA.a->b', trace: true).as(&property_ref(['regFA', 0], 'regA', 'a', 'b'))
    expect(parser).to parse('regFA[1].regA.a->b', trace: true).as(&property_ref(['regFA', 1], 'regA', 'a', 'b'))

    prop_keywords.each do |keyword|
      expect(parser).to parse("regFA[0].regA.a->#{keyword}", trace: true).as(&property_ref(['regFA', 0], 'regA', 'a', keyword))
    end
  end
end
