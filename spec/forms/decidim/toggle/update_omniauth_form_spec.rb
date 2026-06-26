# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateOmniauthForm do
      let(:organization) { create(:organization) }

      it "exposes host and users_registration_mode from the organization" do
        form = described_class.from_model(organization)

        expect(form.host).to eq(organization.host)
        expect(form.users_registration_mode).to eq(organization.users_registration_mode)
      end

      it "extracts host/users_registration_mode from params[:organization]" do
        current_host = organization.host
        organization.update!(host: "current-host.example.org")

        params_host = "params-host.example.org"
        params = {
          organization: {
            host: params_host,
            users_registration_mode: organization.users_registration_mode
          }
        }

        form = described_class.from_params(params).with_context(current_organization: organization)

        expect(form.host).to eq(params_host)
        expect(form.users_registration_mode).to eq(organization.users_registration_mode)
        expect(form.host).not_to eq(current_host)
      end

      it "builds omniauth encrypted settings from params[:organization]" do
        provider = Decidim::OmniauthProvider.available.keys.first
        omniauth_secrets = Rails.application.secrets.dig(:omniauth, provider) || {}

        # Pick the first setting other than :enabled. For `developer` this is typically :icon.
        setting_key = (omniauth_secrets.keys.map(&:to_sym) - [:enabled]).first
        skip "No omniauth provider settings found in secrets" if provider.blank? || setting_key.blank?

        params = {
          organization: {
            :host => organization.host,
            :users_registration_mode => organization.users_registration_mode,
            "omniauth_settings_#{provider}_enabled" => true,
            "omniauth_settings_#{provider}_#{setting_key}" => "foo-#{setting_key}"
          }
        }

        form = described_class.from_params(params).with_context(current_organization: organization)

        expect(form.omniauth_settings).to include(
          "omniauth_settings_#{provider}_enabled" => true,
          "omniauth_settings_#{provider}_#{setting_key}" => "foo-#{setting_key}"
        )
        expect(form.encrypted_omniauth_settings).to include("omniauth_settings_#{provider}_#{setting_key}")
      end

      it "registers space page info callout only when decidim-space_page is in the bundle" do
        form = described_class.from_params({})
        entries = form.visible_informative_callouts

        if Decidim::Toggle.gem_present?("decidim-space_page")
          expect(entries.map(&:type)).to eq([:info])
          expect(entries.first.message_for(form)).to include("decidim space page")
        else
          expect(entries).to be_empty
        end
      end

      it "is valid and executes the uniqueness validation hook (no-op)" do
        form = described_class.from_model(organization)

        expect(form).to receive(:validate_organization_uniqueness).and_call_original
        expect(form).to be_valid
      end
    end
  end
end
