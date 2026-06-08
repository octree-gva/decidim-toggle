# frozen_string_literal: true

module Decidim
  module Toggle
    module SystemSettingsTabHelper
      def decidim_toggle_settings_tab_form(organization, tab, &block)
        tab_form = tab.form_class.from_model(organization)
        form_with(
          url: decidim_toggle_update_settings_tab_organization_path(organization, tab_id: tab.identifier),
          model: tab_form,
          scope: :organization,
          builder: Decidim::Toggle::SettingsFormBuilder,
          method: :patch,
          html: { id: "settings_tab_form_#{tab.identifier}" },
          local: true
        ) do |tf|
          safe_join([
                      render("decidim_toggle/system/organizations/settings_tab_active_tab_field", tab:),
                      tf.informative_callouts,
                      content_tag(:div, class: "form__wrapper") { capture(tf, &block) },
                      render("decidim_toggle/system/organizations/settings_tab_submit", form: tf)
                    ])
        end
      end
    end
  end
end
