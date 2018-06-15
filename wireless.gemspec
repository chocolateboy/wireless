# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wireless/version'

Gem::Specification.new do |spec|
  spec.name     = 'wireless'
  spec.version  = Wireless::VERSION
  spec.author   = 'chocolateboy'
  spec.email    = 'chocolate@cpan.org'
  spec.summary  = 'A lightweight, declarative dependency-provider'
  spec.homepage = 'https://github.com/chocolateboy/wireless'
  spec.license  = 'Artistic-2.0'

  spec.files = `git ls-files -z *.md bin lib`.split("\0")
  spec.require_paths = %w[lib]

  # spec.required_ruby_version = '>= 2.3.0'

  spec.metadata = {
    'allowed_push_host' => 'http://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/chocolateboy/wireless/issues',
    'changelog_uri'     => 'https://github.com/chocolateboy/wireless/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/chocolateboy/wireless',
  }

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'minitest-power_assert', '~> 0.3.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'
end
