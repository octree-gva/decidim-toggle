# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Toggle do
    it "has a version" do
      expect(Decidim::Toggle.version).to be_present
    end

    it "defines decidim_version" do
      expect(Decidim::Toggle.decidim_version).to eq("~> 0.29")
    end

    describe "Engine" do
      it "isolates the namespace" do
        expect(Decidim::Toggle::Engine.railtie_namespace).to eq(Decidim::Toggle)
      end
    end
  end
end
