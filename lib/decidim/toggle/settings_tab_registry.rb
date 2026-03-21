# frozen_string_literal: true

module Decidim
  module Toggle
    class SettingsTabRegistry
      class << self
        def register(name, &block)
          registry = find(name) || create(name)
          registry.configurations << block
          registry
        end

        def find(name)
          all[name.to_sym]
        end

        def create(name)
          all[name.to_sym] = new
        end

        def destroy(name)
          all[name.to_sym] = nil
        end

        private

        def all
          @all ||= {}
        end
      end

      attr_reader :configurations, :form_tabs

      def initialize
        @configurations = []
        @form_tabs = {}
      end

      def register_form_tab(identifier, form_class, command_class)
        @form_tabs[identifier.to_sym] = { form: form_class, command: command_class }
      end

      def form_tab(identifier)
        form_tabs[identifier.to_sym]
      end
    end
  end
end
