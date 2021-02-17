# frozen_string_literal: true

RSpec.describe 'parser/concatenation' do
  describe 'constant concatenation' do
    let(:parser) do
      SystemRDL::Parser.new(:constant_concatenation)
    end

    it 'should be parsed by :constant_concatenation parser' do
      expect(parser).to parse('{1}', trace: true).as(&concatenation([1]))
      expect(parser).to parse('{1,2,3}', trace: true).as(&concatenation([1, 2, 3]))
    end

    it 'should need one expression at least' do
      expect(parser).not_to parse('{}', trace: true)
    end
  end

  describe 'constant multiple concatenation' do
    let(:parser) do
      SystemRDL::Parser.new(:constant_multiple_concatenation)
    end

    it 'should be parsed by :constant_multiple_concatenation parser' do
      expect(parser).to parse('{1{2}}', trace: true).as(&multiple_concatenation(1, [2]))
      expect(parser).to parse('{1{2,3,4}}', trace: true).as(&multiple_concatenation(1, [2, 3, 4]))
    end
  end
end
