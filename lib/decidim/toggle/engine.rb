# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/system"
# After core so Decidim::FormBuilder autoload pulls Map, TranslatableAttributes, etc.
require "decidim/toggle/settings_form_builder"
require "decidim/toggle/organization_settings_tabs"
require "decidim/toggle/expose_attributes_to_js_validator"

module Decidim
  module Toggle
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Toggle

      routes do
        scope path: "system" do
          patch "organizations/:organization_id/settings_tab/:tab_id",
                controller: "/decidim_toggle/system/settings_tab",
                action: :update,
                as: :update_settings_tab_organization
        end
      end

      initializer "decidim_toggle.ignore_deface_overrides_in_zeitwerk" do
        overrides_path = root.join("app/overrides").to_s
        Rails.autoloaders.main.ignore(overrides_path) if defined?(Rails.autoloaders) && Dir.exist?(overrides_path)
      end

      initializer "decidim_toggle.mount_routes" do
        Rails.application.routes.append do
          mount Decidim::Toggle::Engine, at: "/decidim_toggle", as: "decidim_toggle"
        end
      end

      initializer "decidim_toggle.organization_settings_tabs" do
        Decidim::Toggle::OrganizationSettingsTabs.register!
      end

      initializer "decidim_toggle.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      # So System::OrganizationsController resolves this before decidim-system's partial.
      initializer "decidim_toggle.prepend_views" do
        ActiveSupport.on_load(:action_controller) do
          prepend_view_path Decidim::Toggle::Engine.root.join("app/views")
        end
      end

      config.to_prepare do
        Decidim::Toggle::ExposeAttributesToJsValidator.validate! if Rails.env.development? || Rails.env.test?

        ActiveSupport.on_load(:action_view) do
          include Decidim::Toggle::SystemSettingsTabHelper
          include Decidim::Toggle::JavascriptConfigHelper
        end
      end
    end
  end
end
