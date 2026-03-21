# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateNameCommand < Decidim::Command
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          organization.name = form.name
          organization.host = form.host
          organization.secondary_hosts = form.clean_secondary_hosts
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
