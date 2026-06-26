# frozen_string_literal: true

module Decidim
  module Toggle
    # Declare form-level informative callouts (info, warning, danger) on toggle settings forms.
    #
    #   class MyForm < Decidim::Form
    #     include Decidim::Toggle::InformativeCallouts
    #
    #     info "Helpful context for integrators."
    #     info :dynamic_message_method
    #     info ->(form) { "Hello #{form.name}" }
    #     warning "Check this before saving.", if_predicate: ->(form) { form.some_flag? }
    #     danger "Destructive change.", if_predicate: ->(_) { Decidim::Toggle.gem_present?("decidim-other") }
    #   end
    module InformativeCallouts
      extend ActiveSupport::Concern

      CALLOUT_TYPES = [:info, :warning, :danger].freeze

      class InformativeEntry
        attr_reader :type, :message, :if_predicate, :html

        def initialize(type:, message:, if_predicate: nil, html: false)
          @type = type
          @message = message
          @if_predicate = if_predicate
          @html = html
        end

        def html?
          html
        end

        def visible?(form)
          return true if if_predicate.nil?

          if_predicate.call(form)
        end

        def message_for(form)
          case message
          when Proc then message.call(form)
          when Symbol then form.public_send(message)
          else message.to_s
          end
        end
      end

      class_methods do
        def informative_callouts
          @informative_callouts ||= []
        end

        def info(message, if_predicate: nil, html: :auto)
          register_informative(:info, message, if_predicate:, html: resolve_html_flag(message, html))
        end

        def warning(message, if_predicate: nil, html: :auto)
          register_informative(:warning, message, if_predicate:, html: resolve_html_flag(message, html))
        end

        def danger(message, if_predicate: nil, html: :auto)
          register_informative(:danger, message, if_predicate:, html: resolve_html_flag(message, html))
        end

        private

        def resolve_html_flag(message, html)
          return message.to_s.end_with?("_html") if html == :auto && message.is_a?(Symbol)

          html == :auto ? false : html
        end

        def register_informative(type, message, if_predicate: nil, html: false)
          informative_callouts << InformativeEntry.new(type:, message:, if_predicate:, html:)
        end
      end

      def visible_informative_callouts
        self.class.informative_callouts.select { |entry| entry.visible?(self) }
      end
    end
  end
end
