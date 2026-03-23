# frozen_string_literal: true

module Decidim
  module Toggle
    # Vanilla Decidim: `available_authorizations` is a string array of workflow names.
    # Other gems may replace this tab (same identifier `:authorizations`); see
    # {Decidim::Toggle::OrganizationSettingsTabs}.
    class UpdateAuthorizationsForm < Decidim::Form
      mimic :organization

      attribute :available_authorizations, [String]

      validate :available_authorizations_subset_of_workflows

      def self.from_model(organization)
        from_params(organization: { available_authorizations: Array(organization.available_authorizations).map(&:to_s) })
      end

      def self.collection_for_available_authorizations
        Decidim.authorization_workflows.map { |w| [w.name, w.description] }
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        attrs = params[:organization] || params
        if attrs[:available_authorizations].nil?
          params = params.dup
          params[:organization] = (params[:organization] || {}).merge(available_authorizations: [])
        end
        super(params, additional_params)
      end

      def clean_available_authorizations
        @clean_available_authorizations ||= if available_authorizations.blank?
                                              []
                                            else
                                              available_authorizations.map(&:to_s).select(&:present?)
                                            end
      end

      private

      def available_authorizations_subset_of_workflows
        return if clean_available_authorizations.blank?

        allowed = Decidim.authorization_workflows.to_set(&:name)
        invalid = Array(clean_available_authorizations).map(&:to_s).reject { |a| allowed.include?(a) }
        return if invalid.empty?

        errors.add(:available_authorizations, :invalid)
      end
    end
  end
end
