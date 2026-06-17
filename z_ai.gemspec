# frozen_string_literal: true

require_relative "lib/z_ai/version"

Gem::Specification.new do |spec|
  spec.name = "z_ai"
  spec.version = ZAI::VERSION
  spec.authors = ["Faheem Ul Islam"]
  spec.email = ["70851748+faheemKamboh@users.noreply.github.com"]

  spec.summary = "Ruby SDK for Z.ai APIs."
  spec.description = "Ruby SDK for Z.ai APIs, with chat completions, error handling, and response helpers."
  spec.homepage = "https://github.com/faheemKamboh/z_ai-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |file|
      (file == gemspec) || file.start_with?(
        *%w[bin/ Gemfile .devcontainer/ .github/ .gitignore .rspec .rubocop.yml spec/]
      )
    end
  end
  spec.require_paths = ["lib"]
end
