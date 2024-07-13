source "https://rubygems.org"

ruby "3.3.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "rails_live_reload"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

# ログイン機能を追加するためのgem
gem 'devise'

# 環境変数を設定するためのgem
gem 'dotenv-rails', groups: [:development, :test]

# Googleログイン機能を追加するためのgem
gem 'omniauth-google-oauth2'

# discordログイン機能を追加するためのgem
gem 'omniauth-discord'

# Twitterログイン機能を追加するためのgem
gem 'omniauth-twitter'

# GitHubログイン機能を追加するためのgem
gem 'omniauth-github'

# LINEログイン機能を追加するためのgem
gem 'omniauth-line'

# CSRF対策を追加するためのgem
gem 'omniauth-rails_csrf_protection', '1.0.2'

# ログイン機能を日本語化するためのgem
gem 'devise-i18n'

# omniauthのバージョンを指定するためのgem
gem 'omniauth', '2.1.2'

# Action CableのためのRedisを追加(データベース)
gem 'redis', '~> 4.0'

# Elasticsearchを使う為のgem
gem 'searchkick'

# 独立した検索エンジンで高速検索を実現するためのgem
# 独立した検索エンジンで高速検索を実現するためのgem
gem 'elasticsearch', '~> 7.11'
gem 'elasticsearch-model', '~> 7.2'
gem 'elasticsearch-rails', '~> 7.2'

