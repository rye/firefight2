FROM docker.io/ruby:2.0

WORKDIR /app

ADD . /app

RUN bundle install
