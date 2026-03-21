# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "Deface overrides for organizations edit" do
      let(:virtual_path) { "decidim/system/organizations/edit" }

      let(:overrides_list) do
        found = Deface::Override.find(virtual_path:)
        found.is_a?(Hash) ? found.values.flatten : Array(found)
      end

      it "registers overrides for decidim/system/organizations/edit" do
        toggle_overrides = overrides_list.select { |o| o.name.to_s.include?("decidim_toggle") }
        expect(toggle_overrides.size).to eq(1)
      end

      it "has override to replace advanced settings with tabbed settings" do
        replace = overrides_list.find { |o| o.name.to_s == "decidim_toggle_replace_advanced_settings_button" }
        expect(replace).to be_present
      end
    end
  end
end
