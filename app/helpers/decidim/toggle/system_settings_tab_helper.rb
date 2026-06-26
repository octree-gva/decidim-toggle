# frozen_string_literal: true

module Decidim
  module Toggle
    module SystemSettingsTabHelper
      ##
      # Check if Decidim can use encryption
      def encryption_configured?
        return false if Rails.application.secret_key_base.blank?

        probe = "decidim-toggle-secret-probe"
        encrypted = Decidim::AttributeEncryptor.encrypt(probe)
        return false if encrypted.blank?

        Decidim::AttributeEncryptor.decrypt(encrypted) == probe
      rescue ArgumentError, OpenSSL::Cipher::CipherError,
             ActiveSupport::MessageEncryptor::InvalidMessage,
             ActiveSupport::MessageVerifier::InvalidSignature
        false
      end

      def decidim_toggle_settings_tab_form(organization, tab, &block)
        tab_form = tab.form_class.from_model(organization)
        if (stored = flash[:decidim_toggle_invalid_settings_tab]) &&
           stored[:organization_id].to_i == organization.id &&
           stored[:tab_id].to_s == tab.identifier.to_s
          flash.delete(:decidim_toggle_invalid_settings_tab)
          tab_form = tab.form_class.from_params(organization: stored[:params])
          tab_form = tab_form.with_context(current_organization: organization) if tab_form.respond_to?(:with_context)
          stored[:errors].each do |attribute, messages|
            messages.each { |message| tab_form.errors.add(attribute, message) }
          end
        end
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
