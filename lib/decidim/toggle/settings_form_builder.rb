# frozen_string_literal: true

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

      private

      def input_field(name)
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

        object.class.attribute_types.keys.reject { |k| k.to_s == "id" }
      end

      def attribute_type(name)
        return :string unless object.class.respond_to?(:attribute_types)

        type_obj = object.class.attribute_types[name.to_s]
        type_obj.respond_to?(:type) ? type_obj.type : :string
      end
    end
  end
end
