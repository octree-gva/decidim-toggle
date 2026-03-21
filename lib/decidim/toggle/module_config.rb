# frozen_string_literal: true

require "decidim/toggle/module_configuration_presenter"

module Decidim
  module Toggle
    class << self
      # @param name [String, Symbol]
      # @return [String] canonical module key stored in {OrganizationModuleConfig#module_name}
      def normalize_module_name(name)
        name.to_s
      end

      # Loads JSONB for +organization+ and +module_name+.
      # When a form is registered for this module (via +add_tab ..., module_name:+), returns
      # a {ModuleConfigurationPresenter}; otherwise an indifferent hash of the raw config.
      #
      # @param registry_name [Symbol] settings registry (default +:organization_settings+)
      # @return [ModuleConfigurationPresenter, ActiveSupport::HashWithIndifferentAccess]
      def config_for(organization, module_name, registry_name: :organization_settings)
        key = normalize_module_name(module_name)
        raw = raw_config_hash(organization, key)
        entry = SettingsTabRegistry.find(registry_name)&.form_tab_for_module(key)

        if entry && entry[:form]
          form = build_form_from_hash(entry[:form], organization, raw)
          ModuleConfigurationPresenter.new(form)
        else
          raw.with_indifferent_access
        end
      end

      # Persists config for +organization+ and +module_name+.
      # Uses **shallow merge** at the top level of the JSON object: new keys overwrite, nested
      # values are replaced as a whole for a given key.
      #
      # @param attributes [Hash] coercible keys (string or symbol)
      # @param merge [Boolean] when +true+ (default), merges into existing config; when +false+, replaces
      def save_config!(organization, module_name, attributes, merge: true)
        key = normalize_module_name(module_name)
        record = OrganizationModuleConfig.find_or_initialize_by(
          decidim_organization_id: organization.id,
          module_name: key
        )
        incoming = stringify_keys(attributes)
        record.config = merge ? (record.config || {}).stringify_keys.merge(incoming) : incoming
        record.save!
        record
      end

      private

      def build_form_from_hash(form_class, organization, raw_hash)
        form_class.from_params(organization: raw_hash).with_context(current_organization: organization)
      end

      def raw_config_hash(organization, module_name)
        OrganizationModuleConfig.find_by(
          decidim_organization_id: organization.id,
          module_name:
        )&.config || {}
      end

      def stringify_keys(hash)
        hash.to_h.stringify_keys.transform_values do |v|
          case v
          when Hash
            stringify_keys(v)
          when Array
            v.map { |e| e.is_a?(Hash) ? stringify_keys(e) : e }
          else
            v
          end
        end
      end
    end
  end
end
