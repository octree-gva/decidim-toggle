# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe "encrypted settings edit secret", :js do
      let(:organization) { create(:organization) }
      let(:admin) { create(:admin) }

      before do
        EncryptedSettingsForm.register_tab!
        EncryptedSettingsForm.persist_secret!(organization, "secret")
        login_as admin, scope: :admin
      end

      it "reveals an empty password field when edit secret is clicked" do
        visit decidim_system.edit_organization_path(organization)
        click_on "Toggle secret"
        click_on "edit secret"

        field = find("#settings_tab_form_toggle_secret input[type=password]")
        expect(field).to be_visible
        expect(field.value).to eq("")
        expect(page).to have_no_css(".encrypted-secret-mask", visible: :visible)
      end
    end
  end
end
