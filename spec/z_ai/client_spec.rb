# frozen_string_literal: true

require "json"

RSpec.describe ZAI::Client do
  let(:api_key) { "test-api-key" }
  let(:client) { described_class.new(api_key: api_key) }
  let(:endpoint) { "https://api.z.ai/api/paas/v4/chat/completions" }
  let(:messages) { [{ role: "user", content: "Hello" }] }

  describe "#chat" do
    it "creates a chat completion" do
      stub_request(:post, endpoint)
        .to_return(
          status: 200,
          body: JSON.generate(
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
          ),
          headers: { "Content-Type" => "application/json" }
        )

      response = client.chat(model: "glm-4.7-flash", messages: messages, temperature: 0.7)

      expect(response).to be_a(ZAI::Response)
      expect(response.id).to eq("chatcmpl-test")
      expect(response.model).to eq("glm-4.7-flash")
      expect(response.content).to eq("Hello from Z.ai")
      expect(response.usage).to include("total_tokens" => 9)

      expect(
        a_request(:post, endpoint).with do |request|
          payload = JSON.parse(request.body)

          request.headers["Authorization"] == "Bearer #{api_key}" &&
            payload["model"] == "glm-4.7-flash" &&
            payload["messages"] == [{ "role" => "user", "content" => "Hello" }] &&
            payload["temperature"] == 0.7
        end
      ).to have_been_made.once
    end

    it "raises a configuration error when no API key is provided" do
      expect { described_class.new(api_key: nil) }
        .to raise_error(ZAI::ConfigurationError, "Z.ai API key is required")
    end

    it "raises an authentication error for authentication failures" do
      stub_request(:post, endpoint)
        .to_return(
          status: 401,
          body: JSON.generate("error" => { "message" => "Invalid API key" }),
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.chat(model: "glm-4.7-flash", messages: messages) }
        .to raise_error(ZAI::AuthenticationError, /Invalid API key/)
    end

    it "raises a rate limit error for rate limit responses" do
      stub_request(:post, endpoint)
        .to_return(
          status: 429,
          body: JSON.generate("message" => "Too many requests"),
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.chat(model: "glm-4.7-flash", messages: messages) }
        .to raise_error(ZAI::RateLimitError, /Too many requests/)
    end
  end
end
