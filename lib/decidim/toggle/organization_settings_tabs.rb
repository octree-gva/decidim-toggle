# frozen_string_literal: true

module Decidim
  module Toggle
    # Registers default system organization settings tabs.
    #
    # Extension contract: the authorizations tab uses the stable identifier
    # +:authorizations+. Vanilla Decidim persists a string array of workflow names.
    # When +Decidim::EphemeralParticipation+ is loaded, Toggle persists a Hash with
    # +allow_ephemeral_participation+ (see {UpdateAuthorizationsForm}).
    # Another engine may still +remove_tab(:authorizations)+ then +add_tab+ to replace it.
    class OrganizationSettingsTabs
      def self.register!
        scope = "decidim_toggle.system.organizations.settings_tabs"
        Decidim::Toggle.settings_tabs :organization_settings do |tabs|
          tabs.add_tab :name,
                       t("name", scope:),
                       form: Decidim::Toggle::UpdateNameForm,
                       command: Decidim::Toggle::UpdateNameCommand,
                       position: 1, open: true

          tabs.add_tab :omniauth,
                       t("omniauth", scope:),
                       form: Decidim::Toggle::UpdateOmniauthForm,
                       command: Decidim::Toggle::UpdateOmniauthCommand,
                       position: 2,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/omniauth_tab"

          tabs.add_tab :emails,
                       t("emails", scope:),
                       form: Decidim::Toggle::UpdateEmailsForm,
                       command: Decidim::Toggle::UpdateEmailsCommand,
                       position: 3,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/emails_tab"

          tabs.add_tab :language,
                       t("language", scope:),
                       form: Decidim::Toggle::UpdateLocaleForm,
                       command: Decidim::Toggle::UpdateLocaleCommand,
                       position: 4,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/language_tab"

          tabs.add_tab :authorizations,
                       t("authorizations", scope:),
                       form: Decidim::Toggle::UpdateAuthorizationsForm,
                       command: Decidim::Toggle::UpdateAuthorizationsCommand,
                       position: 5,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/authorizations_tab"

          tabs.add_tab :security,
                       t("security", scope:),
                       form: Decidim::Toggle::UpdateSecurityForm,
                       command: Decidim::Toggle::UpdateSecurityCommand,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/security_tab",
                       position: 6

          tabs.add_tab :other,
                       t("file_upload", scope:),
                       form: Decidim::Toggle::UpdateFileUploadSettingsForm,
                       command: Decidim::Toggle::UpdateFileUploadSettingsCommand,
                       position: 7,
                       form_layout_partial: "decidim_toggle/system/organizations/tabs/file_upload_tab"
        end
      end
    end
  end
end
