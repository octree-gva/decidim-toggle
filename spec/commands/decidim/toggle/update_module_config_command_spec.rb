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
          attribute :api_key, :string
          encrypted :api_key
        end
      end

      def run_command(form)
        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        outcomes
      end

      describe "#call" do
        it "broadcasts :ok and persists config" do
          form = form_class.from_params(organization: { enabled: true }).with_context(current_organization: organization)

          expect(run_command(form)).to eq([:ok])
          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config["enabled"]).to be(true)
        end

        it "encrypts secrets and stores count and last4" do
          form = form_class.from_params(organization: { enabled: true, api_key: "secret" })
                           .with_context(current_organization: organization)

          expect(run_command(form)).to eq([:ok])
          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config["api_key"]).not_to eq("secret")
          expect(Decidim::AttributeEncryptor.decrypt(row.config["api_key"])).to eq("secret")
          expect(row.config["api_key_count"]).to eq(6)
          expect(row.config["api_key_last4"]).to eq("cret")
        end

        it "omits blank secrets so the previous value is kept" do
          ciphertext = Decidim::AttributeEncryptor.encrypt("keep-me")
          Decidim::Toggle.save_config!(
            organization,
            :decidim_geo,
            { "api_key" => ciphertext, "api_key_count" => 7, "api_key_last4" => "ep-me" }
          )
          form = form_class.from_params(organization: { enabled: false, api_key: "" })
                           .with_context(current_organization: organization)

          expect(run_command(form)).to eq([:ok])
          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config["api_key"]).to eq(ciphertext)
          expect(row.config["api_key_count"]).to eq(7)
          expect(row.config["enabled"]).to be(false)
        end
      end
    end
  end
end
