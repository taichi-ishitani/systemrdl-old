# frozen_string_literal: true

module SystemRDL
  module Node
    class Identifier
      def initialize(slice)
        @slice = slice
        non_escaped_identifier? && validate
      end

      def to_s
        @slice.str
      end

      def position
        @slice.position
      end

      def identifier
        to_s
      end

      def non_escaped_identifier?
        !escaped_identifier?
      end

      def escaped_identifier?
        to_s.start_with?('\\')
      end

      private

      KEYWORDS = [
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
        'type', 'unsigned', 'w', 'w1', 'wclr',
        'woclr', 'woset', 'wot', 'wr', 'wset',
        'wuser', 'wzc', 'wzs', 'wzt'
      ].freeze

      RESERVED_WORDS = [
        'alternate', 'byte', 'int', 'precedencetype', 'real',
        'shortint', 'shortreal', 'signed', 'with', 'within'
      ].freeze

      def validate
        KEYWORDS.any?(identifier) &&
          Parslet::Cause.format(
            @slice.line_cache, @slice.position.bytepos,
            "keywords cannot be used for identifiers: #{identifier}"
          ).raise
        RESERVED_WORDS.any?(identifier) &&
          Parslet::Cause.format(
            @slice.line_cache, @slice.position.bytepos,
            "reserved words cannot be used for identifiers: #{identifier}"
          ).raise
      end
    end
  end
end
