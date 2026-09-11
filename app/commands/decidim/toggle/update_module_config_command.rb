# frozen_string_literal: true

module Decidim
  module Toggle
    # Persists a form that includes {ModuleConfigForm} into {OrganizationModuleConfig#config}.
    class UpdateModuleConfigCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.class.module_config_name.blank?
        return broadcast(:invalid) if form.invalid?

        Decidim::Toggle.save_config!(
          organization,
          form.class.module_config_name,
          persistable_config
        )
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :organization, :form

      def persistable_config
        return form.to_persisted_config if form.respond_to?(:to_persisted_config)

        form.to_h
      end
    end
  end
end
