FROM ruby:2.4.6

RUN apt-get update -qq && \
  apt-get install -qq -y build-essential libpq-dev nodejs && \
  rm -rf /var/lib/apt/lists*

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN gem install bundler

RUN bundler install

# 全コピー
COPY . /usr/src/app

# puma
EXPOSE 80
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
