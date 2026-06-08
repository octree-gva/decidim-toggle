# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateOmniauthCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          organization.omniauth_settings = form.encrypted_omniauth_settings
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
