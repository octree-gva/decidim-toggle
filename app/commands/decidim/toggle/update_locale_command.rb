# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateLocaleCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_organization_locales
          rebuild_search_index
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :organization, :form

      def update_organization_locales
        organization.available_locales = form.clean_available_locales
        organization.default_locale = form.default_locale
        if organization.respond_to?(:enable_machine_translations=)
          organization.enable_machine_translations = form.enable_machine_translations
          organization.machine_translation_display_priority = form.machine_translation_display_priority || "original"
        end
        organization.save!
      end

      def rebuild_search_index
        Rake::Task["decidim:locales:rebuild_search"].reenable
        Rake::Task["decidim:locales:rebuild_search"].invoke
      end
    end
  end
end
