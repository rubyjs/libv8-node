ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION}

RUN test ! -f /etc/alpine-release || apk add --no-cache build-base bash python3 git curl tar ccache clang
RUN test -f /etc/alpine-release || (apt-get update && apt-get install -y ccache clang)
ENV CCACHE_DIR=/ccache

RUN gem update --system 3.3.26 && gem install bundler -v '~> 2.3.26'

RUN mkdir -p /code
WORKDIR /code

ARG NODE_VERSION=18.13.0

COPY sums/v${NODE_VERSION}.sum /code/sums/
COPY libexec/download-node /code/libexec/
RUN ./libexec/download-node ${NODE_VERSION}
COPY libexec/extract-node /code/libexec/
COPY patch/* /code/patch/
RUN ./libexec/extract-node ${NODE_VERSION}
COPY libexec/platform /code/libexec/
COPY libexec/build-libv8 /code/libexec/
RUN --mount=type=cache,id=ccache,target=/ccache/ ./libexec/build-libv8 ${NODE_VERSION}
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
