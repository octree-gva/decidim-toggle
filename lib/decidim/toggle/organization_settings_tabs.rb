# frozen_string_literal: true

module Decidim
  module Toggle
    # Registers default system organization settings tabs.
    #
    # Extension contract: the authorizations tab uses the stable identifier
    # +:authorizations+ (vanilla Decidim: string array of verification workflow names).
    # Another engine may register an additional +Decidim::Toggle.settings_tabs+
    # block **after** +decidim_toggle.organization_settings_tabs+ and call
    # +remove_tab(:authorizations)+ then +add_tab(:authorizations, ...)+ with the
    # same identifier to replace the tab. The last +register_form_tab+ for that id
    # wins; see {Decidim::Toggle::SettingsTabRegistry#register_form_tab}.
    class OrganizationSettingsTabs
      def self.register!
        scope = "decidim_toggle.system.organizations.settings_tabs"
        Decidim::Toggle.settings_tabs :organization_settings do |tabs|
          tabs.add_tab :name,
                       t("name", scope:),
                       form: Decidim::Toggle::UpdateNameForm,
                       command: Decidim::Toggle::UpdateNameCommand,
                       position: 1, open: true

          tabs.add_custom_tab :registration,
                              t("registration", scope:),
                              "decidim/system/organizations/omniauth_settings",
                              position: 2

          tabs.add_custom_tab :emails,
                              t("emails", scope:),
                              "decidim/system/organizations/smtp_settings",
                              position: 3

          tabs.add_tab :language,
                       t("language", scope:),
                       form: Decidim::Toggle::UpdateLocaleForm,
                       command: Decidim::Toggle::UpdateLocaleCommand,
                       position: 4,
                       form_layout_partial: "decidim_toggle/system/organizations/language_tab"

          tabs.add_tab :authorizations,
                       t("authorizations", scope:),
                       form: Decidim::Toggle::UpdateAuthorizationsForm,
                       command: Decidim::Toggle::UpdateAuthorizationsCommand,
                       position: 5,
                       form_layout_partial: "decidim_toggle/system/organizations/authorizations_tab"

          tabs.add_tab :security,
                       t("security", scope:),
                       form: Decidim::Toggle::UpdateSecurityForm,
                       command: Decidim::Toggle::UpdateSecurityCommand,
                       form_layout_partial: "decidim_toggle/system/organizations/security_tab",
                       position: 6

          tabs.add_custom_tab :other,
                              t("file_upload", scope:),
                              "decidim/system/organizations/file_upload_settings",
                              position: 7
        end
      end
    end
  end
end
