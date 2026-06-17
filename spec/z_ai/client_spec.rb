# frozen_string_literal: true

require "json"

RSpec.describe ZAI::Client do
  let(:api_key) { "test-api-key" }
  let(:client) { described_class.new(api_key: api_key) }
  let(:http) { instance_double(Net::HTTP) }
  let(:messages) { [{ role: "user", content: "Hello" }] }

  before do
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)
    allow(Net::HTTP).to receive(:start).and_yield(http)
  end

  describe "#chat" do
    it "creates a chat completion" do
      expect(http).to receive(:request) do |request|
        payload = JSON.parse(request.body)

        expect(request["Authorization"]).to eq("Bearer #{api_key}")
        expect(request["Content-Type"]).to eq("application/json")
        expect(request.path).to eq("/api/paas/v4/chat/completions")
        expect(payload).to include(
          "model" => "glm-4.7-flash",
          "messages" => [{ "role" => "user", "content" => "Hello" }],
          "temperature" => 0.7
        )

        http_response(
          status: 200,
          body: {
            "id" => "chatcmpl-test",
            "model" => "glm-4.7-flash",
            "choices" => [
              {
                "index" => 0,
                "message" => {
                  "role" => "assistant",
                  "content" => "Hello from Z.ai"
                },
                "finish_reason" => "stop"
              }
            ],
            "usage" => {
              "prompt_tokens" => 4,
              "completion_tokens" => 5,
              "total_tokens" => 9
            }
          }
        )
      end

      response = client.chat(model: "glm-4.7-flash", messages: messages, temperature: 0.7)

      expect(response).to be_a(ZAI::Response)
      expect(response.id).to eq("chatcmpl-test")
      expect(response.model).to eq("glm-4.7-flash")
      expect(response.content).to eq("Hello from Z.ai")
      expect(response.usage).to include("total_tokens" => 9)
    end

    it "raises a configuration error when no API key is provided" do
      expect { described_class.new(api_key: nil) }
        .to raise_error(ZAI::ConfigurationError, "Z.ai API key is required")
    end

    it "raises an authentication error for authentication failures" do
      allow(http).to receive(:request).and_return(
        http_response(status: 401, body: { "error" => { "message" => "Invalid API key" } })
      )

      expect { client.chat(model: "glm-4.7-flash", messages: messages) }
        .to raise_error(ZAI::AuthenticationError, /Invalid API key/)
    end

    it "raises a rate limit error for rate limit responses" do
      allow(http).to receive(:request).and_return(
        http_response(status: 429, body: { "message" => "Too many requests" })
      )

      expect { client.chat(model: "glm-4.7-flash", messages: messages) }
        .to raise_error(ZAI::RateLimitError, /Too many requests/)
    end
  end

  def http_response(status:, body:)
    instance_double(
      Net::HTTPResponse,
      code: status.to_s,
      body: JSON.generate(body),
      to_hash: { "content-type" => ["application/json"] }
    )
  end
end
