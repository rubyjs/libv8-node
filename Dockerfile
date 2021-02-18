ARG RUBY_VERSION=2.7
FROM ruby:${RUBY_VERSION}

RUN test ! -f /etc/alpine-release || apk add --no-cache build-base bash python2 python3 git curl tar clang binutils-gold

RUN mkdir -p /code
WORKDIR /code

ARG NODE_VERSION=14.14.0

COPY download-node /code/
RUN ./download-node ${NODE_VERSION}
COPY extract-node /code/
RUN ./extract-node ${NODE_VERSION}
COPY build-libv8 /code/
RUN ./build-libv8 ${NODE_VERSION}
COPY build-monolith /code/
RUN ./build-monolith ${NODE_VERSION}
COPY inject-libv8 /code/
RUN ./inject-libv8 ${NODE_VERSION}

COPY Gemfile libv8-node.gemspec /code/
COPY lib/libv8/node/version.rb /code/lib/libv8/node/version.rb
RUN bundle install

COPY . /code/
RUN bundle exec rake binary

CMD /bin/bash
