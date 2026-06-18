# frozen_string_literal: true

module Decidim
  module Toggle
    class JavascriptConfig
      SUPPORTED_VALUE_CLASSES = [TrueClass, FalseClass, String, Integer, Float, NilClass].freeze

      class << self
        def for(organization, registry_name: :organization_settings)
          return {} if organization.blank?

          registry = SettingsTabRegistry.find(registry_name)
          return {} unless registry

          registry.ensure_configurations_applied!
          build_from_registry(organization, registry)
        end

        private

        def build_from_registry(organization, registry)
          registry.module_configs.each_with_object({}) do |(module_name, entry), config|
            form_class = entry[:form]
            next unless form_class&.included_modules&.include?(ExposeAttributesToJs)

            exposed = form_class.javascript_exposed_attribute_names
            next if exposed.empty?

            presenter = Decidim::Toggle.config_for(organization, module_name, registry_name: registry.registry_name)
            merge_exposed_attributes!(config, module_name, presenter, form_class, exposed)
          end
        end

        def merge_exposed_attributes!(config, module_name, presenter, form_class, exposed)
          exposed.each do |attr|
            type = form_class.attribute_types[attr]
            raw = presenter.public_send(attr)
            value = serialize_value(raw, type)
            next if value.nil? && !supported_scalar?(raw)

            config["#{module_name}.#{attr}"] = value
          end
        end

        def serialize_value(value, _type)
          return value if supported_scalar?(value)
          return value.map { |element| serialize_element(element) } if value.is_a?(Array)
          return stringify_hash(value) if value.is_a?(Hash)

          warn_unsupported_type(value)
          nil
        end

        def supported_scalar?(value)
          SUPPORTED_VALUE_CLASSES.any? { |klass| value.is_a?(klass) }
        end

        def serialize_element(element)
          return stringify_hash(element) if element.is_a?(Hash)

          element
        end

        def stringify_hash(hash)
          hash.to_h.transform_keys(&:to_s).transform_values do |value|
            case value
            when Hash
              stringify_hash(value)
            when Array
              value.map { |element| serialize_element(element) }
            else
              value
            end
          end
        end

        def warn_unsupported_type(value)
          return unless Rails.env.development? || Rails.env.test?

          Rails.logger.warn(
            "[decidim-toggle] Skipping unsupported JavaScript config value #{value.class}"
          )
        end
      end
    end
  end
end
