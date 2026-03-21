# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateSecurityCommand do
      let(:organization) { create(:organization) }

      it "updates security fields when form is valid" do
        form = UpdateSecurityForm.from_model(organization)
        form.force_users_to_authenticate_before_access_organization = true
        form.users_registration_mode = "enabled"

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:ok])
        expect(organization.reload.force_users_to_authenticate_before_access_organization).to be true
      end

      it "broadcasts invalid when form is invalid" do
        form = UpdateSecurityForm.from_model(organization)
        form.users_registration_mode = "not_a_mode"

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:invalid])
      end
    end
  end
end
