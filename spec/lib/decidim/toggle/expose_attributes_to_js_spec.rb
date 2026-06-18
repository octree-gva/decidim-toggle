# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe ExposeAttributesToJs do
      let(:form_class) do
        Class.new(Decidim::Form) do
          include ExposeAttributesToJs

          mimic :organization
          attribute :enabled, :boolean
          attribute :search_bar, :boolean
          attribute :secret, :string

          expose_to_javascript :enabled, :search_bar
        end
      end

      it "registers attributes via expose_to_javascript" do
        expect(form_class.javascript_exposed_attribute_names).to contain_exactly("enabled", "search_bar")
      end

      it "deduplicates exposed attribute names" do
        form_class.expose_to_javascript(:enabled)
        expect(form_class.javascript_exposed_attribute_names).to contain_exactly("enabled", "search_bar")
      end
    end
  end
end
