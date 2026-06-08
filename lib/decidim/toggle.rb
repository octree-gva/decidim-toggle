# frozen_string_literal: true

require "decidim/toggle/version"
require "decidim/toggle/gem_registry"
require "decidim/toggle/settings_tab_registry"
require "decidim/toggle/settings_tab_item"
require "decidim/toggle/settings_tabs"
require "decidim/toggle/module_config"
require "decidim/toggle/engine"

module Decidim
  module Toggle
    def self.settings_tabs(name, &)
      SettingsTabRegistry.register(name, &)
    end

    # @param gem_name [String, Symbol] Bundler gem name (e.g. +"decidim-space_page"+)
    # @return [Boolean]
    def self.gem_present?(gem_name)
      GemRegistry.present?(gem_name)
    end
  end
end
