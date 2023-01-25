# frozen_string_literal: true

require_relative 'encoder'

module Faraday
  module XML
    # Request middleware that encodes the body as XML.
    #
    # Processes only requests with matching Content-type or those without a type.
    # If a request doesn't have a type but has a body, it sets the Content-type
    # to XML MIME-type.
    #
    # Doesn't try to encode bodies that already are in string form.
    class Request < Middleware
      MIME_TYPE = 'application/xml'
      MIME_TYPE_REGEX = %r{^application/(vnd\..+\+)?xml$}.freeze

      def initialize(app = nil, options = {})
        super(app)
        @encoder_options = options.fetch(:encoder_options, {})
      end

      def on_request(env)
        match_content_type(env) do |data|
          env[:body] = encoder.encode(data)
        end
      end

      def encoder
        @encoder ||= Encoder.build!(@encoder_options)
      end

      private

      def match_content_type(env)
        return unless process_request?(env)

        env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
        yield env[:body] unless env[:body].respond_to?(:to_str)
      end

      def process_request?(env)
        type = request_type(env)
        body?(env) && (type.empty? || type.match?(MIME_TYPE_REGEX))
      end

      def body?(env)
        (body = env[:body]) && !(body.respond_to?(:to_str) && body.empty?)
      end

      def request_type(env)
        type = env[:request_headers][CONTENT_TYPE].to_s
        type = type.split(';', 2).first if type.index(';')
        type
      end
    end
  end
end
