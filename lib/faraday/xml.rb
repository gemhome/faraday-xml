# frozen_string_literal: true

require_relative 'xml/request'
require_relative 'xml/response'
require_relative 'xml/version'

module Faraday
  # The Faraday::XML middleware main module
  module XML
    # Load middleware with
    #   conn.use Faraday::XML::Request
    #   or
    #   conn.request :xml
    Faraday::Request.register_middleware(xml: Faraday::XML::Request)
    # Load middleware with
    #   conn.use Faraday::XML::Response
    #   or
    #   conn.response :xml
    Faraday::Response.register_middleware(xml: Faraday::XML::Response)
  end
end
