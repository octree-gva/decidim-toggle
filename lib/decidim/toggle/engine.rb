# frozen_string_literal: true

require "rails"
require "decidim/core"
require "decidim/system"
require "decidim/toggle/organization_settings_tabs"

module Decidim
  module Toggle
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Toggle

      config.paths["config/routes"] = [root.join("config", "routes.rb").to_s]
      initializer "decidim_toggle.mount_routes" do
        Rails.application.routes.append do
          mount Decidim::Toggle::Engine, at: "/decidim_toggle", as: "decidim_toggle"
        end
      end

      initializer "decidim_toggle.organization_settings_tabs" do
        Decidim::Toggle::OrganizationSettingsTabs.register!
      end

      initializer "decidim_toggle.append_migrations" do |app|
        next if app.root == root

        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
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
        ActiveSupport.on_load(:action_view) { include Decidim::Toggle::SystemLocaleHelper }
      end
    end
  end
end
