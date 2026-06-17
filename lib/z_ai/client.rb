# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

require_relative "errors"
require_relative "response"

# Namespace for the Z.ai Ruby SDK.
module ZAI
  # HTTP client for Z.ai API requests.
  class Client
    DEFAULT_BASE_URL = "https://api.z.ai/api/paas/v4"
    DEFAULT_TIMEOUT = 60
    DEFAULT_HEADERS = {
      "Accept" => "application/json",
      "Accept-Language" => "en-US,en",
      "Content-Type" => "application/json"
    }.freeze

    attr_reader :api_key, :base_url, :timeout, :default_headers

    def initialize(api_key: nil, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT, default_headers: {})
      @api_key = (api_key || ENV.fetch("ZAI_API_KEY", nil)).to_s
      @base_url = base_url.to_s.chomp("/")
      @timeout = timeout
      @default_headers = default_headers

      raise ConfigurationError, "Z.ai API key is required" if @api_key.empty?
    end

    def chat(model:, messages:, **params)
      chat_completions(model: model, messages: messages, **params)
    end

    def chat_completions(model:, messages:, **params)
      post("/chat/completions", body: params.merge(model: model, messages: messages))
    end

    private

    def post(path, body:)
      request = build_request(path, body)
      response = perform_request(request.uri, request)

      handle_response(response, parse_response(response))
    rescue JSON::ParserError => e
      raise ParseError, "Unable to parse Z.ai response as JSON: #{e.message}"
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError => e
      raise RequestError, "Unable to complete Z.ai request: #{e.message}"
    end

    def build_request(path, body)
      uri = URI("#{base_url}#{path}")

      Net::HTTP::Post.new(uri, headers).tap do |request|
        request.body = JSON.generate(body)
      end
    end

    def perform_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.open_timeout = timeout
        http.read_timeout = timeout
        http.request(request)
      end
    end

    def headers
      DEFAULT_HEADERS.merge(default_headers).merge("Authorization" => "Bearer #{api_key}")
    end

    def parse_response(response)
      return {} if response.body.to_s.empty?

      JSON.parse(response.body)
    end

    def handle_response(response, parsed_body)
      status = response.code.to_i
      normalized_headers = normalize_headers(response)

      return Response.new(parsed_body, status: status, headers: normalized_headers) if status.between?(200, 299)

      raise api_error_class(status).new(
        error_message(parsed_body, status),
        status: status,
        body: parsed_body,
        headers: normalized_headers
      )
    end

    def normalize_headers(response)
      response.to_hash.transform_values { |values| values.join(", ") }
    end

    def api_error_class(status)
      return AuthenticationError if [401, 403].include?(status)
      return RateLimitError if status == 429
      return ServerError if status >= 500

      APIError
    end

    def error_message(body, status)
      message = api_error_message(body)

      return "Z.ai API request failed with status #{status}" if message.to_s.empty?

      "Z.ai API request failed with status #{status}: #{message}"
    end

    def api_error_message(body)
      return unless body.is_a?(Hash)

      body.dig("error", "message") || body["message"] || body["msg"]
    end
  end
end
