# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateAuthorizationsCommand do
      let(:organization) { create(:organization, available_authorizations: []) }

      it "updates available_authorizations when form is valid" do
        form = UpdateAuthorizationsForm.from_params(
          organization: { available_authorizations: %w(dummy_authorization_handler) }
        ).with_context(current_organization: organization)

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call

        expect(outcomes).to eq([:ok])
        expect(organization.reload.available_authorizations).to eq(%w(dummy_authorization_handler))
      end

      it "broadcasts invalid when form is invalid" do
        form = UpdateAuthorizationsForm.from_params(
          organization: { available_authorizations: %w(not_a_real_workflow) }
        ).with_context(current_organization: organization)

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call

        expect(outcomes).to eq([:invalid])
        expect(organization.reload.available_authorizations).to eq([])
      end

      context "when the ephemeral gem is loaded but available_authorizations is a string array" do
        before do
          allow(Decidim::Toggle).to receive(:ephemeral_participation?).and_return(true)
        end

        it "persists handler names and does not assign a Hash" do
          form = UpdateAuthorizationsForm.from_params(
            organization: {
              available_authorizations: %w(dummy_authorization_handler),
              ephemeral_participation_authorization: "dummy_authorization_handler"
            }
          ).with_context(current_organization: organization)

          outcomes = []
          cmd = described_class.new(organization, form)
          cmd.on(:ok) { outcomes << :ok }
          cmd.on(:invalid) { outcomes << :invalid }
          cmd.call

          expect(outcomes).to eq([:ok])
          expect(organization.reload.available_authorizations).to eq(%w(dummy_authorization_handler))
        end
      end

      context "when ephemeral participation is loaded" do
        before do
          allow(Decidim::Toggle).to receive(:ephemeral_authorizations_hash?).and_return(true)
        end

        it "persists the Hash shape with allow_ephemeral_participation" do
          form = UpdateAuthorizationsForm.from_params(
            organization: {
              available_authorizations: %w(dummy_authorization_handler),
              ephemeral_participation_authorization: "dummy_authorization_handler"
            }
          ).with_context(current_organization: organization)

          allow(organization).to receive(:available_authorizations=)
          allow(organization).to receive(:save!).and_return(true)

          outcomes = []
          cmd = described_class.new(organization, form)
          cmd.on(:ok) { outcomes << :ok }
          cmd.call

          expect(outcomes).to eq([:ok])
          expect(organization).to have_received(:available_authorizations=).with(
            "dummy_authorization_handler" => { "allow_ephemeral_participation" => true }
          )
        end
      end
    end
  end
end
