PWD := $(shell pwd)
VERSION := $(shell ./libexec/metadata version)
NODE_VERSION := $(shell ./libexec/metadata node_version)

all:

pkg/libv8-node-$(VERSION)-x86_64-linux.gem:
	docker build --platform linux/amd64 --build-arg RUBY_VERSION=2.3 --progress plain -t libv8-node:gnu .
	docker run --platform linux/amd64 --rm -it -v "$(PWD)/pkg":/pkg libv8-node:gnu cp $@ /pkg/

pkg/libv8-node-$(VERSION)-x86_64-linux-musl.gem:
	docker build --platform linux/amd64 --build-arg RUBY_VERSION=2.4-alpine --progress plain -t libv8-node:musl .
	docker run --platform linux/amd64 --rm -it -v "$(PWD)/pkg":/pkg libv8-node:musl cp $@ /pkg/

pkg/libv8-node-$(VERSION)-aarch64-linux.gem:
	docker build --platform linux/arm64 --build-arg RUBY_VERSION=2.3 --progress plain -t libv8-node:gnu .
	docker run --platform linux/arm64 --rm -it -v "$(PWD)/pkg":/pkg libv8-node:gnu cp $@ /pkg/

pkg/libv8-node-$(VERSION)-aarch64-linux-musl.gem:
	docker build --platform linux/arm64 --build-arg RUBY_VERSION=2.4-alpine --progress plain -t libv8-node:musl .
	docker run --platform linux/arm64 --rm -it -v "$(PWD)/pkg":/pkg libv8-node:musl cp $@ /pkg/

test/x86_64-linux: pkg/libv8-node-$(VERSION)-x86_64-linux.gem
	test -d test/mini_racer || git clone https://github.com/rubyjs/mini_racer.git test/mini_racer --depth 1
	cd test/mini_racer && git fetch origin refs/pull/186/head && git checkout FETCH_HEAD && git reset --hard && git clean -f -d -x
	ruby -i -ne '$$_ =~ /^\s+LIBV8_NODE_VERSION/ ? print("  LIBV8_NODE_VERSION = \"15.12.0.0.beta1\"\n") : print' test/mini_racer/lib/mini_racer/version.rb
	docker run --platform linux/amd64 --rm -it -v "$(PWD)/test:/code/test" -w "/code/test/mini_racer" libv8-node:gnu sh -c 'gem install ../../$< && bundle install && bundle exec rake compile && bundle exec rake test'

test/x86_64-linux-musl: pkg/libv8-node-$(VERSION)-x86_64-linux-musl.gem
	test -d test/mini_racer || git clone https://github.com/rubyjs/mini_racer.git test/mini_racer --depth 1
	cd test/mini_racer && git fetch origin refs/pull/186/head && git checkout FETCH_HEAD && git reset --hard && git clean -f -d -x
	ruby -i -ne '$$_ =~ /^\s+LIBV8_NODE_VERSION/ ? print("  LIBV8_NODE_VERSION = \"15.12.0.0.beta1\"\n") : print' test/mini_racer/lib/mini_racer/version.rb
	docker run --platform linux/amd64 --rm -it -v "$(PWD)/test:/code/test" -w "/code/test/mini_racer" libv8-node:musl sh -c 'gem install ../../$< && bundle install && bundle exec rake compile && bundle exec rake test'

test/aarch64-linux: pkg/libv8-node-$(VERSION)-aarch64-linux.gem
	test -d test/mini_racer || git clone https://github.com/rubyjs/mini_racer.git test/mini_racer --depth 1
	cd test/mini_racer && git fetch origin refs/pull/186/head && git checkout FETCH_HEAD && git reset --hard && git clean -f -d -x
	ruby -i -ne '$$_ =~ /^\s+LIBV8_NODE_VERSION/ ? print("  LIBV8_NODE_VERSION = \"15.12.0.0.beta1\"\n") : print' test/mini_racer/lib/mini_racer/version.rb
	docker run --platform linux/arm64 --rm -it -v "$(PWD)/test:/code/test" -w "/code/test/mini_racer" libv8-node:gnu sh -c 'gem install ../../$< && bundle install && bundle exec rake compile && bundle exec rake test'

test/aarch64-linux-musl: pkg/libv8-node-$(VERSION)-aarch64-linux-musl.gem
	test -d test/mini_racer || git clone https://github.com/rubyjs/mini_racer.git test/mini_racer --depth 1
	cd test/mini_racer && git fetch origin refs/pull/186/head && git checkout FETCH_HEAD && git reset --hard && git clean -f -d -x
	ruby -i -ne '$$_ =~ /^\s+LIBV8_NODE_VERSION/ ? print("  LIBV8_NODE_VERSION = \"15.12.0.0.beta1\"\n") : print' test/mini_racer/lib/mini_racer/version.rb
	docker run --platform linux/arm64 --rm -it -v "$(PWD)/test:/code/test" -w "/code/test/mini_racer" libv8-node:musl sh -c 'gem install ../../$< && bundle install && bundle exec rake compile && bundle exec rake test'
