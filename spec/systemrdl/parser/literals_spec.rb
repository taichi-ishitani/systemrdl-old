# frozen_string_literal: true

RSpec.describe 'parser/literals' do
  def literal(type, value)
    lambda do |result|
      result.is_a?(SystemRDL::Node::Literal) &&
        result.type == type && result.value == value
    end
  end

  def number_literal(value, width: nil)
    lambda do |result|
      result.is_a?(SystemRDL::Node::NumberLiteral) &&
        result.value == value && result.width == width
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

  describe 'number literal' do
    let(:parser) do
      SystemRDL::Parser.new(:number_literal)
    end

    specify 'simple decimal and hexadecimal should be parsed as number literals' do
      expect(parser).to parse('0', trace: true).as(&number_literal(0))
      expect(parser).to parse('40', trace: true).as(&number_literal(40))
      expect(parser).to parse('0x45', trace: true).as(&number_literal(0x45))
      expect(parser).to parse('0XAbCdEf', trace: true).as(&number_literal(0xabcdef))
    end

    specify 'verilog style binary, decimal and hexadecimal should be parsed as number literals' do
      expect(parser).to parse("3'b101", trace: true).as(&number_literal(0b101, width: 3))
      expect(parser).to parse("4'B1010", trace: true).as(&number_literal(0b1010, width: 4))
      expect(parser).to parse("4'd0", trace: true).as(&number_literal(0, width: 4))
      expect(parser).to parse("4'd1", trace: true).as(&number_literal(1, width: 4))
      expect(parser).to parse("10'D123", trace: true).as(&number_literal(123, width: 10))
      expect(parser).to parse("32'hdeadbeaf", trace: true).as(&number_literal(0xdeadbeaf, width: 32))
      expect(parser).to parse("32'HDEADBEAF", trace: true).as(&number_literal(0xdeadbeaf, width: 32))
    end

    specify 'width of verilog style number should be specified' do
      expect(parser).not_to parse("'d1", trace: true)
      expect(parser).not_to parse("'b101", trace: true)
      expect(parser).not_to parse("'hdeadbeaf", trace: true)
    end

    specify 'multiple underscores can be inserted at any position except for width part and first position' do
      expect(parser).to parse('1_234_567').as(&number_literal(1_234_567))
      expect(parser).to parse('0xdead_beaf').as(&number_literal(0xdeadbeaf))
      expect(parser).to parse("3'b1_0_1").as(&number_literal(0b101, width: 3))
      expect(parser).to parse("10'd1_23").as(&number_literal(123, width: 10))
      expect(parser).to parse("32'hde_ad_be_af", trace: true).as(&number_literal(0xdeadbeaf, width: 32))

      expect(parser).not_to parse('_123', trace: true)
      expect(parser).not_to parse('0x_abcd', trace: true)
      expect(parser).not_to parse("3'b_101", trace: true)
      expect(parser).not_to parse("1_0'b0000000000", trace: true)
      expect(parser).not_to parse("10'd_123", trace: true)
      expect(parser).not_to parse("1_0'd123", trace: true)
      expect(parser).not_to parse("32'h_deadbeaf", trace: true)
      expect(parser).not_to parse("3_2'hdeadbeaf", trace: true)
    end

    specify 'decimal numbers greater than or eual to 10 should not start with 0' do
      expect(parser).not_to parse('010', trace: true)
      expect(parser).not_to parse("10'd0123", trace: true)
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
