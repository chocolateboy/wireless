# frozen_string_literal: true

module Wireless
  class Resolver
    # A dependency resolver which runs its block every time the value is fetched.
    class Factory < Resolver
      # return the dependency provided by the block
      def resolve(fetcher)
        @block.call(fetcher.call)
      end
    end
  end
end
