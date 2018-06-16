# frozen_string_literal: true

module Wireless
  # A Hash wrapper with synchronized get, set and check methods.
  class SynchronizedStore
    def initialize(store = {}, replace: false, type: :key)
      @type = type
      @replace = replace
      @store = store
      @lock = Mutex.new
    end

    # Retrieve a value from the store
    #
    # A synchronized version of:
    #
    #   store[key]
    #
    def [](key)
      @lock.synchronize { @store[key] }
    end

    # Add a key/value to the store
    #
    # A synchronized version of:
    #
    #   store[key] = value
    #
    def []=(key, value)
      @lock.synchronize do
        if !@replace && @store.include?(key)
          # XXX don't expose the receiver as this class is an internal
          # implementation detail
          raise Wireless::KeyError.new(
            "#{@type} already exists: #{key}",
            key: key
          )
        end

        @store[key] = value
      end
    end

    # Retrieve a value from the store. If it doesn't exist and a block is
    # supplied, create and return it; otherwise, raise a KeyError.
    #
    # A synchronized version of:
    #
    #   store[key] ||= value
    #
    def get_or_create(key)
      @lock.synchronize do
        if @store.include?(key)
          @store[key]
        elsif block_given?
          @store[key] = yield
        else
          # XXX don't expose the receiver as this class is an internal
          # implementation detail
          raise Wireless::KeyError.new(
            "#{@type} not found: #{key}",
            key: key
          )
        end
      end
    end

    alias get! get_or_create

    # Returns true if the store contains the key, false otherwise
    #
    # A synchronized version of:
    #
    #   store.include?(key)
    #
    def include?(key)
      @lock.synchronize { @store.include?(key) }
    end
  end
end
