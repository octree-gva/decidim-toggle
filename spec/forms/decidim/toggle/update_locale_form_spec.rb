# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateLocaleForm do
      let(:organization) { create(:organization) }

      describe ".from_model" do
        it "normalizes available_locales and default_locale to strings" do
          org = Struct.new(:available_locales, :default_locale, :enable_machine_translations, :machine_translation_display_priority).new(
            %i[en ca es], :en, false, "original"
          )

          form = described_class.from_model(org)

          expect(form.available_locales).to eq(%w[en ca es])
          expect(form.default_locale).to eq("en")
        end

        it "loads locales from the Organization record when the source only has id (e.g. system UpdateOrganizationForm)" do
          org = create(:organization, available_locales: %w[en ca], default_locale: "ca")
          form_like = Struct.new(:id, :enable_machine_translations, :machine_translation_display_priority).new(
            org.id, false, "original"
          )

          form = described_class.from_model(form_like)

          expect(form.available_locales).to eq(%w[en ca])
          expect(form.default_locale).to eq("ca")
        end
      end

      describe ".from_params with hash available_locales" do
        it "maps checked keys to array" do
          form = described_class.from_params(
            organization: { available_locales: { "en" => "1", "ca" => "1" }, default_locale: "en" }
          ).with_context(current_organization: organization)

          expect(form.available_locales).to include("en", "ca")
        end
      end

      describe "validations" do
        it "rejects default_locale not in available_locales" do
          form = described_class.from_params(
            organization: { available_locales: %w(en), default_locale: "ca" }
          ).with_context(current_organization: organization)

          expect(form).not_to be_valid
        end

        it "rejects available_locales outside I18n" do
          form = described_class.from_params(
            organization: { available_locales: %w(zz), default_locale: "zz" }
          ).with_context(current_organization: organization)

          expect(form).not_to be_valid
        end
      end

      describe "collection helpers" do
        it "lists available_locales and default_locale options" do
          expect(described_class.collection_for_available_locales).to be_present
          expect(described_class.collection_for_default_locale).to be_present
        end
      end
    end
  end
end
