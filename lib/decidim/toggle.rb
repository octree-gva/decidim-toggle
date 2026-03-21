# frozen_string_literal: true

require "decidim/toggle/version"
require "decidim/toggle/settings_tab_registry"
require "decidim/toggle/settings_tab_item"
require "decidim/toggle/settings_tabs"
require "decidim/toggle/settings_form_builder"
require "decidim/toggle/module_config"
require "decidim/toggle/engine"

module Decidim
  module Toggle
    def self.settings_tabs(name, &)
      SettingsTabRegistry.register(name, &)
    end
  end
end
