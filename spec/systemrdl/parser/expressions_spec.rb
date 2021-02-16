# frozen_string_literal: true

RSpec.describe 'parser/expressions' do
  let(:parser) do
    SystemRDL::Parser.new(:constant_expression)
  end

  def constant_expression(expression)
    lambda do |result|
      match_expression(result, expression)
    end
  end

  def match_expression(actual, expectation)
    case expectation[0]
    when :unary then match_unary_operation(actual, expectation)
    when :binary then match_binary_operation(actual, expectation)
    when :ternary then match_ternary_operation(actual, expectation)
    else false
    end
  end

  def match_unary_operation(actual, expectation)
    actual.operator == expectation[1] &&
      match_operand(actual.operand, expectation[2])
  end

  def match_binary_operation(actual, expectation)
    actual.operator == expectation[1] &&
      match_operand(actual.left, expectation[2]) &&
      match_operand(actual.right, expectation[3])
  end

  def match_ternary_operation(actual, expectation)
    actual.operator == expectation[1] &&
      match_operand(actual.first, expectation[2]) &&
      match_operand(actual.second, expectation[3]) &&
      match_operand(actual.third, expectation[4])
  end

  def match_operand(actual, expectation)
    if expectation.is_a?(Array)
      match_expression(actual, expectation)
    else
      actual == expectation
    end
  end

  describe 'constant literals' do
    specify 'number literals should be treated as constant expressions' do
      expect(parser).to parse('123', trace: true)
        .as(&number_literal(123))
      expect(parser).to parse('0xabcd', trace: true)
        .as(&number_literal(0xabcd))
      expect(parser).to parse("4'b1010", trace: true)
        .as(&number_literal(0b1010, width: 4))
      expect(parser).to parse("7'd123", trace: true)
        .as(&number_literal(123, width: 7))
      expect(parser).to parse("16'habcd", trace: true)
        .as(&number_literal(0xabcd, width: 16))
    end

    specify 'string literals should be treated as constant expressions' do
      expect(parser).to parse('"this is a test."', trace: true)
        .as(&literal(:string, 'this is a test.'))
    end

    specify 'boolean literals should be treated as constant expressions' do
      expect(parser).to parse('true', trace: true)
        .as(&literal(:boolean, true))
      expect(parser).to parse('false', trace: true)
        .as(&literal(:boolean, false))
    end

    specify 'accesstype literals should be treated as constant expressions' do
      ['na', 'rw', 'wr', 'r', 'w', 'rw1', 'w1'].each do |accesstype|
        expect(parser).to parse(accesstype, trace: true)
          .as(&literal(:accesstype, accesstype.to_sym))
      end
    end

    specify 'onreadtype literals should be treated as constant expressions' do
      ['rclr', 'rset', 'ruser'].each do |onreadtype|
        expect(parser).to parse(onreadtype, trace: true)
          .as(&literal(:onreadtype, onreadtype.to_sym))
      end
    end

    specify 'onwritetype literals should be treated as constant expressions' do
      ['woset', 'woclr', 'wot', 'wzs', 'wzc', 'wzt', 'wclr', 'wset', 'wuser'].each do |onwritetype|
        expect(parser).to parse(onwritetype, trace: true)
          .as(&literal(:onwritetype, onwritetype.to_sym))
      end
    end

    specify 'addressingtype literals should be treated as constant expressions' do
      ['compact', 'regalign', 'fullalign'].each do |addressingtype|
        expect(parser).to parse(addressingtype, trace: true)
          .as(&literal(:addressingtype, addressingtype.to_sym))
      end
    end

    specify 'enumerator literals should be treated as constant expressions' do
      expect(parser).to parse('foo::bar', trace: true)
        .as(&enumerator_literal('foo', 'bar'))
      expect(parser).to parse('baz::qux', trace: true)
        .as(&enumerator_literal('baz', 'qux'))
    end

    specify "'this' keyword should be treated as a constant expression" do
      expect(parser).to parse('this', trace: true)
        .as(&identifier('this'))
    end
  end

  describe 'unary operations' do
    it 'should be parsed by :constant_expression parser' do
      expect(parser).to parse('!true', trace: true)
        .as(&constant_expression([:unary, :'!', true]))
      expect(parser).to parse("+8'hab", trace: true)
        .as(&constant_expression([:unary, :'+', 0xab]))
      expect(parser).to parse("-8'hab", trace: true)
        .as(&constant_expression([:unary, :'-', 0xab]))
      expect(parser).to parse("~8'hab", trace: true)
        .as(&constant_expression([:unary, :'~', 0xab]))
      expect(parser).to parse("&8'hab", trace: true)
        .as(&constant_expression([:unary, :'&', 0xab]))
      expect(parser).to parse("~&8'hab", trace: true)
        .as(&constant_expression([:unary, :'~&', 0xab]))
      expect(parser).to parse("|8'hab", trace: true)
        .as(&constant_expression([:unary, :'|', 0xab]))
      expect(parser).to parse("~|8'hab", trace: true)
        .as(&constant_expression([:unary, :'~|', 0xab]))
      expect(parser).to parse("^8'hab", trace: true)
        .as(&constant_expression([:unary, :'^', 0xab]))
      expect(parser).to parse("~^8'hab", trace: true)
        .as(&constant_expression([:unary, :'~^', 0xab]))
      expect(parser).to parse("^~8'hab", trace: true)
        .as(&constant_expression([:unary, :'^~', 0xab]))
    end
  end

  describe 'binary operation' do
    it 'should be parsed by :constant_expression parser' do
      expect(parser).to parse('true&&true', trace: true)
        .as(&constant_expression([:binary, :'&&', true, true]))
      expect(parser).to parse('true||true', trace: true)
        .as(&constant_expression([:binary, :'||', true, true]))
      expect(parser).to parse('123<456', trace: true)
        .as(&constant_expression([:binary, :'<', 123, 456]))
      expect(parser).to parse('123>456', trace: true)
        .as(&constant_expression([:binary, :'>', 123, 456]))
      expect(parser).to parse('123<=456', trace: true)
        .as(&constant_expression([:binary, :'<=', 123, 456]))
      expect(parser).to parse('123>=456', trace: true)
        .as(&constant_expression([:binary, :'>=', 123, 456]))
      expect(parser).to parse('123==456', trace: true)
        .as(&constant_expression([:binary, :'==', 123, 456]))
      expect(parser).to parse('123!=456', trace: true)
        .as(&constant_expression([:binary, :'!=', 123, 456]))
      expect(parser).to parse('123>>1', trace: true)
        .as(&constant_expression([:binary, :'>>', 123, 1]))
      expect(parser).to parse('123<<1', trace: true)
        .as(&constant_expression([:binary, :'<<', 123, 1]))
      expect(parser).to parse("8'hab&8'h11", trace: true)
        .as(&constant_expression([:binary, :'&', 0xab, 0x11]))
      expect(parser).to parse("8'hab|8'h11", trace: true)
        .as(&constant_expression([:binary, :'|', 0xab, 0x11]))
      expect(parser).to parse("8'hab^8'h11", trace: true)
        .as(&constant_expression([:binary, :'^', 0xab, 0x11]))
      expect(parser).to parse("8'hab~^8'h11", trace: true)
        .as(&constant_expression([:binary, :'~^', 0xab, 0x11]))
      expect(parser).to parse("8'hab^~8'h11", trace: true)
        .as(&constant_expression([:binary, :'^~', 0xab, 0x11]))
      expect(parser).to parse('123*456', trace: true)
        .as(&constant_expression([:binary, :'*', 123, 456]))
      expect(parser).to parse('123/456', trace: true)
        .as(&constant_expression([:binary, :'/', 123, 456]))
      expect(parser).to parse('123%456', trace: true)
        .as(&constant_expression([:binary, :'%', 123, 456]))
      expect(parser).to parse('123+456', trace: true)
        .as(&constant_expression([:binary, :'+', 123, 456]))
      expect(parser).to parse('123-456', trace: true)
        .as(&constant_expression([:binary, :'-', 123, 456]))
      expect(parser).to parse('123**456', trace: true)
        .as(&constant_expression([:binary, :'**', 123, 456]))
    end
  end

  describe 'conditional operation' do
    it 'should be parsed by :constant_expression parser' do
      expect(parser).to parse('1?2:3', trace: true)
        .as(&constant_expression([:ternary, :'?', 1, 2, 3]))
      expect(parser).to parse('1?2:3?4:5', trace: true)
        .as(&constant_expression([:ternary, :'?', 1, 2, [:ternary, :'?', 3, 4, 5]]))
      expect(parser).to parse('1?2?3:4:5?6:7', trace: true)
        .as(&constant_expression([:ternary, :'?', 1, [:ternary, :'?', 2, 3, 4], [:ternary, :'?', 5, 6, 7]]))
    end
  end

  specify 'oparator precedence is listed in Table 11-2 on IEEE1800-2012' do
    expect(parser).to parse('+1**2', trace: true)
      .as(&constant_expression([:binary, :'**', [:unary, :'+', 1], 2]))
    expect(parser).to parse('+(1**2)', trace: true)
      .as(&constant_expression([:unary, :'+', [:binary, :'**', 1, 2]]))
    expect(parser).to parse('1*2**3', trace: true)
      .as(&constant_expression([:binary, :'*', 1, [:binary, :'**', 2, 3]]))
    expect(parser).to parse('(1*2)**3', trace: true)
      .as(&constant_expression([:binary, :'**', [:binary, :'*', 1, 2], 3]))
    expect(parser).to parse('1+2*3', trace: true)
      .as(&constant_expression([:binary, :'+', 1, [:binary, :'*', 2, 3]]))
    expect(parser).to parse('(1+2)*3', trace: true)
      .as(&constant_expression([:binary, :'*', [:binary, :'+', 1, 2], 3]))
    expect(parser).to parse('1<<2+3', trace: true)
      .as(&constant_expression([:binary, :'<<', 1, [:binary, :'+', 2, 3]]))
    expect(parser).to parse('(1<<2)+3', trace: true)
      .as(&constant_expression([:binary, :'+', [:binary, :'<<', 1, 2], 3]))
    expect(parser).to parse('1<2<<3', trace: true)
      .as(&constant_expression([:binary, :'<', 1, [:binary, :'<<', 2, 3]]))
    expect(parser).to parse('(1<2)<<3', trace: true)
      .as(&constant_expression([:binary, :'<<', [:binary, :'<', 1, 2], 3]))
    expect(parser).to parse('1==2<3', trace: true)
      .as(&constant_expression([:binary, :'==', 1, [:binary, :'<', 2, 3]]))
    expect(parser).to parse('(1==2)<3', trace: true)
      .as(&constant_expression([:binary, :'<', [:binary, :'==', 1, 2], 3]))
    expect(parser).to parse('1&2==3', trace: true)
      .as(&constant_expression([:binary, :'&', 1, [:binary, :'==', 2, 3]]))
    expect(parser).to parse('(1&2)==3', trace: true)
      .as(&constant_expression([:binary, :'==', [:binary, :'&', 1, 2], 3]))
    expect(parser).to parse('1^2&3', trace: true)
      .as(&constant_expression([:binary, :'^', 1, [:binary, :'&', 2, 3]]))
    expect(parser).to parse('(1^2)&3', trace: true)
      .as(&constant_expression([:binary, :'&', [:binary, :'^', 1, 2], 3]))
    expect(parser).to parse('1|2^3', trace: true)
      .as(&constant_expression([:binary, :'|', 1, [:binary, :'^', 2, 3]]))
    expect(parser).to parse('(1|2)^3', trace: true)
      .as(&constant_expression([:binary, :'^', [:binary, :'|', 1, 2], 3]))
    expect(parser).to parse('1&&2|3', trace: true)
      .as(&constant_expression([:binary, :'&&', 1, [:binary, :'|', 2, 3]]))
    expect(parser).to parse('(1&&2)|3', trace: true)
      .as(&constant_expression([:binary, :'|', [:binary, :'&&', 1, 2], 3]))
    expect(parser).to parse('1||2&&3', trace: true)
      .as(&constant_expression([:binary, :'||', 1, [:binary, :'&&', 2, 3]]))
    expect(parser).to parse('(1||2)&&3', trace: true)
      .as(&constant_expression([:binary, :'&&', [:binary, :'||', 1, 2], 3]))
    expect(parser).to parse('1||2?3:4', trace: true)
      .as(&constant_expression([:ternary, :'?', [:binary, :'||', 1, 2], 3, 4]))
    expect(parser).to parse('1||(2?3:4)', trace: true)
      .as(&constant_expression([:binary, :'||', 1, [:ternary, :'?', 2, 3, 4]]))
  end
end
