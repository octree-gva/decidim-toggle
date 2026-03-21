# frozen_string_literal: true

module Decidim
  module Toggle
    # Read model around a {Decidim::Form} built from stored JSON: normalizes +nil+ for
    # array/hash/boolean attributes so runtime code can use +enabled?+, empty collections, etc.
    class ModuleConfigurationPresenter
      def initialize(form)
        @form = form
        define_accessors!
      end

      attr_reader :form

      def respond_to_missing?(name, include_private = false)
        @form.respond_to?(name, include_private)
      end

      def method_missing(name, *args, &)
        if @form.respond_to?(name)
          @form.public_send(name, *args, &)
        else
          super
        end
      end

      private

      def define_accessors!
        @form.class.attribute_names.each do |attr|
          next if attr == "id"

          type = @form.class.attribute_types[attr]

          define_singleton_method(attr) do
            normalize(@form.public_send(attr), attr, type)
          end

          next unless type.is_a?(ActiveModel::Type::Boolean)

          define_singleton_method("#{attr}?") do
            !!normalize(@form.public_send(attr), attr, type)
          end
        end
      end

      def normalize(value, _attr_name, type)
        return value unless value.nil?

        return [] if type.try(:type) == :array
        return {} if type.try(:type) == :hash
        return false if type.is_a?(ActiveModel::Type::Boolean)

        value
      end
    end
  end
end
