# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module Toggle
    class UpdateNameForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :organization

      translatable_attribute :name, String
      attribute :host, String
      attribute :secondary_hosts, String

      validates :host, presence: true
      validate :validate_name_presence

      def self.from_model(organization)
        from_params(
          name: organization.name,
          host: organization.host,
          secondary_hosts: organization.secondary_hosts&.join("\n")
        )
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        attrs = params[:organization] || params
        name_hash = I18n.available_locales.to_h { |l| [l.to_s, attrs["name_#{l}"]] }.compact_blank
        if name_hash.present?
          params = params.dup
          params[:organization] = (params[:organization] || {}).merge(name: name_hash)
        end
        super(params, additional_params)
      end

      def clean_secondary_hosts
        return [] if secondary_hosts.blank?

        secondary_hosts.split("\n").map(&:chomp).select(&:present?)
      end

      private

      def validate_name_presence
        return if name.is_a?(Hash) && name.values.any?(&:present?)

        locale = current_organization&.default_locale || Decidim.default_locale.to_s
        errors.add(:"name_#{locale}", :blank) if name.blank? || name[locale].blank?
      end
    end
  end
end
