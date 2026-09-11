# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe ExposeAttributesToJsValidator do
      it "warns when an exposed attribute is not declared on the form" do
        form_class = Class.new(Decidim::Form) do
          include ExposeAttributesToJs

          mimic :organization
          attribute :enabled, :boolean

          expose_to_javascript :missing_flag
        end

        expect(Rails.logger).to receive(:warn).with(
          /decidim-toggle.*missing_flag/
        )

        described_class.validate_form!(form_class)
      end

      it "validates every registered organization settings form without error" do
        expect { described_class.validate! }.not_to raise_error
      end

      it "warns when an encrypted attribute is exposed to JS" do
        form_class = Class.new(Decidim::Form) do
          include ModuleConfigForm
          include ExposeAttributesToJs

          self.module_config_name = "decidim_warn_secret"
          mimic :organization
          attribute :api_key, :string
          encrypted :api_key
          expose_to_javascript :api_key
        end

        expect(Rails.logger).to receive(:warn).with(
          /must not expose encrypted attribute "api_key"/
        )

        described_class.validate_form!(form_class)
      end
    end
  end
end
