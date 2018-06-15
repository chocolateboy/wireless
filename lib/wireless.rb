# frozen_string_literal: true

# The Wireless namespace houses the top-level dependency-provider/service-locator
# object (Wireless::Registry) and also exposes a static method, Wireless.new, which
# forwards to and instantiates the registry.
module Wireless
  class Error < StandardError; end
  class CycleError < Error; end
  class NameError < Error; end

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
