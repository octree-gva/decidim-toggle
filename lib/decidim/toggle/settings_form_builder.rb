# frozen_string_literal: true

module Decidim
  module Toggle
    # Form builder for add_tab form tabs. Renders all form attributes via #all_fields.
    # Form classes can define class method collection_for_<attribute> to return [[value, label], ...] for collection inputs.
    # Loaded from the engine after +require "decidim/core"+ so +Decidim::FormBuilder+ autoload works.
    class SettingsFormBuilder < Decidim::FormBuilder
      CALLOUT_CLASS_BY_TYPE = {
        info: "info",
        warning: "warning",
        danger: "alert"
      }.freeze

      def informative_callouts
        return "".html_safe unless object.class.include?(InformativeCallouts)

        entries = object.visible_informative_callouts
        return "".html_safe if entries.blank?

        callouts = entries.map do |entry|
          @template.cell(
            "decidim/announcement",
            entry.message_for(object),
            callout_class: CALLOUT_CLASS_BY_TYPE.fetch(entry.type)
          )
        end
        safe_join(callouts)
      end

      def all_fields
        fields = attribute_names.map do |name|
          @template.content_tag(:div, input_field(name), class: field_wrapper_classes(name))
        end
        safe_join(fields)
      end

      # Renders a subset of attributes (e.g. machine translation fields after a custom locale table).
      def fields_for_names(*names)
        names = names.flatten.map(&:to_s)
        fields = names.filter_map do |name|
          next unless object.class.respond_to?(:attribute_types) && object.class.attribute_types.has_key?(name)

          @template.content_tag(:div, input_field(name.to_sym), class: field_wrapper_classes(name))
        end
        safe_join(fields)
      end

      private

      def input_field(name)
        name = name.to_sym
        input_html =
          if translatable_hash_attribute?(name)
            translated_input_field(name)
          else
            build_input_field(name)
          end

        helptext = helptext_for_attribute(name)
        return input_html if helptext.blank?

        # Render the help text under the field label (the upstream `Decidim::FormBuilder`
        # typically renders the label inside the field HTML returned above).
        @template.safe_join(
          [
            input_html,
            @template.content_tag(:p, helptext, class: "field-helptext")
          ]
        )
      end

      def build_input_field(name)
        type = attribute_type(name)

        if (collection = collection_for(name))
          if type == :array
            collection_check_boxes(name, collection, :first, :last) do |b|
              @template.content_tag(:div, b.check_box(checked: Array(object.public_send(name)).include?(b.value)) + b.label { b.text })
            end
          else
            collection_radio_buttons(name, collection, :first, :last) do |b|
              @template.content_tag(:div, b.radio_button + b.label { b.text })
            end
          end
        else
          options = field_html_options_for(name)
          case type
          when :string
            name.to_s == "secondary_hosts" ? text_area(name, options) : text_field(name, options)
          when :integer then number_field(name, options)
          when :boolean then check_box(name, options)
          else text_field(name, options)
          end
        end
      end

      def field_html_options_for(name)
        attribute_disabled?(name) ? { disabled: true } : {}
      end

      def field_wrapper_classes(name)
        attribute_disabled?(name) ? "field is-disabled" : "field"
      end

      def attribute_disabled?(name)
        name = name.to_sym
        method = :"disabled_for_#{name}?"
        return object.public_send(method) if object.respond_to?(method)

        return object.attribute_disabled?(name) if object.respond_to?(:attribute_disabled?)

        false
      end

      def collection_for(attribute)
        method = :"collection_for_#{attribute}"
        object.class.respond_to?(method) ? object.class.public_send(method) : nil
      end

      def attribute_names
        return [] unless object.class.respond_to?(:attribute_types)

        object.class.attribute_types.keys.reject do |k|
          k.to_s == "id" || translatable_locale_field?(k.to_s)
        end
      end

      def attribute_type(name)
        return :string unless object.class.respond_to?(:attribute_types)

        type_obj = object.class.attribute_types[name.to_s]
        type_obj.respond_to?(:type) ? type_obj.type : :string
      end

      # translatable_attribute adds a hash (:name) plus one String per locale (:name_en, …).
      # Decidim forms use #translated (tabs or locale select); listing locale keys duplicates the UI.
      def translatable_hash_attribute?(base)
        return false unless object.class.include?(Decidim::TranslatableAttributes)

        type = object.class.attribute_types[base.to_s]
        type.respond_to?(:type) && type.type == :hash
      end

      def translatable_locale_field?(key)
        return false unless object.class.include?(Decidim::TranslatableAttributes)

        Decidim.available_locales.any? do |locale|
          suffix = locale.to_s.tr("-", "__")
          next unless key.end_with?("_#{suffix}")

          base = key.delete_suffix("_#{suffix}")
          next if base.blank?

          translatable_hash_attribute?(base)
        end
      end

      def translated_input_field(name)
        locale = Decidim.available_locales.first
        locale_key = "#{name}_#{locale.to_s.tr("-", "__")}"
        t = attribute_type(locale_key)
        case t
        when :"decidim/attributes/rich_text"
          translated(:editor, name)
        else
          translated(:text_field, name)
        end
      end

      def helptext_for_attribute(name)
        attribute_name = name.to_s

        # When a form `mimic`s another ActiveModel (e.g. organization), `model_name`
        # is expected to match i18n keys used across Decidim.
        candidate_model_keys = []
        candidate_model_keys << object.class.model_name.i18n_key if object.class.respond_to?(:model_name) && object.class.model_name.respond_to?(:i18n_key)
        candidate_model_keys << object_name if respond_to?(:object_name)

        candidate_model_keys.compact!
        candidate_model_keys.uniq!

        candidate_model_keys.each do |model_key|
          # Preferred location avoids making `activemodel.attributes.<model>.<attr>` a Hash (which can break
          # attribute name i18n lookups for the same key).
          helptext = I18n.t("activemodel.attributes.#{model_key}.helptext.#{attribute_name}", default: nil)
          return helptext if helptext.present?
        end

        nil
      end
    end
  end
end
