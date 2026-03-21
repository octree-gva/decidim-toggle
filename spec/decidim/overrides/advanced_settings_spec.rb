# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "System organization advanced settings override" do
      let(:view_path) do
        Decidim::Toggle::Engine.root.join("app/views/decidim_toggle/system/organizations/_settings_tabs.html.erb")
      end

      it "provides settings tabs partial that builds tabs and passes the form builder" do
        expect(view_path).to exist
        content = File.read(view_path)
        expect(content).to include("SettingsTabs")
        expect(content).to include("f:")
        expect(content).to include("organization")
      end
    end
  end
end
