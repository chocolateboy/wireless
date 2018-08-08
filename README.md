# Wireless

[![Build Status](https://travis-ci.org/chocolateboy/wireless.svg)](https://travis-ci.org/chocolateboy/wireless)
[![Gem Version](https://img.shields.io/gem/v/wireless.svg)](https://rubygems.org/gems/wireless)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [NAME](#name)
- [INSTALLATION](#installation)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [WHY?](#why)
  - [Why Wireless?](#why-wireless)
  - [Why Service Locators?](#why-service-locators)
- [VERSION](#version)
- [SEE ALSO](#see-also)
  - [Gems](#gems)
  - [Articles](#articles)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# NAME

Wireless - a lightweight, declarative dependency-provider

# INSTALLATION

```ruby
gem "wireless"
```

# SYNOPSIS

```ruby
require "wireless"

WL = Wireless.new do
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
  on(:baz) do |wl|
    [:baz, wl[:foo], wl[:bar]]
  end
end

# factory
WL[:foo] # [:foo, 1]
WL[:foo] # [:foo, 2]

# singleton
WL[:bar] # [:bar, 42]
WL[:bar] # [:bar, 42]

# dependencies
WL[:baz] # [:baz, [:foo, 3], [:bar, 42]]
WL[:baz] # [:baz, [:foo, 4], [:bar, 42]]

# mixin
class Example
  include WL.mixin %i[foo bar baz]

  def test
    foo # [:foo, 5]
    bar # [:bar, 42]
    baz # [:baz, [:foo, 6], [:bar, 42]]
  end
end
```

# DESCRIPTION

Wireless is a declarative dependency-provider (AKA [service locator](https://en.wikipedia.org/wiki/Service_locator_pattern)),
which has the following features:

* Simplicity

    It's just an object which dependencies can be added to and retrieved from. It can
    be passed around and stored like any other object. No "injection", no containers,
    no framework, no dependencies.

* Inclusion

    Inclusion of dependency getters into a class or module with control over their visibility.

* Laziness

    As well as dependencies being resolved lazily, they can also be *registered* lazily i.e.
    at the point of creation, rather than forcing everything to be declared up-front.

* Safety

    Dependency resolution is thread-safe. Dependency cycles are checked and raise a fatal
    error as soon as they are detected.

# WHY?

## Why Wireless?

I wanted a simple service locator like [DiFtw](https://github.com/jhollinger/ruby-diftw),
with cycle detection and control over the [visibility of getters](https://github.com/jhollinger/ruby-diftw/issues/1).

## Why Service Locators?

Service locators make it easy to handle shared (AKA
[cross-cutting](https://en.wikipedia.org/wiki/Cross-cutting_concern)) dependencies i.e.
values and services that are required by multiple otherwise-unrelated parts of a system.
Examples include:

* logging
* configuration data
* storage backends
* authorisation

Rather than wiring these dependencies together manually, service locators allow them to be
registered and retrieved in a declarative way. This is similar to the difference between
imperative build tools like Ant or Gulp, and declarative build tools like Make or Rake, which
allow prerequisites to be acquired without micromanaging their construction and coordination.

# VERSION

0.0.2

# SEE ALSO

## Gems

- [Canister](https://github.com/mlibrary/canister) - a simple service-locator inspired by Jim Weirich's [article](https://archive.li/shxeA) on Dependency Injection
- [DiFtw](https://github.com/jhollinger/ruby-diftw) - the original inspiration for this module: a similar API with a focus on testing/mocking

## Articles

- Martin Fowler - [Inversion of Control Containers and the Dependency Injection pattern](https://www.martinfowler.com/articles/injection.html) [2004]
- Jim Weirich - [Dependency Injection in Ruby](https://archive.li/shxeA) [2004]

# AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

# COPYRIGHT AND LICENSE

Copyright © 2018 by chocolateboy.

This is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
