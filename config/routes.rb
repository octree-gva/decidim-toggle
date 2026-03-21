# frozen_string_literal: true

Decidim::Toggle::Engine.routes.draw do
  scope path: "system" do
    patch "organizations/:organization_id/settings_tab/:tab_id",
          controller: "/decidim_toggle/system/settings_tab",
          action: :update,
          as: :update_settings_tab_organization
  end
end
