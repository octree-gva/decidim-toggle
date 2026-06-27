# frozen_string_literal: true

module Decidim
  module Toggle
    # I18n scope helpers for {ModuleConfigForm} tab fields.
    module ModuleConfigI18n
      module_function

      def scope_for(module_name)
        return if module_name.blank?

        "decidim_toggle.system.#{module_name}"
      end

      def label_key(module_name, attribute)
        base = scope_for(module_name)
        return unless base

        "#{base}.#{attribute}"
      end

      def helptext_key(module_name, attribute)
        base = scope_for(module_name)
        return unless base

        "#{base}.helptext.#{attribute}"
      end

      def translate_label(module_name, attribute)
        key = label_key(module_name, attribute)
        return unless key && I18n.exists?(key)

        I18n.t(key)
      end

      def translate_helptext(module_name, attribute)
        key = helptext_key(module_name, attribute)
        return unless key && I18n.exists?(key)

        I18n.t(key)
      end
    end
  end
end
