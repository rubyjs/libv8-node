PWD := $(shell pwd)
OS := $(shell uname -s | tr '[A-Z]' '[a-z]')
CPU := $(shell uname -m)
VERSION := $(shell ./libexec/metadata version)
NODE_VERSION := $(shell ./libexec/metadata node_version)
RUBY_VERSION = $(shell ruby -e 'puts RUBY_VERSION.gsub(/\d+$$/, "0")')

.PHONY: vars
vars:
	@echo $(PWD)
	@echo $(OS) $(CPU)
	@echo $(VERSION) $(NODE_VERSION)
	@echo $(RUBY_VERSION)

.PHONY: all
all: gem test

.PHONY: build
build: src/node-v$(NODE_VERSION)/out/Release/node

.PHONY: lib
lib: src/node-v$(NODE_VERSION)/out/Release/libv8_monolith.a

.PHONY: gem
gem: pkg/libv8-node-$(VERSION)-$(CPU)-$(OS).gem

.PHONY: test
test: test/$(CPU)-$(OS)

.PHONY: ctest
ctest: vendor/v8
	cd test/gtest && cmake -S . -B build && cd build && cmake --build . && ctest

src/node-v$(NODE_VERSION).tar.gz:
	./libexec/download-node $(NODE_VERSION)

src/node-v$(NODE_VERSION): src/node-v$(NODE_VERSION).tar.gz
	./libexec/extract-node $(NODE_VERSION)

src/node-v$(NODE_VERSION)/out/Release/node: src/node-v$(NODE_VERSION)
	./libexec/build-libv8 $(NODE_VERSION)

src/node-v$(NODE_VERSION)/out/Release/libv8_monolith.a: src/node-v$(NODE_VERSION)/out/Release/node
	./libexec/build-monolith $(NODE_VERSION)

.PHONY: vendor/v8
vendor/v8: src/node-v$(NODE_VERSION)/out/Release/libv8_monolith.a
	./libexec/inject-libv8 $(NODE_VERSION)

pkg/libv8-node-$(VERSION)-$(CPU)-$(OS).gem: vendor/v8
	bundle exec rake binary

.PHONY: test/$(CPU)-$(OS)
test/$(CPU)-$(OS): pkg/libv8-node-$(VERSION)-$(CPU)-$(OS).gem
	test -d test/mini_racer || git clone https://github.com/rubyjs/mini_racer.git test/mini_racer --depth 1
	cd test/mini_racer && git fetch origin refs/pull/261/head && git checkout FETCH_HEAD && git reset --hard && git clean -f -d -x
	ruby -i -ne '$$_ =~ /^\s+LIBV8_NODE_VERSION/ ? print("  LIBV8_NODE_VERSION = \"$(VERSION)\"\n") : print' test/mini_racer/lib/mini_racer/version.rb
	ruby -i -ne '$$_ =~ /spec.required_ruby_version/ ? "" : print' test/mini_racer/mini_racer.gemspec
	cd test/mini_racer && env TOP="$(PWD)" GEM_HOME="$(PWD)/test/bundle/ruby/$(RUBY_VERSION)" BUNDLE_PATH="$(PWD)/test/bundle" sh -c 'rm -rf "$${GEM_HOME}" && gem install $${TOP}/$< && bundle install && bundle exec rake compile && bundle exec rake test'
