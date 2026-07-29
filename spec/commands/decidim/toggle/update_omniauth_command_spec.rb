# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateOmniauthCommand do
      let(:organization) do
        Struct.new(:omniauth_settings) do
          def save!
            @saved = true
          end

          def saved?
            !!@saved
          end
        end.new
      end

      it "updates omniauth_settings when form is valid" do
        form = instance_double(UpdateOmniauthForm, invalid?: false, encrypted_omniauth_settings: { "foo" => "bar" })

        outcomes = []
        expect(Decidim::OrganizationSettings).to receive(:reload).with(organization)

        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call

        expect(outcomes).to eq([:ok])
        expect(organization.omniauth_settings).to eq({ "foo" => "bar" })
        expect(organization).to be_saved
      end

      it "broadcasts invalid when the form is invalid" do
        form = instance_double(UpdateOmniauthForm, invalid?: true)

        outcomes = []
        expect(organization).not_to receive(:save!)
        cmd = described_class.new(organization, form)
        cmd.on(:ok) { outcomes << :ok }
        cmd.on(:invalid) { outcomes << :invalid }
        cmd.call

        expect(outcomes).to eq([:invalid])
      end

      it "broadcasts invalid when saving fails" do
        allow(organization).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(create(:organization)))

        form = instance_double(UpdateOmniauthForm, invalid?: false, encrypted_omniauth_settings: { "foo" => "bar" })

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
