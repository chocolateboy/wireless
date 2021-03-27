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
  spec.license  = 'MIT'

  spec.files = `git ls-files -z *.md bin lib`.split("\0")

  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/chocolateboy/wireless/issues',
    'changelog_uri'     => 'https://github.com/chocolateboy/wireless/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/chocolateboy/wireless',
  }

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'minitest', '~> 5.14'
  spec.add_development_dependency 'minitest-power_assert', '~> 0.3'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.93'
end
