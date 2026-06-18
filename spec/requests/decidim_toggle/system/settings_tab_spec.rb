# frozen_string_literal: true

require "spec_helper"

describe "DecidimToggle::System::SettingsTabController" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:admin) }

  before { login_as admin, scope: :admin }

  describe "PATCH /decidim_toggle/system/organizations/:organization_id/settings_tab/:tab_id" do
    let(:path) { "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/security" }
    let(:valid_params) do
      {
        organization: {
          force_users_to_authenticate_before_access_organization: "1",
          users_registration_mode: "enabled"
        }
      }
    end

    it "updates the tab and redirects with notice" do
      patch path, params: valid_params

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:notice]).to eq(I18n.t("decidim_toggle.system.organizations.form_tab.success"))
      expect(organization.reload.force_users_to_authenticate_before_access_organization).to be(true)
    end

    it "redirects with anchor when active tab param matches a registered tab" do
      patch path, params: valid_params.merge(decidim_toggle_active_tab: "security")

      expect(response).to redirect_to(
        decidim_system.edit_organization_path(organization, anchor: "panel-toggle-security")
      )
    end

    it "ignores unknown active tab ids when building the redirect anchor" do
      patch path, params: valid_params.merge(decidim_toggle_active_tab: "not-a-tab")

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
    end

    it "returns not found for unknown tab ids" do
      patch "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/unknown"

      expect(response).to have_http_status(:not_found)
    end

    it "redirects with alert when the form is invalid" do
      patch path, params: { organization: { users_registration_mode: "not_a_mode" } }

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:alert]).to be_present
    end
  end
end
