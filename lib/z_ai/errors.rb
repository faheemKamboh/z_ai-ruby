# frozen_string_literal: true

module ZAI
  class Error < StandardError
    attr_reader :response

    def initialize(message = nil, response: nil)
      @response = response
      super(message)
    end
  end

  class ConfigurationError < Error; end

  class RequestError < Error; end

  class ParseError < Error; end

  class APIError < Error
    attr_reader :status, :body, :headers

    def initialize(message = nil, status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers
      super(message)
    end
  end

  class AuthenticationError < APIError; end

  class RateLimitError < APIError; end

  class ServerError < APIError; end
end
