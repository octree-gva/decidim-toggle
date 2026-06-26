# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateFileUploadSettingsCommand do
      let(:organization) { create(:organization) }

      it "updates file_upload_settings when form is valid" do
        form = UpdateFileUploadSettingsForm.from_model(organization)
        form.file_upload_settings.maximum_file_size = {
          default: 5.0,
          avatar: 2.0
        }

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call
        expect(outcomes).to eq([:ok])
        expect(organization.reload.file_upload_settings["maximum_file_size"]["default"]).to eq(5.0)
        expect(organization.file_upload_settings["maximum_file_size"]["avatar"]).to eq(2.0)
      end
    end
  end
end
