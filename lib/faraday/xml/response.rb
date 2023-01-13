# frozen_string_literal: true

module Faraday
  module XML
    # Parse response bodies as XML
    class Response < Faraday::Middleware
      def initialize(app = nil, options = {})
        super(app)
        @parser_options = options[:parser_options]
        @content_types = Array(options.fetch(:content_type, /\bxml$/))
        @preserve_raw = options.fetch(:preserve_raw, false)
      end
      ruby2_keywords :initialize if respond_to?(:ruby2_keywords, true)

      # @param env [Faraday::Env] the environment of the response being processed.
      def on_complete(env)
        process_response(env) if parse_response?(env)
      end

      def parser
        @parser ||= nil
        if @parser.nil?
          @parser = set_parser
          @parser && test_parser
        end
        @parser or raise 'Missing dependencies ActiveSupport::XmlMini or MultiXml'
      end

      private

      def process_response(env)
        env[:raw_body] = env[:body] if @preserve_raw
        env[:body] = parse(env[:body])
      rescue StandardError, SyntaxError => e
        raise Faraday::ParsingError.new(e, env[:response])
      end

      def parse(body)
        return nil if body.strip.empty?

        parser.call(body, @parser_options || {})
      end

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

      def parse_response?(env)
        process_response_type?(env) &&
          env[:body].respond_to?(:to_str)
      end

      def process_response_type?(env)
        type = response_type(env)
        @content_types.empty? || @content_types.any? do |pattern|
          pattern.is_a?(Regexp) ? type.match?(pattern) : type == pattern
        end
      end

      def response_type(env)
        type = env[:response_headers][CONTENT_TYPE].to_s
        type = type.split(';', 2).first if type.index(';')
        type
      end
    end
  end
end
