# frozen_string_literal: true

module Decidim
  module Toggle
    class UpdateSecurityForm < Decidim::Form
      mimic :organization

      attribute :force_users_to_authenticate_before_access_organization, Boolean
      attribute :users_registration_mode, String
      attribute :available_authorizations, [String]
      attribute :"default-src", String
      attribute :"img-src", String
      attribute :"media-src", String
      attribute :"script-src", String
      attribute :"style-src", String
      attribute :"frame-src", String
      attribute :"font-src", String
      attribute :"connect-src", String

      validates :users_registration_mode, presence: true,
                                          inclusion: { in: Decidim::Organization.users_registration_modes }

      def self.from_model(organization)
        csp = organization.content_security_policy || {}
        attrs = {
          force_users_to_authenticate_before_access_organization: organization.force_users_to_authenticate_before_access_organization,
          users_registration_mode: organization.users_registration_mode,
          available_authorizations: organization.available_authorizations || [],
          "default-src": csp["default-src"],
          "img-src": csp["img-src"],
          "media-src": csp["media-src"],
          "script-src": csp["script-src"],
          "style-src": csp["style-src"],
          "frame-src": csp["frame-src"],
          "font-src": csp["font-src"],
          "connect-src": csp["connect-src"]
        }
        from_params({ organization: attrs })
      end

      def self.from_params(params, additional_params = {})
        params = params.to_h.with_indifferent_access if params.respond_to?(:to_h)
        params[:organization] || params
        super(params, additional_params)
      end

      def self.collection_for_users_registration_mode
        Decidim::Organization.users_registration_modes.map do |mode|
          [mode.first, I18n.t("decidim.system.organizations.users_registration_mode.#{mode.first}", default: mode.first)]
        end
      end

      def self.collection_for_available_authorizations
        Decidim.authorization_workflows.map { |w| [w.name, w.description] }
      end

      def content_security_policy
        {
          "default-src" => send(:"default-src"),
          "img-src" => send(:"img-src"),
          "media-src" => send(:"media-src"),
          "script-src" => send(:"script-src"),
          "style-src" => send(:"style-src"),
          "frame-src" => send(:"frame-src"),
          "font-src" => send(:"font-src"),
          "connect-src" => send(:"connect-src")
        }.compact_blank
      end

      def clean_available_authorizations
        Array(available_authorizations).select(&:present?)
      end
    end
  end
end
