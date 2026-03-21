# frozen_string_literal: true

SimpleCov.start "rails" do
  root File.expand_path(__dir__)

  add_filter "/spec/"
  add_filter "/decidim_dummy_app/"
  add_filter "/vendor/"
  add_filter "/.bundle/"

  add_group "App", "app"
  add_group "Lib", "lib"

  enable_coverage :branch
end
