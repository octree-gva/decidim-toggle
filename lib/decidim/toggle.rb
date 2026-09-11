# frozen_string_literal: true

require "decidim/toggle/version"
require "decidim/toggle/gem_registry"
require "decidim/toggle/authorization_workflows"
require "decidim/toggle/settings_tab_registry"
require "decidim/toggle/settings_tab_item"
require "decidim/toggle/settings_tabs"
require "decidim/toggle/module_config"
require "decidim/toggle/informative_callouts"
require "decidim/toggle/field_conditions"
require "decidim/toggle/module_config_i18n"
require "decidim/toggle/module_config_form"
require "decidim/toggle/tab_form"
require "decidim/toggle/expose_attributes_to_js"
require "decidim/toggle/javascript_config"
require "decidim/toggle/engine"

module Decidim
  module Toggle
    def self.settings_tabs(name, &)
      SettingsTabRegistry.register(name, &)
    end

    def self.filter_authorization_workflows(&)
      AuthorizationWorkflows.add_filter(&)
    end

    def self.authorization_workflows_for(organization)
      AuthorizationWorkflows.for(organization)
    end

    # @param gem_name [String, Symbol] Bundler gem name (e.g. +"decidim-space_page"+)
    # @return [Boolean]
    def self.gem_present?(gem_name)
      GemRegistry.present?(gem_name)
    end

    # True when +decidim-ephemeral_participation+ is in the bundle.
    # Prefer Bundler over +const_defined?+ (Zeitwerk may not have defined the
    # constant yet when System settings render).
    def self.ephemeral_participation?
      gem_present?("decidim-ephemeral_participation")
    end

    # @param organization [Decidim::Organization, nil]
    # @param registry_name [Symbol] settings tab registry (default +:organization_settings+)
    # @return [Hash{String => Object}] flat keys like +"decidim_geo.enabled"+
    def self.javascript_config_for(organization, registry_name: :organization_settings)
      JavascriptConfig.for(organization, registry_name:)
    end
  end
end
