# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "encrypted settings blank save" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:admin) }
      let(:plaintext) { "keep-secret" }
      let(:path) { "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/toggle_secret" }

      before do
        EncryptedSettingsForm.register_tab!
        EncryptedSettingsForm.persist_secret!(organization, plaintext)
        login_as admin, scope: :admin
      end

      it "keeps the previous secret when the password field is left blank" do
        ciphertext = OrganizationModuleConfig.find_by!(
          decidim_organization_id: organization.id,
          module_name: "decidim_toggle_secret"
        ).config["api_key"]

        patch path, params: { organization: { api_key: "" } }

        expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
        row = OrganizationModuleConfig.find_by!(
          decidim_organization_id: organization.id,
          module_name: "decidim_toggle_secret"
        )
        expect(row.config["api_key"]).to eq(ciphertext)
        expect(Decidim::AttributeEncryptor.decrypt(row.config["api_key"])).to eq(plaintext)
      end
    end
  end
end
