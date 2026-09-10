# frozen_string_literal: true

module Decidim
  module Toggle
    # Persists organization verification workflows.
    #
    # Vanilla Decidim: +available_authorizations+ is a string array of workflow names.
    # Persist a Hash only when +decidim-ephemeral_participation+ is loaded *and*
    # the column is json/jsonb (not a Postgres array).
    class UpdateAuthorizationsForm < Decidim::Form
      mimic :organization

      attribute :available_authorizations, [String]
      attribute :ephemeral_participation_authorization, String

      validate :available_authorizations_subset_of_workflows
      validate :ephemeral_authorization_among_enabled

      def self.ephemeral_mode?
        Decidim::Toggle.ephemeral_authorizations_hash?
      end

      def self.from_model(organization)
        if ephemeral_mode?
          from_model_ephemeral(organization)
        else
          from_model_vanilla(organization)
        end
      end

      def self.from_model_vanilla(organization)
        from_params(
          organization: {
            available_authorizations: Array(organization.available_authorizations).map(&:to_s)
          }
        )
      end

      def self.from_model_ephemeral(organization)
        hash = normalize_hash(organization.read_attribute(:available_authorizations))
        from_params(
          organization: {
            available_authorizations: hash.keys.map(&:to_s),
            ephemeral_participation_authorization: ephemeral_name_from(hash)
          }
        )
      end

      def self.collection_for_available_authorizations
        Decidim.authorization_workflows.map { |workflow| [workflow.name, workflow.description] }
      end

      def self.collection_for_ephemeral_participation_authorization
        return [] unless ephemeral_mode?

        Decidim.authorization_workflows.filter_map do |workflow|
          next unless workflow.respond_to?(:ephemerable) && workflow.ephemerable

          [workflow.name, workflow.description]
        end
      end

      def collection_for_available_authorizations
        self.class.collection_for_available_authorizations
      end

      def collection_for_ephemeral_participation_authorization
        self.class.collection_for_ephemeral_participation_authorization
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        attrs = params[:organization] || params
        if attrs[:available_authorizations].nil?
          params = params.dup
          params[:organization] = (params[:organization] || {}).merge(available_authorizations: [])
        end
        super
      end

      def self.normalize_hash(raw)
        case raw
        when Hash then stringify_hash(raw)
        when Array then raw.index_with { |_name| { "allow_ephemeral_participation" => false } }
        else {}
        end
      end

      def self.stringify_hash(raw)
        raw.each_with_object({}) do |(name, value), memo|
          memo[name.to_s] = value.is_a?(Hash) ? value.stringify_keys : {}
        end
      end

      def self.ephemeral_name_from(hash)
        hash.find { |_name, options| options["allow_ephemeral_participation"] == true }&.first
      end

      def clean_available_authorizations
        @clean_available_authorizations ||= if self.class.ephemeral_mode?
                                              clean_ephemeral_hash
                                            else
                                              clean_vanilla_array
                                            end
      end

      private

      def clean_vanilla_array
        return [] if available_authorizations.blank?

        available_authorizations.map(&:to_s).compact_blank
      end

      def clean_ephemeral_hash
        selected = ephemeral_participation_authorization.to_s
        clean_vanilla_array.index_with do |name|
          { "allow_ephemeral_participation" => name == selected }
        end
      end

      def available_authorizations_subset_of_workflows
        names = clean_vanilla_array
        return if names.blank?

        allowed = Decidim.authorization_workflows.to_set(&:name)
        invalid = names.reject { |name| allowed.include?(name) }
        return if invalid.empty?

        errors.add(:available_authorizations, :invalid)
      end

      def ephemeral_authorization_among_enabled
        return unless self.class.ephemeral_mode?
        return if ephemeral_participation_authorization.blank?
        return if clean_vanilla_array.include?(ephemeral_participation_authorization.to_s)

        errors.add(:ephemeral_participation_authorization, :invalid)
      end
    end
  end
end
