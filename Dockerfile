FROM ruby:2.6.7-alpine as assets
ENV RAILS_ENV production
WORKDIR /app
RUN apk add --update build-base nodejs yarn git tzdata postgresql-dev python2
COPY Gemfile Gemfile.lock ./
RUN BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ") && \
    gem install bundler:$BUNDLER_VERSION && \
    bundle install --jobs 4
COPY package.json yarn.lock ./
RUN yarn install
COPY . ./
RUN bundle exec rails webpacker:compile

FROM ruby:2.6.7-alpine as bundler
WORKDIR /app
COPY Gemfile Gemfile.lock ./
COPY --from=assets /usr/local/bundle /usr/local/bundle
RUN BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ") && \
    gem install bundler:$BUNDLER_VERSION && \
    bundle install --jobs 4 --without "test development darwin"

FROM ruby:2.6.7-alpine
WORKDIR /app
RUN apk add --update tzdata libpq
ENV RAILS_ENV production
ENV RACK_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
COPY . ./
COPY --from=assets /app/public/packs /app/public/packs
COPY --from=bundler /usr/local/bundle /usr/local/bundle
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
