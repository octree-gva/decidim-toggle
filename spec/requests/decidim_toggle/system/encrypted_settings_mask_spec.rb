# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "encrypted settings mask" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:admin) }

      before do
        EncryptedSettingsForm.register_tab!
        EncryptedSettingsForm.persist_secret!(organization, "secret")
        login_as admin, scope: :admin
      end

      it "shows a non-editable star mask matching the secret length" do
        get decidim_system.edit_organization_path(organization)

        expect(response.body).to include("******")
        expect(response.body).to include("edit secret")
        expect(response.body).to include("text-link")
        password = Nokogiri::HTML(response.body).at_css("#settings_tab_form_toggle_secret input[type=password]")
        expect(password["value"].to_s).to eq("")
      end
    end
  end
end
