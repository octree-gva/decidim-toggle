# frozen_string_literal: true

module Decidim
  module Toggle
    module ExposeAttributesToJsValidator
      module_function

      def validate!
        registry = SettingsTabRegistry.find(:organization_settings)
        return unless registry

        registry.ensure_configurations_applied!
        registry.module_configs.each_value do |entry|
          validate_form!(entry[:form])
        end
      end

      def validate_form!(form_class)
        return unless form_class
        return unless form_class.included_modules.include?(ExposeAttributesToJs)

        form_class.javascript_exposed_attribute_names.each do |attr|
          warn_unknown_attribute(form_class, attr)
          warn_encrypted_attribute(form_class, attr)
        end
      end

      def warn_unknown_attribute(form_class, attr)
        return if form_class.attribute_names.include?(attr)

        Rails.logger.warn(
          "[decidim-toggle] #{form_class} exposes unknown attribute #{attr.inspect} to JS"
        )
      end

      def warn_encrypted_attribute(form_class, attr)
        return unless form_class.respond_to?(:encrypted_attribute?)
        return unless form_class.encrypted_attribute?(attr)

        Rails.logger.warn(
          "[decidim-toggle] #{form_class} must not expose encrypted attribute #{attr.inspect} to JS"
        )
      end
    end
  end
end
