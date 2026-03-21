# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateLocaleForm < Decidim::Form
      mimic :organization

      attribute :available_locales, Array
      attribute :default_locale, String
      attribute :enable_machine_translations, Boolean
      attribute :machine_translation_display_priority, String

      validates :available_locales, presence: true
      validates :default_locale, presence: true
      validates :machine_translation_display_priority,
                inclusion: { in: %w(original translation) },
                if: -> { defined?(Decidim::Organization::AVAILABLE_MACHINE_TRANSLATION_DISPLAY_PRIORITIES) && enable_machine_translations }
      validate :available_locales_subset_of_i18n
      validate :default_locale_in_available_locales
      validate :default_locale_in_i18n

      def self.from_model(organization)
        attrs = {
          available_locales: organization.available_locales,
          default_locale: organization.default_locale
        }
        attrs[:enable_machine_translations] = organization.enable_machine_translations if organization.respond_to?(:enable_machine_translations)
        attrs[:machine_translation_display_priority] = organization.machine_translation_display_priority if organization.respond_to?(:machine_translation_display_priority)
        from_params(attrs)
      end

      def self.collection_for_machine_translation_display_priority
        return [] unless defined?(Decidim::Organization::AVAILABLE_MACHINE_TRANSLATION_DISPLAY_PRIORITIES)

        Decidim::Organization::AVAILABLE_MACHINE_TRANSLATION_DISPLAY_PRIORITIES.map do |priority|
          [
            priority,
            I18n.t("activemodel.attributes.organization.machine_translation_display_priority_#{priority}", default: priority)
          ]
        end
      end

      def self.collection_for_available_locales
        I18n.available_locales.map { |l| [l.to_s, l.to_s] }
      end

      def self.collection_for_default_locale
        I18n.available_locales.map { |l| [l.to_s, l.to_s] }
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        attrs = params[:organization] || params
        if attrs[:available_locales].is_a?(Hash)
          params = params.dup
          params[:organization] = (params[:organization] || {}).merge(available_locales: attrs[:available_locales].keys.compact_blank)
        end
        super(params, additional_params)
      end

      def clean_available_locales
        return [] if available_locales.blank?

        allowed = i18n_available_locales_set
        Array(available_locales).map(&:to_s).select { |l| allowed.include?(l) }
      end

      private

      def i18n_available_locales_set
        @i18n_available_locales_set ||= I18n.available_locales.to_set(&:to_s)
      end

      def available_locales_subset_of_i18n
        return if available_locales.blank?

        invalid = Array(available_locales).map(&:to_s) - i18n_available_locales_set.to_a
        return if invalid.empty?

        errors.add(:available_locales, :inclusion)
      end

      def default_locale_in_available_locales
        return if default_locale.blank?

        errors.add(:default_locale, :inclusion) unless Array(available_locales).map(&:to_s).include?(default_locale.to_s)
      end

      def default_locale_in_i18n
        return if default_locale.blank?

        errors.add(:default_locale, :inclusion) unless i18n_available_locales_set.include?(default_locale.to_s)
      end
    end
  end
end
