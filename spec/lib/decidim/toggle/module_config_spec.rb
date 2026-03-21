# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe Decidim::Toggle do
      let(:organization) { create(:organization) }

      after do
        SettingsTabRegistry.destroy(:module_config_spec)
      end

      describe ".save_config!" do
        it "creates a row and shallow-merges by default" do
          described_class.save_config!(organization, :decidim_geo, { "enabled" => true })
          described_class.save_config!(organization, :decidim_geo, { "foo" => "bar" })

          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config).to eq("enabled" => true, "foo" => "bar")
        end

        it "replaces config when merge: false" do
          described_class.save_config!(organization, :decidim_geo, { "a" => 1 })
          described_class.save_config!(organization, :decidim_geo, { "b" => 2 }, merge: false)

          row = OrganizationModuleConfig.find_by!(decidim_organization_id: organization.id, module_name: "decidim_geo")
          expect(row.config).to eq("b" => 2)
        end
      end

      describe ".config_for" do
        let(:demo_form_class) do
          Class.new(Decidim::Form) do
            mimic :organization
            attribute :enabled, :boolean
          end
        end

        it "returns indifferent hash when no form is registered for the module" do
          described_class.save_config!(organization, :unknown_mod, { "x" => 1 })
          result = described_class.config_for(organization, :unknown_mod, registry_name: :module_config_spec)
          expect(result[:x]).to eq(1)
          expect(result["x"]).to eq(1)
        end

        it "returns a presenter when a tab registered module_name with a form" do
          form_class = demo_form_class
          SettingsTabRegistry.register(:module_config_spec) do |tabs|
            tabs.add_tab :geo, "Geo", form: form_class, command: Integer, module_name: :decidim_geo
          end

          described_class.save_config!(organization, :decidim_geo, { "enabled" => true })

          result = described_class.config_for(organization, :decidim_geo, registry_name: :module_config_spec)
          expect(result).to be_a(ModuleConfigurationPresenter)
          expect(result.enabled).to be(true)
        end
      end

      describe ".normalize_module_name" do
        it "stringifies symbols" do
          expect(described_class.normalize_module_name(:decidim_geo)).to eq("decidim_geo")
        end
      end
    end
  end
end
