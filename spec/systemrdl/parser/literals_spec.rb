# frozen_string_literal: true

RSpec.describe 'parser/literals' do
  def literal(type, value)
    lambda do |result|
      result.is_a?(SystemRDL::Node::Literal) &&
        result.type == type && result.value == value
    end
  end

  def upcase_randomly(string)
    pos =
      (0...string.size)
        .to_a
        .select { |i| /[a-z]/i =~ string[i] }
        .sample
    string
      .each_char
      .map.with_index { |char, index| index == pos && char.upcase || char }
      .join
  end

  describe 'boolean literal' do
    let(:parser) do
      SystemRDL::Parser.new(:boolean_literal)
    end

    it 'should be parsed by :boolean_literal parser' do
      expect(parser).to parse('true', trace: true).as(&literal(:boolean, true))
      expect(parser).to parse('false', trace: true).as(&literal(:boolean, false))
    end

    it 'should be case sensitive' do
      ['true', 'false'].each do |value|
        expect(parser).not_to parse(value.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(value), trace: true)
      end
    end
  end

  describe 'string literal' do
    let(:parser) do
      SystemRDL::Parser.new(:string_literal)
    end

    it 'should be parsed by :string_literal parser' do
      [
        'This is a string',
        "This is also\na string!",
        ''
      ].each do |string|
        expect(parser).to parse("\"#{string}\"", trace: true)
          .as(&literal(:string, string))
      end
    end

    specify 'double quote can be escaped by using \\' do
      expect(parser).to parse('"\\"\\"\\""', trace: true)
        .as(&literal(:string, '"""'))
      expect(parser).to parse('"This third string contains a \\"double quote\\""', trace: true)
        .as(&literal(:string, 'This third string contains a "double quote"'))
    end

    it 'can include any characters encoded using UTF-8' do
      [
        'これは文字列です',
        'ＴＨＩＳ　ＩＳ　Ａ　ＳＴＲＩＮＧ'
      ].each do |string|
        expect(parser).to parse("\"#{string}\"", trace: true)
          .as(&literal(:string, string))
      end
    end

    it 'should be enclosed by double quotes' do
      expect(parser).not_to parse("'This is a string'", trace: true)
      expect(parser).not_to parse('"This is a string', trace: true)
      expect(parser).not_to parse('"This is a string\'', trace: true)
    end
  end

  describe 'accesstype literal' do
    let(:parser) do
      SystemRDL::Parser.new(:accesstype_literal)
    end

    let(:accesstypes) do
      ['na', 'rw', 'wr', 'r', 'w', 'rw1', 'w1']
    end

    it 'should be parsed by :access_type parser' do
      accesstypes.each do |accesstype|
        expect(parser).to parse(accesstype, trace: true)
          .as(&literal(:accesstype, accesstype.to_sym))
      end
    end

    it 'should be case sensitive' do
      accesstypes.each do |accesstype|
        expect(parser).not_to parse(accesstype.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(accesstype), trace: true)
      end
    end
  end

  describe 'onreadtype literal' do
    let(:parser) do
      SystemRDL::Parser.new(:onreadtype_literal)
    end

    let(:onreadtypes) do
      ['rclr', 'rset', 'ruser']
    end

    it 'should be parsed by :onreadtype_literal parser' do
      onreadtypes.each do |onreadtype|
        expect(parser).to parse(onreadtype, trace: true)
          .as(&literal(:onreadtype, onreadtype.to_sym))
      end
    end

    it 'should be case sensitive' do
      onreadtypes.each do |onreadtype|
        expect(parser).not_to parse(onreadtype.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(onreadtype), trace: true)
      end
    end
  end

  describe 'onwritetype literal' do
    let(:parser) do
      SystemRDL::Parser.new(:onwritetype_literal)
    end

    let(:onwritetypes) do
      ['woset', 'woclr', 'wot', 'wzs', 'wzc', 'wzt', 'wclr', 'wset', 'wuser']
    end

    it 'should be parsed by :onwritetype_literal parser' do
      onwritetypes.each do |onwritetype|
        expect(parser).to parse(onwritetype, trace: true)
          .as(&literal(:onwritetype, onwritetype.to_sym))
      end
    end

    it 'should be case sensitive' do
      onwritetypes.each do |onwritetype|
        expect(parser).not_to parse(onwritetype.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(onwritetype), trace: true)
      end
    end
  end

  describe 'addressingtype literal' do
    let(:parser) do
      SystemRDL::Parser.new(:addressingtype_literal)
    end

    let(:addressingtypes) do
      ['compact', 'regalign', 'fullalign']
    end

    it 'should be parsed by :addressingtype_literal parser' do
      addressingtypes.each do |addressingtype|
        expect(parser).to parse(addressingtype, trace: true)
          .as(&literal(:addressingtype, addressingtype.to_sym))
      end
    end

    it 'should be case sensitive' do
      addressingtypes.each do |addressingtype|
        expect(parser).not_to parse(addressingtype.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(addressingtype), trace: true)
      end
    end
  end

  describe 'precedencetype literal' do
    let(:parser) do
      SystemRDL::Parser.new(:precedencetype_literal)
    end

    let(:precedencetypes) do
      ['hw', 'sw']
    end

    it 'should be parsed by :precedencetype_literal parser' do
      precedencetypes.each do |precedencetype|
        expect(parser).to parse(precedencetype, trace: true)
          .as(&literal(:precedencetype, precedencetype.to_sym))
      end
    end

    it 'should be case sensitive' do
      precedencetypes.each do |precedencetype|
        expect(parser).not_to parse(precedencetype.upcase, trace: true)
        expect(parser).not_to parse(upcase_randomly(precedencetype), trace: true)
      end
    end
  end
end
