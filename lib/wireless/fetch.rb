# frozen_string_literal: true

module Wireless
  # A mixin which provides the #fetch method (and #[] alias) shared by Wireless::Registry
  # and the cut-down version, Wireless::Fetcher, which is passed to the blocks used
  # to resolve dependencies.
  #
  # In both cases, @registry and @seen need to be defined as instance variables.
  # @registry is a hash of { name (Symbol) => dependency (Object) } pairs, and
  # @seen is an immutable Set of symbols, which is used to detect dependency cycles.
  module Fetch
    # Fetches the dependency with the specified name. Creates the dependency if
    # it doesn't exist. Raises a Wireless::KeyError if the dependency is not
    # defined or a Wireless::CycleError if resolving the dependency results in
    # a cycle.
    def fetch(name)
      name = name.to_sym

      if @seen.include?(name)
        path = [*@seen, name].join(' -> ')
        raise Wireless::CycleError, "cycle detected: #{path}"
      end

      unless (resolver = @registry[name])
        raise Wireless::KeyError.new(
          "dependency not found: #{name}",
          key: name,
          receiver: self
        )
      end

      fetcher = lambda do
        seen = @seen.dup
        seen.add(name)
        Fetcher.new(registry: @registry, seen: seen)
      end

      resolver.resolve(fetcher)
    end

    alias [] fetch
  end
end
