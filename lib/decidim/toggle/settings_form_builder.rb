# frozen_string_literal: true

require "decidim/translatable_attributes"
require "decidim/form_builder"

module Decidim
  module Toggle
    # Form builder for add_tab form tabs. Renders all form attributes via #all_fields.
    # Form classes can define class method collection_for_<attribute> to return [[value, label], ...] for collection inputs.
    class SettingsFormBuilder < Decidim::FormBuilder
      def all_fields
        fields = attribute_names.map do |name|
          @template.content_tag(:div, input_field(name), class: "field")
        end
        safe_join(fields)
      end

      # Renders a subset of attributes (e.g. machine translation fields after a custom locale table).
      def fields_for_names(*names)
        names = names.flatten.map(&:to_s)
        fields = names.filter_map do |name|
          next unless object.class.respond_to?(:attribute_types) && object.class.attribute_types.key?(name)

          @template.content_tag(:div, input_field(name.to_sym), class: "field")
        end
        safe_join(fields)
      end

      private

      def input_field(name)
        name = name.to_sym
        if translatable_hash_attribute?(name)
          return translated_input_field(name)
        end

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
          case type
          when :string
            name.to_s == "secondary_hosts" ? text_area(name) : text_field(name)
          when :integer then number_field(name)
          when :boolean then check_box(name)
          else text_field(name)
          end
        end
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
        type&.respond_to?(:type) && type.type == :hash
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
        when :string, :"decidim/attributes/clean_string"
          translated(:text_field, name)
        else
          translated(:text_field, name)
        end
      end
    end
  end
end
