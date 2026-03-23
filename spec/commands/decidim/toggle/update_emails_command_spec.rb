# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateEmailsCommand do
      let(:organization) do
        Struct.new(:smtp_settings) do
          def save!
            @saved = true
          end

          def saved?
            !!@saved
          end
        end.new
      end

      it "updates smtp_settings when form is valid" do
        form = instance_double(UpdateEmailsForm, invalid?: false, encrypted_smtp_settings: { "host" => "smtp.example" })

        outcomes = []
        expect(Decidim::OrganizationSettings).to receive(:reload).with(organization)

        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }

        cmd.call

        expect(outcomes).to eq([:ok])
        expect(organization.smtp_settings).to eq({ "host" => "smtp.example" })
        expect(organization).to be_saved
      end

      it "broadcasts invalid when the form is invalid" do
        form = instance_double(UpdateEmailsForm, invalid?: true)

        outcomes = []
        expect(organization).not_to receive(:save!)
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }

        cmd.call

        expect(outcomes).to eq([:invalid])
        expect(organization.smtp_settings).to be_nil
      end

      it "broadcasts invalid when saving fails" do
        errors = double("errors", full_messages: [])
        invalid_record_class = Class.new do
          def initialize(record_errors)
            @errors = record_errors
          end

          def errors
            @errors
          end

          def self.i18n_scope
            "fake_scope"
          end
        end

        invalid_record = invalid_record_class.new(errors)
        allow(organization).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(invalid_record))

        form = instance_double(UpdateEmailsForm, invalid?: false, encrypted_smtp_settings: { "host" => "smtp.example" })

        outcomes = []
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }

        cmd.call

        expect(outcomes).to eq([:invalid])
      end
    end
  end
end
