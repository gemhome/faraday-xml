# frozen_string_literal: true

module Faraday
  module XML
    # Request middleware that encodes the body as XML.
    #
    # Processes only requests with matching Content-type or those without a type.
    # If a request doesn't have a type but has a body, it sets the Content-type
    # to XML MIME-type.
    #
    # Doesn't try to encode bodies that already are in string form.
    class Request < Middleware # rubocop:disable Metrics/ClassLength
      MIME_TYPE = 'application/xml'
      MIME_TYPE_REGEX = %r{^application/(vnd\..+\+)?xml$}.freeze

      def initialize(app = nil, options = {})
        super(app)
        @encoder_options = options.fetch(:encoder_options, {})
      end

      def on_request(env)
        match_content_type(env) do |data|
          env[:body] = encode(data)
        end
      end

      def encoder
        @encoder ||= nil
        if @encoder.nil?
          @encoder = set_encoder
          @encoder && test_encoder
        end
        @encoder or raise 'Missing dependencies Builder'
      end

      private

      def encode(data)
        encoder.call(data)
      end

      def test_encoder
        encode({ success: true })
      end

      def set_encoder
        @encoder ||= # rubocop:disable Naming/MemoizedInstanceVariableName
          begin
            require 'builder'
            lambda do |parameter_hash|
              parameters_as_xml(parameter_hash)
            end
          rescue LoadError # rubocop:disable Lint/SuppressedException
          end
      end

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

      def parameters_as_xml(parameter_hash) # rubocop:disable Metrics/MethodLength
        xml_markup = build_xml_markup(skip_instruct: true)
        parameter_hash.each_pair do |key, value|
          key = key.to_s
          if _parameter_as_xml?(value)
            xml_markup.tag!(key) do
              xml = _parameter_as_xml(value)
              xml_markup << xml
            end
          else
            xml_markup.tag!(key, _parameter_as_xml(value))
          end
        end
        xml_markup.target!
      end

      def _parameter_as_xml?(value)
        case value
        when Hash, Array then true
        else false
        end
      end

      def _parameter_as_xml(value)
        case value
        when Hash
          parameters_as_xml(value) # recursive case
        when Array
          _parameter_as_list_xml(value) # recursive case
        else
          value.to_s.encode(xml: :text) # end case
        end
      end

      def _parameter_as_list_xml(array_of_hashes)
        xml_markup = build_xml_markup(skip_instruct: true)
        array_of_hashes.each do |value|
          xml_markup << parameters_as_xml(value) # recursive case
        end
        xml_markup.target!
      end

      def build_xml_markup(**options)
        # https://github.com/rails/rails/blob/86fd8d0143b1a0578b359f4b86fea94c718139ae/activesupport/lib/active_support/builder.rb
        # https://github.com/rails/rails/blob/86fd8d0143b1a0578b359f4b86fea94c718139ae/activesupport/lib/active_support/core_ext/hash/conversions.rb
        require 'builder'
        options.merge!(@encoder_options)
        options[:indent] = 2 unless options.key?(:indent)
        xml_markup = ::Builder::XmlMarkup.new(**options)
        if !options.delete(:skip_instruct) # rubocop:disable Style/NegatedIf
          xml_markup.instruct! :xml, version: '1.0', encoding: 'UTF-8'
        end
        xml_markup
      end
    end
  end
end
