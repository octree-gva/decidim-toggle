# frozen_string_literal: true

require "spec_helper"

module EncryptedInvalidFlashForm
  module_function

  def form_class
    @form_class ||= Class.new(Decidim::Form) do
      include Decidim::Toggle::ModuleConfigForm

      self.module_config_name = "decidim_toggle_secret_invalid"

      mimic :organization
      attribute :api_key, :string
      encrypted :api_key
      validates :api_key, length: { maximum: 3 }
    end
  end

  def register_tab!
    return if @registered

    Decidim::Toggle::SettingsTabRegistry.find(:organization_settings).configurations << lambda do |tabs|
      tabs.add_tab :toggle_secret_invalid, "Toggle secret invalid",
                   form: EncryptedInvalidFlashForm.form_class,
                   command: Decidim::Toggle::UpdateModuleConfigCommand,
                   module_name: :decidim_toggle_secret_invalid
    end
    @registered = true
  end
end

module Decidim
  module Toggle
    describe "encrypted settings invalid flash" do
      let(:organization) { create(:organization) }
      let(:admin) { create(:admin) }
      let(:path) { "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/toggle_secret_invalid" }

      before do
        EncryptedInvalidFlashForm.register_tab!
        login_as admin, scope: :admin
      end

      it "does not store submitted secrets in flash" do
        patch path, params: { organization: { api_key: "toolong" } }

        payload = flash[:decidim_toggle_invalid_settings_tab]
        expect(payload[:params]).not_to have_key("api_key")
        expect(payload[:params]).not_to have_key(:api_key)
      end
    end
  end
end
