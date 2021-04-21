ARG RUBY_VERSION=2.3
FROM ruby:${RUBY_VERSION}

RUN test ! -f /etc/alpine-release || apk add --no-cache build-base bash python2 python3 git curl tar clang binutils-gold

RUN mkdir -p /code
WORKDIR /code

ARG NODE_VERSION=16.0.0

COPY libexec/download-node /code/libexec/
RUN ./libexec/download-node ${NODE_VERSION}
COPY libexec/extract-node /code/libexec/
COPY patch/* /code/patch/
RUN ./libexec/extract-node ${NODE_VERSION}
COPY libexec/build-libv8 /code/libexec/
RUN ./libexec/build-libv8 ${NODE_VERSION}
COPY libexec/build-monolith /code/libexec/
RUN ./libexec/build-monolith ${NODE_VERSION}
COPY libexec/inject-libv8 /code/libexec/
RUN ./libexec/inject-libv8 ${NODE_VERSION}

COPY Gemfile libv8-node.gemspec /code/
COPY lib/libv8/node/version.rb /code/lib/libv8/node/version.rb
RUN bundle install

COPY . /code/
RUN bundle exec rake binary

CMD /bin/bash
