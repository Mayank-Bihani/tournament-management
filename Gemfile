source "https://rubygems.org"

ruby "~> 3.2"

gem "rails", "~> 7.1"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 6.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "sprockets-rails"
gem "bootsnap", require: false
gem "jbuilder"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "shoulda-matchers", "~> 5.0"
  gem "rails-controller-testing"
end
