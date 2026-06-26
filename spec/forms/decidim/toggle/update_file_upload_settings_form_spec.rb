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
    end
  end
end
