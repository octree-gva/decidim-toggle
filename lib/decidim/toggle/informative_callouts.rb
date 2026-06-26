# frozen_string_literal: true

module Decidim
  module Toggle
    # Declare form-level informative callouts (info, warning, danger) on toggle settings forms.
    #
    #   class MyForm < Decidim::Form
    #     include Decidim::Toggle::InformativeCallouts
    #
    #     info :management_callout_html
    #     warning :conditional_callout, if_predicate: ->(form) { form.some_flag? }
    #
    #     def management_callout_html
    #       I18n.t("...")
    #     end
    #   end
    #
    # +message+ is always a Symbol naming an instance method on the form.
    # Messages are rendered as HTML (sanitized by the announcement cell), wrapped in
    # +decidim_toggle_informative_callout+ for system typography styles.
    module InformativeCallouts
      extend ActiveSupport::Concern

      WRAPPER_CLASS = "decidim_toggle_informative_callout"
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

        def message_for(form)
          form.public_send(message)
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
