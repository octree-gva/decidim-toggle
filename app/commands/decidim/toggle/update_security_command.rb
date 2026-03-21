# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateSecurityCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          organization.force_users_to_authenticate_before_access_organization = form.force_users_to_authenticate_before_access_organization
          organization.users_registration_mode = form.users_registration_mode
          organization.content_security_policy = form.content_security_policy
          organization.save!
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :organization, :form
    end
  end
end
