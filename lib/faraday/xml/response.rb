# frozen_string_literal: true

require_relative 'parser'

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

      # @param env [Faraday::Env] the environment of the response being processed.
      def on_complete(env)
        process_response(env) if parse_response?(env)
      end

      def parser
        @parser ||= Parser.build!
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

        parser.parse(body, @parser_options || {})
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
