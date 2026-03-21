# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateModuleConfigCommand do
      let(:organization) { create(:organization) }

      let(:form_class) do
        Class.new(Decidim::Form) do
          include Decidim::Toggle::ModuleConfigForm

          self.module_config_name = "decidim_geo"

          mimic :organization
          attribute :enabled, :boolean
        end
      end

      describe "#call" do
        it "broadcasts :ok and persists config" do
          form = form_class.from_params(organization: { enabled: true }).with_context(current_organization: organization)

          outcomes = []
          cmd = described_class.new(organization, form)
          cmd.on(:ok) { outcomes << :ok }
          cmd.on(:invalid) { outcomes << :invalid }
          cmd.call

          expect(outcomes).to eq([:ok])
          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config["enabled"]).to be(true)
        end

        it "broadcasts :invalid when the form is invalid" do
          form = form_class.from_params(organization: { enabled: true }).with_context(current_organization: organization)
          allow(form).to receive(:invalid?).and_return(true)

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
end
