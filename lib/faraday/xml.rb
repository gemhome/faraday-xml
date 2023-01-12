# frozen_string_literal: true

require_relative 'xml/middleware'
require_relative 'xml/version'

module Faraday
  # This will be your middleware main module, though the actual middleware implementation will go
  # into Faraday::XML::Middleware for the correct namespacing.
  module XML
    # Faraday allows you to register your middleware for easier configuration.
    # This step is totally optional, but it basically allows users to use a
    # custom symbol (in this case, `:xml`), to use your middleware in their connections.
    # After calling this line, the following are both valid ways to set the middleware in a connection:
    # * conn.use Faraday::XML::Middleware
    # * conn.use :xml
    # Without this line, only the former method is valid.
    Faraday::Middleware.register_middleware(xml: Faraday::XML::Middleware)

    # Alternatively, you can register your middleware under Faraday::Request or Faraday::Response.
    # This will allow to load your middleware using the `request` or `response` methods respectively.
    #
    # Load middleware with conn.request :xml
    # Faraday::Request.register_middleware(xml: Faraday::XML::Middleware)
    #
    # Load middleware with conn.response :xml
    # Faraday::Response.register_middleware(xml: Faraday::XML::Middleware)
  end
end
