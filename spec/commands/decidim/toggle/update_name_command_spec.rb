# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateNameCommand do
      let(:organization) { create(:organization) }

      it "updates organization when form is valid" do
        form = UpdateNameForm.from_params(
          organization: {
            name_en: "New org name",
            host: organization.host,
            secondary_hosts: ""
          }
        ).with_context(current_organization: organization)

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:ok])
        expect(organization.reload.name["en"]).to eq("New org name")
      end

      it "broadcasts invalid when form is invalid" do
        form = UpdateNameForm.from_params(
          organization: {
            name_en: "",
            host: "",
            secondary_hosts: ""
          }
        ).with_context(current_organization: organization)

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
