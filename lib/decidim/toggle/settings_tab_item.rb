# frozen_string_literal: true

module Decidim
  module Toggle
    class SettingsTabItem
      def initialize(identifier, label, options = {})
        @identifier = identifier
        @label = label
        @partial = options[:partial]
        @form_class = options[:form_class]
        @command_class = options[:command_class]
        @position = options[:position] || Float::INFINITY
        @if = options[:if]
        @open = options.fetch(:open, false)
        @extra_locals = options[:extra_locals] || {}
      end

      attr_reader :identifier, :label, :partial, :form_class, :command_class, :extra_locals

      attr_accessor :position

      def custom_tab?
        partial.present?
      end

      def form_tab?
        form_class.present? && command_class.present?
      end

      def open?
        @open
      end

      def visible?
        return true if @if.nil? || @if

        false
      end
    end
  end
end
