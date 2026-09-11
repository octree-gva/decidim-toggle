# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "encrypted settings last four characters" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:admin) }
      let(:plaintext) { "abcdefghijklmnopqrstuvwxyz0123456789" }

      before do
        EncryptedSettingsForm.register_tab!
        EncryptedSettingsForm.persist_secret!(organization, plaintext)
        login_as admin, scope: :admin
      end

      it "shows only the last four characters when the secret is longer than 32" do
        get decidim_system.edit_organization_path(organization)

        mask = Nokogiri::HTML(response.body).at_css("#settings_tab_form_toggle_secret .encrypted-secret-mask")
        expect(mask.text).to eq("6789")
        expect(response.body).not_to include(plaintext)
      end
    end
  end
end
