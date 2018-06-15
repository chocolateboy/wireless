# frozen_string_literal: true

require 'wireless'
require_relative 'test_helper'

describe 'exceptions' do
  it 'raises an error if an undefined dependency is accessed' do
    wl = Wireless.new
    err = assert_raises(Wireless::NameError) { wl[:foo] }
    assert { err.is_a?(Wireless::Error) }
    assert { err.is_a?(StandardError) }
  end

  it 'raises an error if a dependency is replaced' do
    wl = Wireless.new do
      on(:foo) { :foo }
      once(:bar) { :bar }
    end

    assert { wl[:foo] == :foo }
    assert { wl[:bar] == :bar }

    assert_raises(Wireless::NameError) do
      wl.on(:foo) { :replace_foo }
    end

    assert_raises(Wireless::NameError) do
      wl.on(:bar) { :replace_bar }
    end
  end

  it 'raises an error if dependencies are defined without a block' do
    wl = Wireless.new

    assert_raises(ArgumentError) do
      wl.on(:foo)
    end

    assert_raises(ArgumentError) do
      wl.once(:foo)
    end
  end

  it "doesn't raise an error if a dependency is defined by a class" do
    foo = Class.new
    bar = Class.new
    wl = Wireless.new do
      on(:foo, foo)
      once(:bar, bar)
    end

    assert { wl[:foo].is_a?(foo) }
    assert { wl[:bar].is_a?(bar) }
  end
end
