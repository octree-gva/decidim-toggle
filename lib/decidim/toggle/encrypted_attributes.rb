# frozen_string_literal: true

module Decidim
  module Toggle
    # Declare secrets on settings tab forms. Keep +attribute :api_key, :string+.
    #
    #   class MyForm < Decidim::Form
    #     include Decidim::Toggle::ModuleConfigForm
    #
    #     attribute :api_key, :string
    #     encrypted :api_key
    #   end
    #
    # Persistence uses {Decidim::AttributeEncryptor} plus sibling JSON keys
    # +api_key_count+ and +api_key_last4+. Blank submits omit those keys so
    # +save_config!(merge: true)+ keeps the previous secret.
    module EncryptedAttributes
      extend ActiveSupport::Concern

      LAST4_THRESHOLD = 32

      def self.mask_for(count, last4)
        length = count.to_i
        return "" if length <= 0
        return last4.to_s if length > LAST4_THRESHOLD

        "*" * length
      end

      def self.clear_plaintext!(form)
        Array(form.class.try(:encrypted_attribute_names)).each do |name|
          form.public_send(:"#{name}=", "") if form.respond_to?(:"#{name}=")
        end
      end

      def self.strip_submitted_secrets(hash, form_class)
        result = hash.to_h.stringify_keys
        Array(form_class.try(:encrypted_attribute_names)).each { |name| result.delete(name) }
        result
      end

      class_methods do
        def encrypted_attribute_names
          @encrypted_attribute_names ||= []
        end

        def encrypted(*names)
          names.each { |name| encrypted_attribute_names << name.to_s }
          encrypted_attribute_names.uniq!
        end

        def encrypted_attribute?(name)
          encrypted_attribute_names.include?(name.to_s)
        end

        def persist_encrypted(hash)
          result = hash.stringify_keys
          encrypted_attribute_names.each { |name| write_or_omit_encrypted!(result, name) }
          result
        end

        def write_or_omit_encrypted!(hash, name)
          plaintext = hash[name].to_s
          return hash.delete(name) if plaintext.blank?

          assign_encrypted_keys!(hash, name, plaintext)
        end

        def assign_encrypted_keys!(hash, name, plaintext)
          hash[name] = Decidim::AttributeEncryptor.encrypt(plaintext)
          hash["#{name}_count"] = plaintext.length
          hash["#{name}_last4"] = plaintext.last(4)
        end
      end

      def to_persisted_config
        self.class.persist_encrypted(to_h)
      end
    end
  end
end
