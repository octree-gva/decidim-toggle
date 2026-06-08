# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe SettingsTabRegistry do
      after do
        described_class.destroy(:test_registry)
      end

      describe ".register" do
        it "creates registry and stores configuration blocks" do
          described_class.register(:test_registry) { |_tabs| nil }
          described_class.register(:test_registry) { |_tabs| nil }
          reg = described_class.find(:test_registry)
          expect(reg.configurations.length).to eq(2)
        end
      end

      describe ".find / .create" do
        it "returns nil when missing" do
          expect(described_class.find(:missing)).to be_nil
        end

        it "create stores a new registry" do
          r = described_class.create(:test_registry)
          expect(described_class.find(:test_registry)).to eq(r)
        end
      end

      describe "#register_form_tab and #form_tab" do
        it "stores form/command mapping" do
          reg = described_class.create(:test_registry)
          reg.register_form_tab(:foo, String, Integer)
          expect(reg.form_tab(:foo)).to eq(form: String, command: Integer)
        end

        it "stores module_name for #form_tab_for_module" do
          reg = described_class.create(:test_registry)
          reg.register_form_tab(:foo, String, Integer, module_name: :decidim_geo)
          expect(reg.form_tab_for_module(:decidim_geo)).to eq(
            form: String,
            command: Integer,
            tab_identifier: :foo
          )
        end

        it "drops module mapping when the same tab is re-registered without module_name" do
          reg = described_class.create(:test_registry)
          reg.register_form_tab(:foo, String, Integer, module_name: :decidim_geo)
          reg.register_form_tab(:foo, String, Integer)
          expect(reg.form_tab_for_module(:decidim_geo)).to be_nil
        end

        it "raises when the same tab id is re-registered with a different form in test" do
          reg = described_class.create(:test_registry)
          reg.register_form_tab(:foo, String, Integer)
          expect do
            reg.register_form_tab(:foo, Array, Integer)
          end.to raise_error(Decidim::Toggle::DuplicateTabRegistrationError, /:foo/)
        end
      end
    end
  end
end
