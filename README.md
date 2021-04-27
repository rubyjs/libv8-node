# libv8-node

A project for distributing the v8 runtime libraries and headers in both source and binary form, packaged as a language-independent zip and as a Ruby gem.

## Why?

The goal of libv8-node is three-fold:

- provide a build environment reliably producing a set of (non-Ruby) pre-compiled v8 libraries for as many platforms as possible
- package the pre-compiled v8 libraries as a binary gem leveraging rubygems platform matching
- provide a gem performing an automated compilation for all other platforms

Not only does this drastically reduce gem install times, but it also reduces dependencies on the local machine receiving the gem, as well as unifying the configurable variants that v8 supports.

## How? (also why Node?)

Upstream V8 is dependent on a set of complicated Google-provided tools that fetch source *and* a set of upstream-built compiler toolchains. These are only supported to the extent that they enable the current Chrome versions to build, and only for Chrome-supported platforms. This means that these tools operate on a rolling release basis purely for Google's needs and rely on source control for fetching, thus in practice are only provided as convenience, only allow a frozen-in-time overall relationship and receive no backports, frequently breaking in the context of stable releases, and don't easily support many platforms.

Conversely, the Node.js team vendors v8 in their source code, integrate it in their build system, maintain that across many platforms with public tiered support, backport stability and security fixes under a public timeline, all packaged as a simple tarball.

Therefore we fetch a Node tarball, extract it, build it, save the v8 headers and built libraries, vendor the result, and build a gem from it.

See the Node [platform list](https://github.com/nodejs/node/blob/master/BUILDING.md#platform-list) and [support schedule](https://nodejs.org/en/about/releases/).

## Do I get a binary?

It depends on what the Node version supports, how much of the platforms we can have in CI, and which hardware we have access to.

Check the CI artifacts on the repo's GitHub Actions and [libv8-node on rubygems.org](https://rubygems.org/gems/libv8-node) to be sure.

Here's an informal list of platforms we push so far, with equally informal tiers:

Tier 0 (CI built and tested):

- x86_64-darwin (17 to 20)
- x86_64-linux
- x86_64-linux-musl

Tier 1 (manual build and test):

- arm64-darwin (20)

Tier 2 (manual build and test, has known stability issues):

- aarch64-linux
- aarch64-linux-musl

As a fallback, the source gem (`ruby` gem platform) should compile on all Node supported platforms (including e.g. ppc64le or solaris), but we may not have tested it. Help is welcome!

If a published binary does not work for you, bundler allows to force using the `ruby` platform via `force_ruby_platform`, which will compile from source.

### Note on OS X macOS binaries

If you're installing libv8 on a macOS system that is present in the list above, and despite that, RubyGems insists on downloading a source version and compiling it, check the output of ruby -e 'puts Gem::Platform.local'. If it does not reflect the current version of your OS, recompile Ruby.

The platform gets hardcoded in Ruby during compilation and if you've updated your OS since you've compiled Ruby, it does not represent correctly your current platform which leads to RubyGems trying to download a platform-specific gem for the older version of your OS.

### Note on Alpine/musl

There is an outstanding issue with rubygems and bundler, where it may misselect the incorrect platform (e.g picking linux instead of linux-musl)

## Versioning

The gem versioning is Node-based, e.g node 15.14.0 gives the gem 15.14.0.0. The last number is an increment for libv8-node fixes. We try as mucha s possible not to include too much changes in such gem fixes, so you can consider these like "patch" in semver.

Compared to the `libv8` gem, there is no odd/even scheme, thanks to the intriduction in bundler of the `force_ruby_platform` flag.

## Requirements

### Building

Building from source has a number of requirements, which mostly depend on the Node version. You can find these in the corresponding Node tree.

- https://github.com/nodejs/node/blob/master/BUILDING.md#supported-toolchains
- https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms

Be sure to check the one for the Node version in use.

### Linking

Linking against the produced binaries e.g when installing a `ruby`-platform `mini_racer`) also has similar requirements. Notably, please make sure to have similarly recent compiler and libc++ installed.

## Building from the repo

See `BUILDING.md`. Also make sure to read `CONTRIBUTING.md` if you plan to help.

## About

This project spun off of [libv8](http://github.com/rubyjs/libv8), which itself spun off of [therubyracer](http://github.com/rubyjs/therubyracer) which depends on having a specific version of V8 to compile and run against. However, actually delivering that version reliably to all the different platforms proved to be a challenge to say the least.

## License

(The MIT License)

Copyright (c) 2009,2010 Charles Lowell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
