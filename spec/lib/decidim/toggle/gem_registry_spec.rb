# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe GemRegistry do
      describe ".present?" do
        it "returns true when the gem is in the bundle" do
          expect(described_class.present?("decidim-core")).to be(true)
        end

        it "returns false when the gem is not in the bundle" do
          expect(described_class.present?("decidim-space_page")).to be(false)
        end

        it "returns false for blank names" do
          expect(described_class.present?("")).to be(false)
          expect(described_class.present?(nil)).to be(false)
        end
      end
    end

    describe "Decidim::Toggle.gem_present?" do
      it "returns true for gems in the bundle" do
        expect(Decidim::Toggle.gem_present?("decidim-core")).to be(true)
      end
    end
  end
end
