# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateFileUploadSettingsCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          organization.file_upload_settings = form.file_upload_settings.final
          organization.save!
        end

        Decidim::OrganizationSettings.reload(organization) if defined?(Decidim::OrganizationSettings)

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :organization, :form
    end
  end
end
