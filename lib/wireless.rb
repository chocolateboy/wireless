# frozen_string_literal: true

# The Wireless namespace houses the top-level dependency-provider/service-locator
# object (Wireless::Registry) and also exposes a static method, Wireless.new, which
# forwards to and instantiates the registry.
module Wireless
  class Error < StandardError; end
  class CycleError < Error; end

  # Raised when an attempt is made to:
  #
  #   - retrieve a value from a key-indexed store when the key doesn't exist
  #   - write a value when the key exists and the store doesn't allow replacements
  #
  # Can be passed a message, the receiver the lookup failed on and the key. All
  # are optional and default to nil.
  #
  # XXX eventually (i.e. in ruby 2.6), this can be a subclass of (or replaced by)
  # the core KeyError class: https://bugs.ruby-lang.org/issues/14313
  class KeyError < Wireless::Error
    def initialize(message = nil, receiver: nil, key: nil)
      super(message)
      @receiver = receiver
      @key = key
    end

    attr_reader :key, :receiver
  end

  # a shortcut which allows:
  #
  #   WL = Wireless::Registry.new do
  #     # ...
  #   end
  #
  # to be written as:
  #
  #   WL = Wireless.new do
  #     # ...
  #   end
  def self.new(*args, &block)
    Wireless::Registry.new(*args, &block)
  end
end

require_relative 'wireless/version'
require_relative 'wireless/resolver'
require_relative 'wireless/resolver/factory'
require_relative 'wireless/resolver/singleton'
require_relative 'wireless/fetch'
require_relative 'wireless/registry'
require_relative 'wireless/fetcher'
