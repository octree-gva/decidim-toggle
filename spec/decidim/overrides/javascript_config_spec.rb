# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "Deface overrides for JavaScript config" do
      let(:overrides_dir) { Engine.root.join("app/overrides") }

      it "registers public and admin layout injections" do
        expect(overrides_dir.join("add_toggle_javascript_public.rb")).to exist
        expect(overrides_dir.join("add_toggle_javascript_admin.rb")).to exist

        public_override = File.read(overrides_dir.join("add_toggle_javascript_public.rb"))
        admin_override = File.read(overrides_dir.join("add_toggle_javascript_admin.rb"))

        expect(public_override).to include('virtual_path: "layouts/decidim/_decidim_javascript"')
        expect(public_override).to include("layouts/decidim/toggle/javascript_config")
        expect(admin_override).to include('virtual_path: "layouts/decidim/admin/_header"')
        expect(admin_override).to include("layouts/decidim/toggle/javascript_config")
      end
    end
  end
end
