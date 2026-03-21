# frozen_string_literal: true

module Decidim
  module Toggle
    #
    # Builds a list of settings tabs from registered configurations (same pattern as Decidim::Menu).
    #
    class SettingsTabs
      def initialize(name)
        @name = name
        @items = []
        @removed_items = []
      end

      def build_for(context, **options)
        raise "Settings tabs #{@name} is not registered" if registry.blank?

        registry.configurations.each do |configuration|
          context.instance_exec(self, **options, &configuration)
        end
      end

      # Tab with form + command: common layout renders form.all_fields and submits to generic controller.
      # @param identifier [Symbol] Tab id
      # @param label [String] Tab button label
      # @param form [Class] Decidim::Form subclass (must respond to .from_model(organization))
      # @param command [Class] Decidim::Command that receives (organization, form)
      # @param options [Hash] :position, :if, :open
      def add_tab(identifier, label, form:, command:, **options)
        options = { position: (1 + @items.length) }.merge(options)
        registry.register_form_tab(identifier, form, command)
        @items << SettingsTabItem.new(identifier, label, options.merge(form_class: form, command_class: command))
      end

      # Tab with custom partial: caller provides partial path and is responsible for controller/command.
      # @param identifier [Symbol] Tab id
      # @param label [String] Tab button label
      # @param partial [String] Partial path (e.g. "decidim/system/organizations/omniauth_settings")
      # @param options [Hash] :position, :if, :open, :extra_locals
      def add_custom_tab(identifier, label, partial, **options)
        options = { position: (1 + @items.length) }.merge(options)
        @items << SettingsTabItem.new(identifier, label, options.merge(partial:))
      end

      def remove_tab(identifier)
        @removed_items << identifier
      end

      def items
        @items.reject! { |item| @removed_items.include?(item.identifier) }
        @items.select(&:visible?).sort_by(&:position)
      end

      private

      def registry
        @registry ||= SettingsTabRegistry.find(@name)
      end
    end
  end
end
