# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateEmailsForm do
      let(:organization) { create(:organization) }

      it "exposes host and users_registration_mode from the organization" do
        form = described_class.from_model(organization)

        expect(form.host).to eq(organization.host)
        expect(form.users_registration_mode).to eq(organization.users_registration_mode)
      end

      it "extracts host/users_registration_mode from params[:organization]" do
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
      end

      it "is valid and executes the uniqueness validation hook (no-op)" do
        form = described_class.from_model(organization)

        expect(form).to receive(:validate_organization_uniqueness).and_call_original
        expect(form).to be_valid
      end
    end
  end
end
