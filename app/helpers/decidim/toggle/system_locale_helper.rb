# frozen_string_literal: true

module Decidim
  module Toggle
    module SystemLocaleHelper
      def decidim_toggle_update_settings_tab_organization_path(organization, tab_id:)
        path = Decidim::Toggle::Engine.routes.url_helpers.update_settings_tab_organization_path(organization, tab_id:)
        "/decidim_toggle#{path}"
      end
    end
  end
end
