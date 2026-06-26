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

    it "stores invalid tab data in flash when the form is invalid" do
      patch path, params: { organization: { users_registration_mode: "not_a_mode" } }

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:decidim_toggle_invalid_settings_tab]).to include(
        organization_id: organization.id,
        tab_id: "security"
      )
    end

    it "re-renders field errors after redirect" do
      patch path, params: { organization: { users_registration_mode: "not_a_mode" } }
      follow_redirect!

      expect(response.body).to include("form-error")
    end
  end

  describe "PATCH name tab" do
    let(:path) { "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/name" }
    let(:valid_params) do
      {
        organization: {
          name_en: "Renamed organization",
          host: "renamed.example.org",
          secondary_hosts: ""
        }
      }
    end

    it "updates host and redirects with notice" do
      patch path, params: valid_params

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:notice]).to eq(I18n.t("decidim_toggle.system.organizations.form_tab.success"))
      organization.reload
      expect(organization.host).to eq("renamed.example.org")
      expect(organization.name["en"]).to eq("Renamed organization")
    end

    it "stores invalid tab data in flash when host is blank" do
      patch path, params: { organization: { name_en: "", host: "", secondary_hosts: "" } }

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:decidim_toggle_invalid_settings_tab]).to include(
        organization_id: organization.id,
        tab_id: "name"
      )
    end
  end

  describe "PATCH language tab" do
    let(:path) { "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/language" }
    let(:organization) { create(:organization, available_locales: %w(en ca), default_locale: "ca") }

    before do
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).and_call_original
      allow(Rake::Task).to receive(:[]).with("decidim:locales:rebuild_search").and_return(
        instance_double(Rake::Task, invoke: nil, reenable: nil)
      )
    end

    it "updates available locales and default locale" do
      patch path, params: {
        organization: {
          available_locales: { "en" => "1" },
          default_locale: "en",
          enable_machine_translations: false,
          machine_translation_display_priority: "original"
        }
      }

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      organization.reload
      expect(organization.available_locales).to eq(%w(en))
      expect(organization.default_locale).to eq("en")
    end

    it "stores invalid tab data when default locale is not enabled" do
      patch path, params: {
        organization: {
          available_locales: { "en" => "1" },
          default_locale: "ca"
        }
      }

      expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
      expect(flash[:decidim_toggle_invalid_settings_tab]).to include(
        organization_id: organization.id,
        tab_id: "language"
      )
    end
  end
end
