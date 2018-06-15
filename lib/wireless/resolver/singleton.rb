# frozen_string_literal: true

module Wireless
  class Resolver
    # A dependency resolver which only runs its block the first time the value
    # is read. On subsequent reads, the cached value is returned.
    class Singleton < Resolver
      def initialize(block)
        super(block)
        @lock = Mutex.new
        @seen = false
        @value = nil
      end

      # Resolve the dependency once. On subsequent calls, return the cached
      # version.
      def resolve(fetcher)
        @lock.synchronize do
          unless @seen
            @value = @block.call(fetcher.call)
            @seen = true
          end

          @value
        end
      end
    end
  end
end
