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

        context "when ephemeral participation is loaded" do
          before do
            allow(Decidim::Toggle).to receive(:ephemeral_authorizations_hash?).and_return(true)
          end

          it "loads enabled names and the ephemeral workflow from a Hash" do
            org = create(:organization, available_authorizations: [])
            allow(org).to receive(:read_attribute).and_call_original
            allow(org).to receive(:read_attribute).with(:available_authorizations).and_return(
              {
                "dummy_authorization_handler" => { "allow_ephemeral_participation" => true },
                "another_dummy_authorization_handler" => { "allow_ephemeral_participation" => false }
              }
            )

            form = described_class.from_model(org)

            expect(form.available_authorizations).to contain_exactly(
              "dummy_authorization_handler",
              "another_dummy_authorization_handler"
            )
            expect(form.ephemeral_participation_authorization).to eq("dummy_authorization_handler")
          end
        end
      end

      describe ".from_params" do
        it "defaults missing available_authorizations to an empty array" do
          form = described_class.from_params(organization: {}).with_context(current_organization: organization)

          expect(form.available_authorizations).to eq([])
        end
      end

      describe "#clean_available_authorizations" do
        it "returns a string array in vanilla mode" do
          form = described_class.from_params(
            organization: { available_authorizations: %w(dummy_authorization_handler) }
          )

          expect(form.clean_available_authorizations).to eq(%w(dummy_authorization_handler))
        end

        context "when the ephemeral gem is loaded but the column is still a string array" do
          before do
            allow(Decidim::Toggle).to receive(:ephemeral_participation?).and_return(true)
          end

          it "returns handler names, not a Hash" do
            form = described_class.from_params(
              organization: {
                available_authorizations: %w(dummy_authorization_handler),
                ephemeral_participation_authorization: "dummy_authorization_handler"
              }
            )

            expect(form.clean_available_authorizations).to eq(%w(dummy_authorization_handler))
          end
        end

        context "when ephemeral participation is loaded" do
          before do
            allow(Decidim::Toggle).to receive(:ephemeral_authorizations_hash?).and_return(true)
          end

          it "returns a Hash with the ephemeral flag" do
            form = described_class.from_params(
              organization: {
                available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler),
                ephemeral_participation_authorization: "dummy_authorization_handler"
              }
            )

            expect(form.clean_available_authorizations).to eq(
              "dummy_authorization_handler" => { "allow_ephemeral_participation" => true },
              "another_dummy_authorization_handler" => { "allow_ephemeral_participation" => false }
            )
          end
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

        context "when ephemeral participation is loaded" do
          before do
            allow(Decidim::Toggle).to receive(:ephemeral_authorizations_hash?).and_return(true)
          end

          it "rejects an ephemeral workflow that is not enabled" do
            form = described_class.from_params(
              organization: {
                available_authorizations: %w(dummy_authorization_handler),
                ephemeral_participation_authorization: "another_dummy_authorization_handler"
              }
            ).with_context(current_organization: organization)

            expect(form).not_to be_valid
            expect(form.errors[:ephemeral_participation_authorization]).to be_present
          end
        end
      end
    end
  end
end
