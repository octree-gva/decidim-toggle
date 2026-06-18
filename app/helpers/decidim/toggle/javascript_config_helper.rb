# frozen_string_literal: true

module Decidim
  module Toggle
    module JavascriptConfigHelper
      def decidim_toggle_javascript_config
        Decidim::Toggle.javascript_config_for(current_organization)
      end
    end
  end
end
