# frozen_string_literal: true

module Wireless
  # The object passed to the factory (`on`) or singleton (`once`) block:
  # a cut-down version of Wireless::Registry which only provides read access
  # (via #fetch or its #[] alias) to the underlying dependency store
  class Fetcher
    include Fetch

    def initialize(registry:, seen:)
      @registry = registry
      @seen = seen
    end
  end
end
