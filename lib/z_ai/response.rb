# frozen_string_literal: true

module ZAI
  class Response
    attr_reader :body, :status, :headers

    def initialize(body, status:, headers:)
      @body = body
      @status = status
      @headers = headers
    end

    def [](key)
      body[key.to_s]
    end

    def id
      self["id"]
    end

    def request_id
      self["request_id"]
    end

    def model
      self["model"]
    end

    def choices
      self["choices"] || []
    end

    def usage
      self["usage"] || {}
    end

    def content(index = 0)
      choices.dig(index, "message", "content")
    end
  end
end
