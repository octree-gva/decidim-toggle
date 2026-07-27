# frozen_string_literal: true

module Decidim
  module Toggle
    # Declare trivial field disable rules on settings tab forms.
    #
    #   class MyForm < Decidim::Form
    #     include Decidim::Toggle::FieldConditions
    #
    #     attribute :enabled, :boolean
    #     attribute :api_key, :string
    #
    #     disable :api_key, if_unchecked: :enabled
    #   end
    #
    # When +enabled+ is unchecked, +api_key+ is disabled (server-side on render,
    # and live in the browser via data attributes).
    module FieldConditions
      extend ActiveSupport::Concern

      class_methods do
        def field_disable_conditions
          @field_disable_conditions ||= {}
        end

        # Disables +attribute+ while the boolean +if_unchecked+ attribute is false.
        def disable(attribute, if_unchecked:)
          raise ArgumentError, "disable requires if_unchecked:" if if_unchecked.blank?

          field_disable_conditions[attribute.to_sym] = { if_unchecked: if_unchecked.to_sym }
        end
      end
    end
  end
end
