# frozen_string_literal: true

module Faraday
  module XML
    # Utility fucntion that encodes input as XML.
    #
    # Doesn't try to encode input which already are in string form.
    class Encoder
      def self.build!(encoder_options = {})
        encoder = new(encoder_options)
        encoder.encoder!
        encoder
      end

      def initialize(encoder_options = {})
        @encoder_options = encoder_options || {}
      end

      def encode(data)
        encoder.call(data)
      end

      def encoder
        @encoder ||= nil
        if @encoder.nil?
          @encoder = set_encoder
          @encoder && test_encoder
        end
        @encoder or raise 'Missing dependencies Builder'
      end
      alias encoder! encoder

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
