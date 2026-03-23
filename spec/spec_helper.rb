# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/map_server"
require "decidim/dev/test/base_spec_helper"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }
