# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "System organization advanced settings override" do
      let(:view_path) do
        Decidim::Toggle::Engine.root.join("app/views/decidim_toggle/system/organizations/_settings_tabs.html.erb")
      end

      it "provides settings tabs partial that builds tabs and passes organization + UpdateOrganizationForm" do
        expect(view_path).to exist
        content = File.read(view_path)
        expect(content).to include("SettingsTabs")
        expect(content).to include("organization_form")
        expect(content).to include("organization")
        expect(content).to include("custom_organization_tab")
      end

      it "provides system organization edit view without an outer decidim_form_for" do
        edit_path = Decidim::Toggle::Engine.root.join("app/views/decidim/system/organizations/edit.html.erb")
        expect(edit_path).to exist
        edit_content = File.read(edit_path)
        expect(edit_content).not_to include("decidim_form_for")
        expect(edit_content).to include("settings_tabs")
      end
    end
  end
end
