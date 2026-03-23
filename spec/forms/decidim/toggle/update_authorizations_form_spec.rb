# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateAuthorizationsForm do
      let(:organization) { create(:organization, available_authorizations: []) }

      describe ".from_model" do
        it "loads workflow names as strings" do
          org = create(:organization, available_authorizations: %w(dummy_authorization_handler))

          form = described_class.from_model(org)

          expect(form.available_authorizations).to eq(%w(dummy_authorization_handler))
        end
      end

      describe ".from_params" do
        it "defaults missing available_authorizations to an empty array" do
          form = described_class.from_params(organization: {}).with_context(current_organization: organization)

          expect(form.available_authorizations).to eq([])
        end
      end

      describe "#clean_available_authorizations" do
        it "returns selected workflow names" do
          form = described_class.from_params(
            organization: { available_authorizations: %w(dummy_authorization_handler) }
          ).with_context(current_organization: organization)

          expect(form.clean_available_authorizations).to eq(%w(dummy_authorization_handler))
        end
      end

      describe "validations" do
        it "rejects authorization names that are not registered workflows" do
          form = described_class.from_params(
            organization: { available_authorizations: %w(unknown_handler) }
          ).with_context(current_organization: organization)

          expect(form).not_to be_valid
          expect(form.errors[:available_authorizations]).to be_present
        end
      end
    end
  end
end
