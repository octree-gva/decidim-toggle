# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe JavascriptConfig do
      let(:organization) { create(:organization) }
      let(:registry_name) { :javascript_config_spec }
      let(:registry) { SettingsTabRegistry.find(registry_name) }

      def self.ensure_registry!
        @registry_ready ||= begin
          geo_form_class = Class.new(Decidim::Form) do
            include ExposeAttributesToJs
            include ModuleConfigForm

            self.module_config_name = "decidim_geo"

            mimic :organization
            attribute :enabled, :boolean
            attribute :search_bar, :boolean
            attribute :tags, [String]
            attribute :secret, :string

            expose_to_javascript :enabled, :search_bar, :tags
          end

          other_form_class = Class.new(Decidim::Form) do
            include ExposeAttributesToJs
            include ModuleConfigForm

            self.module_config_name = "decidim_other"

            mimic :organization
            attribute :mode, :string
            expose_to_javascript :mode
          end

          test_registry = SettingsTabRegistry.create(:javascript_config_spec)
          test_registry.register_form_tab(:geo, geo_form_class, Integer, module_name: :decidim_geo)
          test_registry.register_form_tab(:other, other_form_class, Integer, module_name: :decidim_other)
          test_registry.mark_configurations_applied!
          true
        end
      end

      def self.reset_registry!
        SettingsTabRegistry.destroy(:javascript_config_spec) if SettingsTabRegistry.find(:javascript_config_spec)
        remove_instance_variable(:@registry_ready) if instance_variable_defined?(:@registry_ready)
        ensure_registry!
      end

      before do
        self.class.reset_registry!
      end

      # rubocop:disable RSpec/BeforeAfterAll -- isolated registry for this file
      after(:context) do
        SettingsTabRegistry.destroy(:javascript_config_spec)
      end
      # rubocop:enable RSpec/BeforeAfterAll

      it "returns an empty hash without organization" do
        expect(described_class.for(nil, registry_name:)).to eq({})
      end

      it "builds flat dot-notation keys from exposed attributes" do
        Decidim::Toggle.save_config!(
          organization,
          :decidim_geo,
          { "enabled" => true, "search_bar" => false, "tags" => %w(a b), "secret" => "hidden" }
        )
        Decidim::Toggle.save_config!(organization, :decidim_other, { "mode" => "live" })

        expect(described_class.for(organization, registry_name:)).to eq(
          "decidim_geo.enabled" => true,
          "decidim_geo.search_bar" => false,
          "decidim_geo.tags" => %w(a b),
          "decidim_other.mode" => "live"
        )
      end

      it "skips forms without ExposeAttributesToJs" do
        plain_form = Class.new(Decidim::Form) do
          include ModuleConfigForm

          self.module_config_name = "decidim_plain"
          mimic :organization
          attribute :enabled, :boolean
        end

        registry.register_form_tab(:plain, plain_form, Integer, module_name: :decidim_plain)
        Decidim::Toggle.save_config!(organization, :decidim_plain, { "enabled" => true })

        expect(described_class.for(organization, registry_name:)).not_to have_key("decidim_plain.enabled")
      end

      it "skips unsupported scalar types with a warning in test" do
        expect(Rails.logger).to receive(:warn).with(/Skipping unsupported JavaScript config value/)

        expect(described_class.send(:serialize_value, Object.new, nil)).to be_nil
      end

      it "stringifies nested hashes and arrays inside hash values" do
        nested_form_class = Class.new(Decidim::Form) do
          include ExposeAttributesToJs
          include ModuleConfigForm

          self.module_config_name = "decidim_nested"

          mimic :organization
          attribute :settings, Object
          expose_to_javascript :settings
        end

        registry.register_form_tab(:nested, nested_form_class, Integer, module_name: :decidim_nested)
        Decidim::Toggle.save_config!(
          organization,
          :decidim_nested,
          { "settings" => { labels: %w(a b), meta: { "count" => 2 } } }
        )

        expect(described_class.for(organization, registry_name:)).to include(
          "decidim_nested.settings" => { "labels" => %w(a b), "meta" => { "count" => 2 } }
        )
      end

      context "with translatable attributes" do
        def self.ensure_translatable_form!
          @translatable_ready ||= begin
            translatable_form_class = Class.new(Decidim::Form) do
              include Decidim::TranslatableAttributes
              include ExposeAttributesToJs
              include ModuleConfigForm

              self.module_config_name = "decidim_i18n"

              mimic :organization
              translatable_attribute :title, String
              expose_to_javascript :title
            end

            SettingsTabRegistry.find(:javascript_config_spec).register_form_tab(
              :i18n, translatable_form_class, Integer, module_name: :decidim_i18n
            )
            true
          end
        end

        before do
          self.class.ensure_translatable_form!
          Decidim::Toggle.save_config!(
            organization,
            :decidim_i18n,
            { "title" => { "en" => "Hello", "ca" => "Hola" } }
          )
        end

        it "exposes the raw locale hash" do
          expect(described_class.for(organization, registry_name:)["decidim_i18n.title"]).to eq(
            "en" => "Hello",
            "ca" => "Hola"
          )
        end
      end
    end
  end
end
