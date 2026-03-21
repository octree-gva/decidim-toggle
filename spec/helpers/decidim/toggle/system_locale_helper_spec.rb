# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SystemLocaleHelper do
      let(:helper_host) do
        Class.new do
          include Decidim::Toggle::SystemLocaleHelper
        end.new
      end

      let(:organization) { create(:organization) }

      it "prefixes engine path with /decidim_toggle once" do
        path = helper_host.decidim_toggle_update_settings_tab_organization_path(organization, tab_id: "name")
        expect(path).to start_with("/decidim_toggle")
        expect(path).to include("settings_tab")
        expect(path).not_to include("/decidim_toggle/decidim_toggle")
      end
    end
  end
end
