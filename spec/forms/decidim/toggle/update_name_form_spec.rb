# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateNameForm do
      let(:organization) { create(:organization) }

      describe ".from_params with name_* keys" do
        it "maps name_en into nested name hash" do
          form = described_class.from_params(
            organization: { "name_en" => "Hello", :host => "x.lvh.me" }
          ).with_context(current_organization: organization)

          expect(form.name["en"]).to eq("Hello")
        end
      end

      describe ".from_model" do
        it "joins array secondary hosts with newlines" do
          organization.update!(secondary_hosts: %w(a.example.org b.example.org))

          form = described_class.from_model(organization)

          expect(form.secondary_hosts).to eq("a.example.org\nb.example.org")
        end

        it "preserves string secondary hosts" do
          allow(organization).to receive(:secondary_hosts).and_return("legacy.example.org")

          form = described_class.from_model(organization)

          expect(form.secondary_hosts).to eq("legacy.example.org")
        end

        it "defaults secondary hosts to an empty string for unexpected values" do
          allow(organization).to receive(:secondary_hosts).and_return(nil)

          form = described_class.from_model(organization)

          expect(form.secondary_hosts).to eq("")
        end
      end

      describe "#clean_secondary_hosts" do
        it "splits lines and drops blanks" do
          form = described_class.from_params(
            organization: { host: organization.host, secondary_hosts: "a.com\n\nb.com" }
          ).with_context(current_organization: organization)

          expect(form.clean_secondary_hosts).to eq(%w(a.com b.com))
        end
      end
    end
  end
end
