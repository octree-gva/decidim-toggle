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
        registry.mark_configurations_applied!
      end

      # Tab with form + command: common layout renders form.all_fields and submits to generic controller.
      # @param identifier [Symbol] Tab id
      # @param label [String] Tab button label
      # @param form [Class] Decidim::Form subclass (must respond to .from_model(organization))
      # @param command [Class] Decidim::Command that receives (organization, form)
      # @param options [Hash] :position, :if, :open,
      #                        :partial (optional partial path for the form body),
      #                        :form_layout_partial (optional partial path instead of default form_tab wrapper)
      def add_tab(identifier, label, form:, **options)
        command = options.fetch(:command)
        options = { position: (1 + @items.length) }.merge(options)

        partial = options.delete(:partial)
        options[:partial] = partial if partial.present?

        module_name = options[:module_name]
        registry.register_form_tab(identifier, form, command, module_name:)
        @items << SettingsTabItem.new(identifier, label, options.merge(form_class: form, command_class: command))
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
