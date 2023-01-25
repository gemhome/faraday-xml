# frozen_string_literal: true

module Faraday
  module XML
    # Utility fucntion that parses XML input.
    class Parser
      def self.build!
        parser = new
        parser.parser!
        parser
      end

      def parse(xml, parser_options = {})
        parser.call(xml, parser_options)
      end

      def parser
        @parser ||= nil
        if @parser.nil?
          @parser = set_parser
          @parser && test_parser
        end
        @parser or raise 'Missing dependencies ActiveSupport::XmlMini or MultiXml'
      end
      alias parser! parser

      def test_parser
        parse('<success>true</success>')
      end

      def set_parser # rubocop:disable Metrics/MethodLength
        @parser ||=
          begin
            require 'multi_xml'
            lambda do |xml, options|
              ::MultiXml.parse(xml, options)
            end
          rescue LoadError # rubocop:disable Lint/SuppressedException
          end
        @parser ||= # rubocop:disable Naming/MemoizedInstanceVariableName
          begin
            require 'active_support'
            require 'active_support/xml_mini'
            require 'active_support/core_ext/hash/conversions'
            require 'active_support/core_ext/array/conversions'
            lambda do |xml, options|
              disallowed_types = options[:disallowed_types]
              Hash.from_xml(xml, disallowed_types)
            end
          rescue LoadError # rubocop:disable Lint/SuppressedException
          end
      end
    end
  end
end
