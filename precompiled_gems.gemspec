# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "precompiled_gems"
  spec.version = "0.1.2"
  spec.authors = ["Shopify"]
  spec.email = ["rails@shopify.com"]

  spec.summary = "Speed up Bundler by installing popular gems with precompiled binaries"
  spec.description = <<~MSG
    A bundler plugin that hijacks the resolution to use gems with precompiled binaries instead
    of their original one.

    For example, adding `gem 'bigdecimal'` in your Gemfile, will instead download a different
    gem that is exactly similar to the bigdecimal one but without having to compile it during
    install.

    This project is experimental, use at your own risk
  MSG
  spec.homepage = "https://github.com/shopify/precompiled_gems"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0", "< 4"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shopify/precompiled_gems"

  spec.files = ["plugins.rb", "LICENSE.txt", "CODE_OF_CONDUCT.md", "precompiled_gems.gemspec"] + Dir.glob("lib/**/*")
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]
end
