# frozen_string_literal: true

module Decidim
  module Toggle
    # Include in a {Decidim::Form} used with +add_tab ..., module_name:+ so +from_model(organization)+
    # loads JSON from {OrganizationModuleConfig} and +UpdateModuleConfigCommand+ can persist it.
    # Field labels resolve from +decidim_toggle.system.<module_config_name>+ (see integrate/labels.md).
    #
    #   class MyModule::AdminConfigForm < Decidim::Form
    #     include Decidim::Toggle::ModuleConfigForm
    #
    #     self.module_config_name = "decidim_geo"
    #     mimic :organization
    #     attribute :enabled, :boolean
    #     attribute :api_key, :string
    #     encrypted :api_key
    #   end
    module ModuleConfigForm
      extend ActiveSupport::Concern

      class_methods do
        def human_attribute_name(attr, options = {})
          ModuleConfigI18n.translate_label(module_config_name, attr) || super
        end

        def from_model(organization)
          raise NotImplementedError, "#{name} must set self.module_config_name = \"...\"" if module_config_name.blank?

          raw = OrganizationModuleConfig.find_by(
            decidim_organization_id: organization.id,
            module_name: module_config_name
          )&.config || {}

          build_from_raw(organization, raw)
        end

        def build_from_raw(organization, raw)
          form = from_params(organization: raw).with_context(current_organization: organization)
          EncryptedAttributes.clear_plaintext!(form)
          form
        end
      end

      included do
        include EncryptedAttributes

        class_attribute :module_config_name, instance_accessor: false
      end
    end
  end
end
