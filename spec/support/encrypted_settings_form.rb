# frozen_string_literal: true

module EncryptedSettingsForm
  module_function

  def form_class
    @form_class ||= Class.new(Decidim::Form) do
      include Decidim::Toggle::ModuleConfigForm

      self.module_config_name = "decidim_toggle_secret"

      mimic :organization
      attribute :api_key, :string
      encrypted :api_key
    end
  end

  def register_tab!
    return if @registered

    Decidim::Toggle::SettingsTabRegistry.find(:organization_settings).configurations << lambda do |tabs|
      tabs.add_tab :toggle_secret, "Toggle secret",
                   form: EncryptedSettingsForm.form_class,
                   command: Decidim::Toggle::UpdateModuleConfigCommand,
                   module_name: :decidim_toggle_secret
    end
    @registered = true
  end

  def persist_secret!(organization, plaintext)
    Decidim::Toggle.save_config!(
      organization,
      :decidim_toggle_secret,
      {
        "api_key" => Decidim::AttributeEncryptor.encrypt(plaintext),
        "api_key_count" => plaintext.length,
        "api_key_last4" => plaintext.last(4)
      }
    )
  end
end
