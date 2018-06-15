# frozen_string_literal: true

require 'wireless'
require_relative 'test_helper'

describe 'core' do
  # confirm the example in the documentation works
  it 'matches the synopsis' do
    wl = Wireless.new do
      count = 0

      # factory: return a new value every time
      on(:foo) do
        [:foo, count += 1]
      end

      # singleton: return the cached value
      once(:bar) do
        [:bar, 42]
      end

      # depend on other dependencies
      on(:baz) do |w|
        [:baz, w[:foo], w[:bar]]
      end
    end

    # factory
    assert { wl[:foo] == [:foo, 1] }
    assert { wl[:foo] == [:foo, 2] }

    # singleton
    assert { wl[:bar] == [:bar, 42] }
    assert { wl[:bar] == [:bar, 42] }

    # dependencies
    assert { wl[:baz] == [:baz, [:foo, 3], [:bar, 42]] }
    assert { wl[:baz] == [:baz, [:foo, 4], [:bar, 42]] }
  end

  # same again with `factory` instead of `on` and `singleton` instead of `once`
  it 'supports aliases' do
    wl = Wireless.new do
      count = 0

      # factory: return a new value every time
      factory(:foo) do
        [:foo, count += 1]
      end

      # singleton: return the cached value
      singleton(:bar) do
        [:bar, 42]
      end

      # depend on other dependencies
      factory(:baz) do |w|
        [:baz, w[:foo], w[:bar]]
      end
    end

    # factory
    assert { wl[:foo] == [:foo, 1] }
    assert { wl[:foo] == [:foo, 2] }

    # singleton
    assert { wl[:bar] == [:bar, 42] }
    assert { wl[:bar] == [:bar, 42] }

    # dependencies
    assert { wl[:baz] == [:baz, [:foo, 3], [:bar, 42]] }
    assert { wl[:baz] == [:baz, [:foo, 4], [:bar, 42]] }
  end

  it 'allows an indirectly-accessed dependency to be defined lazily' do
    wl = Wireless.new do
      on(:foo) { |w| [:foo, w[:bar]] }
    end

    assert_raises(Wireless::NameError) { wl[:foo] }
    assert_raises(Wireless::NameError) { wl[:bar] }

    wl.once(:bar) { :bar }

    assert { wl[:foo] == %i[foo bar] }
    assert { wl[:bar] == :bar }
  end

  # same as before, but force :bar before it's accessed via :foo
  it 'allows a directly-accessed dependency to be defined lazily' do
    wl = Wireless.new do
      on(:foo) { |w| [:foo, w[:bar]] }
    end

    assert_raises(Wireless::NameError) { wl[:foo] }
    assert_raises(Wireless::NameError) { wl[:bar] }

    wl.once(:bar) { :bar }

    assert { wl[:bar] == :bar }
    assert { wl[:foo] == %i[foo bar] }
  end
end
