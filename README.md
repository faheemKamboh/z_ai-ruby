# ZAI

Ruby SDK for Z.ai APIs.

This project is an unofficial Ruby SDK for Z.ai and is not affiliated with or endorsed by Z.ai.

## Installation

Install the gem and add it to your application's Gemfile by executing:

```bash
bundle add z_ai
```

Or add it manually:

```ruby
gem "z_ai"
```

## Usage

Set your API key:

```bash
export ZAI_API_KEY="your-api-key"
```

Create a chat completion:

```ruby
require "z_ai"

client = ZAI::Client.new

response = client.chat(
  model: "glm-4.7-flash",
  messages: [
    { role: "user", content: "Explain RAG in three lines." }
  ]
)

puts response.content
puts response.usage
```

You can also pass the API key directly:

```ruby
client = ZAI::Client.new(api_key: "your-api-key")
```

## Development

After checking out the repo, run:

```bash
bin/setup
bundle exec rake
```

The default task runs specs and RuboCop.

## Roadmap

- Chat completions
- Streaming responses
- Tool/function calling helpers
- JSON response helpers
- Rails-friendly configuration

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/faheemKamboh/z_ai-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
