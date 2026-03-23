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
    end
  end
end
