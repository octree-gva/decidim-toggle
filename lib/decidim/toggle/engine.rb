# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/system"
require "decidim/toggle/organization_settings_tabs"

module Decidim
  module Toggle
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Toggle

      config.paths["config/routes"] = [root.join("config", "routes.rb").to_s]
      config.paths["app/overrides"] = root.join("app", "overrides").to_s

      initializer "decidim_toggle.mount_routes" do
        Rails.application.routes.append do
          mount Decidim::Toggle::Engine, at: "/decidim_toggle", as: "decidim_toggle"
        end
      end

      initializer "decidim_toggle.organization_settings_tabs" do
        Decidim::Toggle::OrganizationSettingsTabs.register!
      end

      config.to_prepare do
        Rails.application.config.deface.enabled = true
        ActiveSupport.on_load(:action_view) { include Decidim::Toggle::SystemLocaleHelper }
      end
    end
  end
end
