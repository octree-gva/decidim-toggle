# frozen_string_literal: true

require "decidim/system/base_organization_form"

module Decidim
  module Toggle
    class UpdateOmniauthForm < Decidim::System::BaseOrganizationForm
      mimic :organization

      # This tab only updates a small JSONB slice (omniauth settings).
      # The generic system form validates presence of `host` and `users_registration_mode`,
      # so fall back to the current organization when those attributes aren't part of
      # the tab payload.
      def host
        super.presence || current_organization&.host
      end

      def users_registration_mode
        super.presence || current_organization&.users_registration_mode
      end

      private

      # No-op: this tab doesn't touch organization identity/uniqueness.
      def validate_organization_uniqueness
        # intentionally blank
      end
    end
  end
end

