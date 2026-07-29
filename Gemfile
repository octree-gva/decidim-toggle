# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.7"

base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/toggle/version"

# Development / CI / RSpec run against Decidim 0.32.
# The gem itself accepts Decidim::Toggle.decidim_version (>= 0.29, < 0.33).
DECIDIM_VERSION = "~> 0.32.0"

gem "bootsnap", "~> 1.23"
gem "decidim", DECIDIM_VERSION
gem "decidim-toggle", path: "."

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "brakeman", "~> 8.0"
  gem "byebug", "~> 13.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "parallel_tests", "~> 5.6"
end

group :development do
  gem "letter_opener_web", "~> 3.0"
  gem "listen", "~> 3.10"
  gem "web-console", "~> 4.3"
end

gem "faker", "~> 3.6"
