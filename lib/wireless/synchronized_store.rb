# frozen_string_literal: true

module Wireless
  # A Hash wrapper which synchronizes get ([]), set ([]=) and include? methods.
  # Implemented as a wrapper rather than a subclass so we don't have to worry about
  # every possible mutator.
  class SynchronizedStore
    def initialize
      @store = {}
      @lock = Mutex.new
    end

    # Retrieve a new value from the underlying hash in a thread-safe way
    def [](key)
      @lock.synchronize { @store[key] }
    end

    # Assign a new value to the underlying hash in a thread-safe way
    def []=(key, value)
      @lock.synchronize do
        if @store.include?(key)
          raise Wireless::NameError, "resolver already exists: #{key}"
        end

        @store[key] = value
      end
    end

    # Returns true if the underlying hash contains the key, false otherwise
    def include?(key)
      @lock.synchronize { @store.include?(key) }
    end
  end
end
