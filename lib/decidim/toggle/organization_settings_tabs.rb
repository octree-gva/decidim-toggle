# frozen_string_literal: true

module Decidim
  module Toggle
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
                       position: 4

          tabs.add_tab :security,
                       t("security", scope:),
                       form: Decidim::Toggle::UpdateSecurityForm,
                       command: Decidim::Toggle::UpdateSecurityCommand,
                       position: 5

          tabs.add_custom_tab :other,
                              t("file_upload", scope:),
                              "decidim/system/organizations/file_upload_settings",
                              position: 6
        end
      end
    end
  end
end
