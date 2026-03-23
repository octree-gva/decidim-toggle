# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateFileUploadSettingsForm do
      let(:organization) { create(:organization) }

      describe ".from_model" do
        it "wraps the organization file_upload_settings for editing" do
          form = described_class.from_model(organization)

          expect(form.file_upload_settings).to be_a(Decidim::System::FileUploadSettingsForm)
          expect(form.file_upload_settings.maximum_file_size).to be_present
        end
      end

      describe ".from_params" do
        it "accepts indifferent-access-like params" do
          inner = Decidim::System::FileUploadSettingsForm.from_model(organization.file_upload_settings)
          form = described_class.from_params(
            "organization" => { file_upload_settings: inner }
          ).with_context(current_organization: organization)

          expect(form.file_upload_settings).to be_a(Decidim::System::FileUploadSettingsForm)
        end
      end
    end
  end
end
