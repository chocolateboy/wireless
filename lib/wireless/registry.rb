# frozen_string_literal: true

require 'set'
require_relative 'synchronized_store'

module Wireless
  # The hash-like object which is the public API of the dependency provider
  # (AKA service locator). It maps names (symbols) to dependencies (objects) via blocks
  # which resolve the dependency either every time (factory) or once (singleton).
  #
  # The block can be supplied as a class, in which case it is equivalent to a block
  # which calls +new+ on the class e.g.:
  #
  #   WL = Wireless.new do
  #     on(:foo, Foo)
  #   end
  #
  # is equivalent to:
  #
  #   WL = Wireless.new do
  #     on(:foo) { Foo.new }
  #   end
  class Registry
    DEFAULT_EXPORTS = { private: [], protected: [], public: [] }
    DEFAULT_VISIBILITY = :private

    include Fetch

    def initialize(args = DEFAULT_VISIBILITY, &block)
      @default_visibility = args
      @module_cache = {}
      @registry = SynchronizedStore.new
      @seen = Set.new
      instance_eval(&block) if block
    end

    # Registers a dependency which is resolved every time its value is fetched.
    def factory(name, klass = nil, &block)
      register(Resolver::Factory, name, block || klass)
    end

    # Returns true if a service with the specified name has been registered, false
    # otherwise
    def include?(key)
      @registry.include?(key)
    end

    # Registers a dependency which is only resolved the first time its value is
    # fetched. On subsequent fetches, the cached value is returned.
    def singleton(name, klass = nil, &block)
      register(Resolver::Singleton, name, block || klass)
    end

    # Takes an array or hash specifying the dependencies to export, and returns
    # a module which exposes those dependencies as getters.
    #
    #   class Test
    #     # hash (specify visibilities)
    #     include Services.mixin private: :foo, protected: %i[bar baz], public: :quux
    #
    #     # or an array of imports using the default visibility (:private by default)
    #     include Services.mixin %i[foo bar baz quux]
    #
    #     def test
    #       foo + bar + baz + quux # access the dependencies
    #     end
    #   end
    #
    # The visibility of the generated getters can be controlled by passing a hash
    # with { visibility => imports } pairs, where imports is an array of import
    # specifiers. An import specifier is a symbol (method name == dependency name)
    # or a hash with { dependency_name => method_name } pairs (aliases). If
    # there's only one import specifier, its enclosing array can be omitted e.g.:
    #
    #   include Services.mixin(private: :foo, protected: { :baz => :quux })
    #
    # is equivalent to:
    #
    #   include Services.mixin(private: [:foo], protected: [{ :baz => :quux }])
    #
    def mixin(args)
      # normalize the supplied argument (array or hash) into a hash of
      # { visibility => exports } pairs, where `visibility` is a symbol and
      # `exports` is a hash of { dependency_name => method_name } pairs
      if args.is_a?(Array)
        args = { @default_visibility => args }
      elsif !args.is_a?(Hash)
        raise ArgumentError, "invalid mixin argument: expected array or hash, got: #{args.class}"
      end

      # slurp each array of name (symbol) or alias (hash) imports into a
      # normalized hash of { dependency_name => method_name } pairs
      args = DEFAULT_EXPORTS.merge(args).transform_values do |exports|
        Array(exports).reduce({}) do |a, b|
          a.merge(b.is_a?(Hash) ? b : { b => b })
        end
      end

      @module_cache[args] ||= module_for(args)
    end

    alias on factory
    alias once singleton

    private

    # Create a module with the specified exports
    def module_for(args)
      registry = self
      mod = Module.new

      args.each do |visibility, exports|
        exports.each do |dependency_name, method_name|
          # equivalent to (e.g.):
          #
          #   def foo
          #     registry.fetch(:foo)
          #   end
          mod.send(:define_method, method_name) do
            registry.fetch(dependency_name)
          end

          # equivalent to (e.g.):
          #
          #   private :foo
          mod.send(visibility, method_name)
        end
      end

      mod
    end

    # Assign a locator for the specified dependency name
    def register(locator, name, block)
      name = name.to_sym
      @registry[name] = locator.new(block)
    end
  end
end
