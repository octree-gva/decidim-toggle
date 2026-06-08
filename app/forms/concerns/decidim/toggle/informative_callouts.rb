# frozen_string_literal: true

module Decidim
  module Toggle
    # Declare form-level informative callouts (info, warning, danger) on toggle settings forms.
    #
    #   class MyForm < Decidim::Form
    #     include Decidim::Toggle::InformativeCallouts
    #
    #     info "Helpful context for integrators."
    #     warning "Check this before saving.", if_predicate: ->(form) { form.some_flag? }
    #     danger "Destructive change.", if_predicate: ->(_) { Decidim::Toggle.gem_present?("decidim-other") }
    #   end
    module InformativeCallouts
      extend ActiveSupport::Concern

      CALLOUT_TYPES = [:info, :warning, :danger].freeze

      class InformativeEntry
        attr_reader :type, :message, :if_predicate

        def initialize(type:, message:, if_predicate: nil)
          @type = type
          @message = message
          @if_predicate = if_predicate
        end

        def visible?(form)
          return true if if_predicate.nil?

          if_predicate.call(form)
        end
      end

      class_methods do
        def informative_callouts
          @informative_callouts ||= []
        end

        def info(message, if_predicate: nil)
          register_informative(:info, message, if_predicate:)
        end

        def warning(message, if_predicate: nil)
          register_informative(:warning, message, if_predicate:)
        end

        def danger(message, if_predicate: nil)
          register_informative(:danger, message, if_predicate:)
        end

        private

        def register_informative(type, message, if_predicate: nil)
          informative_callouts << InformativeEntry.new(type:, message:, if_predicate:)
        end
      end

      def visible_informative_callouts
        self.class.informative_callouts.select { |entry| entry.visible?(self) }
      end
    end
  end
end
