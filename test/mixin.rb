# frozen_string_literal: true

require 'wireless'
require_relative 'test_helper'

class Method
  def visibility
    if receiver.private_methods.include?(name)
      :private
    elsif receiver.protected_methods.include?(name)
      :protected
    elsif receiver.public_methods.include?(name)
      :public
    else
      :unknown
    end
  end
end

module MethodInspector
  def get(name)
    result = send(name)
    [result, method(name).visibility]
  end
end

# a helper method which creates and returns a new Wireless instance used by most tests
def test_wireless(default_visibility = nil)
  args = Array(default_visibility)

  Wireless.new(*args) do
    on(:foo) { :Foo }
    once(:bar) { :Bar }
    on(:baz) { :Baz }
    once(:quux) { :Quux }
  end
end

describe 'mixin' do
  it 'imports getters with the default visibility (private)' do
    wl = test_wireless

    klass = Class.new do
      include wl.mixin %i[foo bar baz quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar private] }
    assert { test.get(:baz) == %i[Baz private] }
    assert { test.get(:quux) == %i[Quux private] }
  end

  it 'allows the default visibility to be set to private' do
    wl = test_wireless(:private)

    klass = Class.new do
      include wl.mixin %i[foo bar baz quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar private] }
    assert { test.get(:baz) == %i[Baz private] }
    assert { test.get(:quux) == %i[Quux private] }
  end

  it 'allows the default visibility to be set to protected' do
    wl = test_wireless(:protected)

    klass = Class.new do
      include wl.mixin %i[foo bar baz quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo protected] }
    assert { test.get(:bar) == %i[Bar protected] }
    assert { test.get(:baz) == %i[Baz protected] }
    assert { test.get(:quux) == %i[Quux protected] }
  end

  it 'allows the default visibility to be set to public' do
    wl = test_wireless(:public)

    klass = Class.new do
      include wl.mixin %i[foo bar baz quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo public] }
    assert { test.get(:bar) == %i[Bar public] }
    assert { test.get(:baz) == %i[Baz public] }
    assert { test.get(:quux) == %i[Quux public] }
  end

  it 'allows visibilities to be overridden (no default)' do
    wl = test_wireless

    klass = Class.new do
      # note: these tests mix up the wrapped (e.g. [:foo]) and unwrapped
      # (e.g. :quux) import specifications to ensure they're all covered
      include wl.mixin private: [:foo], protected: %i[bar baz], public: [:quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar protected] }
    assert { test.get(:baz) == %i[Baz protected] }
    assert { test.get(:quux) == %i[Quux public] }
  end

  it 'allows visibilities to be overridden (default: private)' do
    wl = test_wireless(:private)

    klass = Class.new do
      include wl.mixin private: :foo, protected: %i[bar baz], public: :quux
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar protected] }
    assert { test.get(:baz) == %i[Baz protected] }
    assert { test.get(:quux) == %i[Quux public] }
  end

  it 'allows visibilities to be overridden (default: protected)' do
    wl = test_wireless(:protected)

    klass = Class.new do
      include wl.mixin private: [:foo], protected: %i[bar baz], public: :quux
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar protected] }
    assert { test.get(:baz) == %i[Baz protected] }
    assert { test.get(:quux) == %i[Quux public] }
  end

  it 'allows visibilities to be overridden (default: public)' do
    wl = test_wireless(:public)

    klass = Class.new do
      include wl.mixin private: :foo, protected: %i[bar baz], public: [:quux]
      include MethodInspector
    end

    test = klass.new
    assert { test.get(:foo) == %i[Foo private] }
    assert { test.get(:bar) == %i[Bar protected] }
    assert { test.get(:baz) == %i[Baz protected] }
    assert { test.get(:quux) == %i[Quux public] }
  end

  it 'allows imports to be renamed (separate aliases)' do
    wl = test_wireless

    klass = Class.new do
      include wl.mixin({
        private: { foo: :one },
        protected: [{ bar: :two }, { baz: :three }],
        public: [{ quux: :four }],
      })

      include MethodInspector
    end

    test = klass.new

    assert_raises(NoMethodError) { test.get(:foo) }
    assert_raises(NoMethodError) { test.get(:bar) }
    assert_raises(NoMethodError) { test.get(:baz) }
    assert_raises(NoMethodError) { test.get(:quux) }

    assert { test.get(:one) == %i[Foo private] }
    assert { test.get(:two) == %i[Bar protected] }
    assert { test.get(:three) == %i[Baz protected] }
    assert { test.get(:four) == %i[Quux public] }
  end

  it 'allows imports to be renamed (merged aliases)' do
    wl = test_wireless

    klass = Class.new do
      include wl.mixin({
        private: { foo: :one },
        protected: { bar: :two, baz: :three },
        public: [{ quux: :four }],
      })

      include MethodInspector
    end

    test = klass.new

    assert_raises(NoMethodError) { test.get(:foo) }
    assert_raises(NoMethodError) { test.get(:bar) }
    assert_raises(NoMethodError) { test.get(:baz) }
    assert_raises(NoMethodError) { test.get(:quux) }

    assert { test.get(:one) == %i[Foo private] }
    assert { test.get(:two) == %i[Bar protected] }
    assert { test.get(:three) == %i[Baz protected] }
    assert { test.get(:four) == %i[Quux public] }
  end
end
