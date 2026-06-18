# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe JavascriptConfigHelper do
      let(:organization) { create(:organization) }
      let(:helper_host) do
        Class.new do
          include JavascriptConfigHelper

          attr_accessor :current_organization

          def initialize(org)
            @current_organization = org
          end
        end.new(organization)
      end

      it "returns the flat javascript config hash for the current organization" do
        allow(Decidim::Toggle).to receive(:javascript_config_for).with(organization).and_return("decidim_demo.enabled" => true)

        expect(helper_host.decidim_toggle_javascript_config).to eq("decidim_demo.enabled" => true)
      end
    end
  end
end
