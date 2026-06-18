# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "JavaScript config injection" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:user, :confirmed, :admin, organization:) }

      def self.ensure_demo_tab!
        @demo_tab_ready ||= begin
          demo_form_class = Class.new(Decidim::Form) do
            include ExposeAttributesToJs
            include ModuleConfigForm

            self.module_config_name = "decidim_toggle_demo"

            mimic :organization
            attribute :enabled, :boolean
            expose_to_javascript :enabled
          end

          SettingsTabRegistry.find(:organization_settings).register_form_tab(
            :toggle_demo_js,
            demo_form_class,
            UpdateModuleConfigCommand,
            module_name: :decidim_toggle_demo
          )
          true
        end
      end

      before do
        self.class.ensure_demo_tab!
        Decidim::Toggle.save_config!(organization, :decidim_toggle_demo, { "enabled" => true })
        switch_to_host(organization.host)
      end

      it "exposes window.DecidimToggle on the public site" do
        visit decidim.root_path

        expect(page.body).to include("window.DecidimToggle")
        expect(page.body).to include('"decidim_toggle_demo.enabled":true')
      end

      it "exposes window.DecidimToggle in the admin layout" do
        login_as admin, scope: :user
        visit decidim_admin.root_path

        expect(page.body).to include("window.DecidimToggle")
        expect(page.body).to include('"decidim_toggle_demo.enabled":true')
      end
    end
  end
end
