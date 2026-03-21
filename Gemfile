# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.2"

base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/toggle/version"

DECIDIM_VERSION = Decidim::Toggle.decidim_version

gem "bootsnap", "~> 1.4"
gem "decidim", DECIDIM_VERSION
gem "decidim-toggle", path: "."

gem "deface", "~> 1.9"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "brakeman", "~> 6.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "parallel_tests", "~> 4.2"
  gem "rubocop-rails", "~> 2.25.1"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end

gem "faker", "~> 3.6"
