# frozen_string_literal: true

require_relative 'test_helper'

module MiniTest
  module Assertions
    def assert_raises_cycle_error(pattern, &block)
      err = assert_raises(Wireless::CycleError, &block)
      assert { err.is_a?(Wireless::Error) }
      assert { err.is_a?(StandardError) }
      assert { err.message =~ pattern }
    end
  end
end

describe 'cycles' do
  it 'detects cycles (factory)' do
    wl = Wireless.new do
      on(:foo)  { |w| w[:bar] }
      on(:bar)  { |w| w[:baz] }
      on(:baz)  { |w| w[:quux] }
      on(:quux) { |w| w[:foo] }
    end

    assert_raises_cycle_error(/foo -> bar -> baz -> quux -> foo/) { wl[:foo] }
  end

  it 'detects self-references (factory)' do
    wl = Wireless.new do
      on(:foo) { |w| w[:foo] }
    end

    assert_raises_cycle_error(/foo -> foo/) { wl[:foo] }
  end

  it 'detects cycles (singleton)' do
    wl = Wireless.new do
      once(:foo)  { |w| w[:bar] }
      once(:bar)  { |w| w[:baz] }
      once(:baz)  { |w| w[:quux] }
      once(:quux) { |w| w[:foo] }
    end

    assert_raises_cycle_error(/foo -> bar -> baz -> quux -> foo/) { wl[:foo] }
  end

  it 'detects self-references (singleton)' do
    wl = Wireless.new do
      once(:foo) { |w| w[:foo] }
    end

    assert_raises_cycle_error(/foo -> foo/) { wl[:foo] }
  end

  it 'detects cycles (mixed)' do
    wl = Wireless.new do
      on(:foo)    { |w| w[:bar] }
      once(:bar)  { |w| w[:baz] }
      on(:baz)    { |w| w[:quux] }
      once(:quux) { |w| w[:foo] }
    end

    assert_raises_cycle_error(/foo -> bar -> baz -> quux -> foo/) { wl[:foo] }
  end
end
