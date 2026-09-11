# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Toggle
    describe EncryptedAttributes do
      let(:form_class) { EncryptedSettingsForm.form_class }

      describe ".encrypted" do
        it "registers string attribute names" do
          expect(form_class.encrypted_attribute?(:api_key)).to be(true)
          expect(form_class.encrypted_attribute_names).to include("api_key")
        end
      end

      describe ".mask_for" do
        it "returns stars equal to the secret length" do
          expect(described_class.mask_for(6, "cret")).to eq("******")
        end

        it "returns the last four characters when length is greater than 32" do
          expect(described_class.mask_for(33, "wxyz")).to eq("wxyz")
        end

        it "returns an empty string when there is no secret" do
          expect(described_class.mask_for(0, "")).to eq("")
        end
      end

      describe ".persist_encrypted" do
        it "encrypts the value and stores count and last4" do
          result = form_class.persist_encrypted("api_key" => "secret")

          expect(result["api_key"]).not_to eq("secret")
          expect(Decidim::AttributeEncryptor.decrypt(result["api_key"])).to eq("secret")
          expect(result["api_key_count"]).to eq(6)
          expect(result["api_key_last4"]).to eq("cret")
        end

        it "omits blank secrets so merge can keep the previous value" do
          result = form_class.persist_encrypted("api_key" => "", "enabled" => true)

          expect(result).not_to have_key("api_key")
          expect(result).not_to have_key("api_key_count")
          expect(result).not_to have_key("api_key_last4")
          expect(result["enabled"]).to be(true)
        end
      end

      describe ".strip_submitted_secrets" do
        it "removes encrypted keys from submitted params" do
          result = described_class.strip_submitted_secrets(
            { "api_key" => "secret", "enabled" => true },
            form_class
          )

          expect(result).not_to have_key("api_key")
          expect(result["enabled"]).to be(true)
        end
      end

      describe "#to_persisted_config" do
        it "encrypts form attributes" do
          form = form_class.from_params(organization: { api_key: "token" })
          result = form.to_persisted_config

          expect(Decidim::AttributeEncryptor.decrypt(result["api_key"])).to eq("token")
          expect(result["api_key_count"]).to eq(5)
          expect(result["api_key_last4"]).to eq("oken")
        end
      end
    end
  end
end
