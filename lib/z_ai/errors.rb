# frozen_string_literal: true

# Namespace for the Z.ai Ruby SDK.
module ZAI
  # Base error for all SDK-specific failures.
  class Error < StandardError
    attr_reader :response

    def initialize(message = nil, response: nil)
      @response = response
      super(message)
    end
  end

  # Raised when client configuration is missing or invalid.
  class ConfigurationError < Error; end

  # Raised when the HTTP request cannot be completed.
  class RequestError < Error; end

  # Raised when the API response cannot be parsed as JSON.
  class ParseError < Error; end

  # Raised for non-successful API responses.
  class APIError < Error
    attr_reader :status, :body, :headers

    def initialize(message = nil, status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers
      super(message)
    end
  end

  # Raised for API key failures.
  class AuthenticationError < APIError; end

  # Raised when the API returns a rate-limit response.
  class RateLimitError < APIError; end

  # Raised when the API returns a server-side error response.
  class ServerError < APIError; end
end
