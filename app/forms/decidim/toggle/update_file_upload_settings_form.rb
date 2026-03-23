# frozen_string_literal: true

module Decidim
  module Toggle
    # Wraps {Decidim::System::FileUploadSettingsForm} for the settings-tab endpoint
    # so file upload settings can be saved without submitting the full organization form.
    class UpdateFileUploadSettingsForm < Decidim::Form
      mimic :organization

      attribute :file_upload_settings, Decidim::System::FileUploadSettingsForm

      def self.from_model(organization)
        from_params(
          organization: {
            file_upload_settings: Decidim::System::FileUploadSettingsForm.from_model(organization.file_upload_settings)
          }
        )
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        super(params, additional_params)
      end
    end
  end
end
