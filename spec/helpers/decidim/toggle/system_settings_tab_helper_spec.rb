# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SystemSettingsTabHelper do
      describe "#decidim_toggle_update_settings_tab_organization_path" do
        let(:helper_host) do
          Class.new do
            include Decidim::Toggle::SystemSettingsTabHelper
          end.new
        end

        it "prefixes engine path with /decidim_toggle once" do
          org = create(:organization)
          path = helper_host.decidim_toggle_update_settings_tab_organization_path(org, tab_id: "name")
          expect(path).to start_with("/decidim_toggle")
          expect(path).to include("settings_tab")
          expect(path).not_to include("/decidim_toggle/decidim_toggle")
        end
      end

      describe "#decidim_toggle_settings_tab_form" do
        let(:helper_host) do
          Class.new do
            include Decidim::Toggle::SystemSettingsTabHelper
            include ActionView::Helpers::FormHelper
            include ActionView::Helpers::FormTagHelper
            include ActionView::Helpers::OutputSafetyHelper
            include ActionView::Context

            def flash
              @flash ||= {}
            end
          end.new
        end

        let(:tab) do
          SettingsTabItem.new(
            :security,
            "Security",
            form_class: UpdateSecurityForm,
            command_class: UpdateSecurityCommand
          )
        end
        let(:form) { UpdateSecurityForm.from_params(organization: { host: "example.org", users_registration_mode: "enabled" }) }
        let(:organization) { instance_double(Decidim::Organization, id: 1) }

        before do
          allow(UpdateSecurityForm).to receive(:from_model).with(organization).and_return(form)
          allow(helper_host).to receive(:render).and_return("".html_safe)
          allow(helper_host).to receive(:decidim_toggle_update_settings_tab_organization_path)
            .with(organization, tab_id: :security)
            .and_return("/decidim_toggle/system/organizations/1/settings_tab/security")
        end

        it "renders form shell markup" do
          html = helper_host.decidim_toggle_settings_tab_form(organization, tab) { |_tf| "body" }
          expect(html).to include("settings_tab_form_security")
          expect(html).to include('action="/decidim_toggle/system/organizations/1/settings_tab/security"')
        end
      end

      describe "#encryption_configured?" do
        let(:helper_host) do
          Class.new do
            include Decidim::Toggle::SystemSettingsTabHelper
          end.new
        end

        around do |example|
          Decidim::AttributeEncryptor.remove_instance_variable(:@cryptor) if Decidim::AttributeEncryptor.instance_variable_defined?(:@cryptor)
          example.run
          Decidim::AttributeEncryptor.remove_instance_variable(:@cryptor) if Decidim::AttributeEncryptor.instance_variable_defined?(:@cryptor)
        end

        it "returns true when encryption round-trips" do
          allow(Rails.application).to receive(:secret_key_base).and_return(SecureRandom.hex(64))

          expect(helper_host.encryption_configured?).to be(true)
        end

        it "returns false when secret_key_base is missing" do
          allow(Rails.application).to receive(:secret_key_base).and_return(nil)

          expect(helper_host.encryption_configured?).to be(false)
        end

        it "returns false when encryption fails" do
          allow(Rails.application).to receive(:secret_key_base).and_return("too-short")
          allow(Decidim::AttributeEncryptor).to receive(:encrypt).and_raise(ArgumentError)

          expect(helper_host.encryption_configured?).to be(false)
        end
      end
    end
  end
end
