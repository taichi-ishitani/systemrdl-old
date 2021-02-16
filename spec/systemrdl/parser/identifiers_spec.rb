# frozen_string_literal: true

RSpec.describe 'parser/identifiers' do
  let(:parser) do
    SystemRDL::Parser.new(:id)
  end

  let(:keywords) do
    [
      'abstract', 'accesstype', 'addressingtype', 'addrmap', 'alias',
      'all', 'bit', 'boolean', 'bothedge', 'compact',
      'component', 'componentwidth', 'constraint', 'default', 'encode',
      'enum', 'external', 'false', 'field', 'fullalign',
      'hw', 'inside', 'internal', 'level', 'longint',
      'mem', 'na', 'negedge', 'nonsticky', 'number',
      'onreadtype', 'onwritetype', 'posedge', 'property', 'r',
      'rclr', 'ref', 'reg', 'regalign', 'regfile',
      'rset', 'ruser', 'rw', 'rw1', 'signal',
      'string', 'struct', 'sw', 'this', 'true',
      'type', 'unsigned',  'w', 'w1', 'wclr',
      'woclr', 'woset', 'wot', 'wr', 'wset', 'wuser', 'wzc', 'wzs', 'wzt'
    ]
  end

  let(:reserved_words) do
    [
      'alternate', 'byte', 'int', 'precedencetype', 'real',
      'shortint', 'shortreal', 'signed', 'with', 'within'
    ]
  end

  let(:illegal_characters) do
    [
      ' ', '!', '"', '#', '$', '%', '&', "'", '(', ')',
      '*', '+', ',', '-', '.', '/', ':', ';', '<', '=',
      '>', '?', '@', '[', '\\', ']', '^', '`', '{',
      '|', '}', '~', 'あ', '＿', 'Ａ', 'ｂ'
    ]
  end

  describe 'non escaped identifiers' do
    it 'should be parsed by :id parser' do
      [
        'my_identifier', 'My_IdEnTiFiEr' 'x',
        '_', '_y0123', '_3'
      ].each do |id|
        expect(parser).to parse(id, trace: true).as(&identifier(id))
      end
    end

    it 'cannot start with a digit' do
      ['0', '1a', '2_'].each do |id|
        expect(parser).not_to parse(id, trace: true)
      end
    end

    it 'cannot contain any characters except for ASCII letter, digit and underscore' do
      illegal_characters.each do |character|
        [character, "_#{character}", "#{character}_"].grep_v('\\_').each do |id|
          expect(parser).not_to parse(id, trace: true)
        end
      end
    end

    specify 'keywords cannot be used as non escaped identifiers' do
      keywords.each do |keyword|
        expect(parser).not_to parse(keyword, trace: true)
      end
    end

    specify 'keywords can be used as parts of non escaped identifiers' do
      keywords.each do |keyword|
        ["#{keyword}_", "_#{keyword}"].each do |id|
          expect(parser).to parse(id, trace: true).as(&identifier(id))
        end
      end
    end

    specify 'resreved words cannot be used as non escaped identifiers' do
      reserved_words.each do |reserved_word|
        expect(parser).not_to parse(reserved_word, trace: true)
      end
    end

    specify 'resreved words can be used as parts of non escaped identifiers' do
      reserved_words.each do |reserved_word|
        ["#{reserved_word}_", "_#{reserved_word}"].each do |id|
          expect(parser).to parse(id, trace: true).as(&identifier(id))
        end
      end
    end
  end

  describe 'escaped identifiers' do
    it 'should be parsed by :id parser' do
      [
        '\my_identifier', '\My_IdEnTiFiEr', '\x',
        '\_', '\_y0123', '\_3'
      ].each do |id|
        expect(parser).to parse(id, trace: true).as(&identifier(id))
      end
    end

    specify 'second character should not be disit' do
      ['\0', '\1a', '\2_'].each do |id|
        expect(parser).not_to parse(id, trace: true)
      end
    end

    it 'cannot contain any characters except for ASCII letter, digit and underscore' do
      illegal_characters.each do |character|
        ["\\#{character}", "\\_#{character}", "\\#{character}_"].each do |id|
          expect(parser).not_to parse(id, trace: true)
        end
      end
    end

    specify 'keywords can be used as escaped identifiers' do
      keywords.each do |keyword|
        id = "\\#{keyword}"
        expect(parser).to parse(id, trace: true).as(&identifier(id))
      end
    end

    specify 'resreved words can be used as escaped identifiers' do
      reserved_words.each do |reserved_word|
        id = "\\#{reserved_word}"
        expect(parser).to parse(id, trace: true).as(&identifier(id))
      end
    end
  end
end
