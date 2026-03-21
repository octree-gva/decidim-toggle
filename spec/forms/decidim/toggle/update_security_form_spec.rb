# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe UpdateSecurityForm do
      let(:organization) { create(:organization) }

      describe "#content_security_policy" do
        it "compacts blank directive values" do
          form = described_class.from_model(organization)
          form.send(:"default-src=", "'self'")
          form.send(:"img-src=", nil)

          csp = form.content_security_policy
          expect(csp["default-src"]).to eq("'self'")
          expect(csp).not_to have_key("img-src")
        end
      end

      describe "validations" do
        it "rejects invalid users_registration_mode" do
          form = described_class.from_model(organization)
          form.users_registration_mode = "invalid_mode"

          expect(form).not_to be_valid
        end
      end
    end
  end
end
