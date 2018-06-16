# frozen_string_literal: true

module Wireless
  # The registry is a key/value store (Hash) whose keys are symbols and whose values
  # are instances of this class. Resolvers are responsible for returning their
  # dependencies, which they do by calling their corresponding blocks. They can wrap
  # additional behaviors around this call e.g. singletons (Wireless::Resolver::Singleton)
  # cache the result so that the block is only called once.
  class Resolver
    def initialize(block = nil)
      if block.respond_to?(:call)
        @block = block
      elsif block.is_a?(Class)
        @block = proc { block.new }
      else
        raise ArgumentError, "invalid argument: expected a block or a class, got: #{block.class}"
      end
    end

    # Abstract method: must be implemented in subclasses
    def resolve(_fetcher)
      raise NotImplementedError, '#resolve is an abstract method'
    end
  end
end
