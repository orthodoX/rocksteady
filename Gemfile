source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.5'

gem 'pg'
gem 'puma', '~> 3.7'
gem 'webpacker', '>= 4.0.x'
gem 'webpacker-react'
gem 'house_style'
gem 'haml-rails'
gem 'turbolinks'
gem 'nomad'
gem 'aws-sdk-ecr'
gem 'http'
gem 'rouge'

group :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'simplecov'
  gem 'webmock'
end

group :test, :development do
  gem 'pry-rails'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
end
