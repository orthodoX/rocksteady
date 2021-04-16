FROM ruby:2.6.7-alpine as assets
ENV RAILS_ENV production
WORKDIR /app
RUN apk add --update build-base nodejs yarn git tzdata postgresql-dev
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY package.json yarn.lock ./
RUN yarn install
COPY . ./
RUN bundle exec rails webpacker:compile

FROM ruby:2.6.7-alpine as bundler
WORKDIR /app
COPY Gemfile Gemfile.lock ./
COPY --from=assets /usr/local/bundle /usr/local/bundle
RUN bundle install --clean --without "test development darwin"

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
