# frozen_string_literal: true

module Decidim
  module Toggle
    # Opt-in DSL to expose module config form attributes to +window.DecidimToggle+.
    # To add this in your form, you need to add the following:
    # ```ruby
    # include Decidim::Toggle::ExposeAttributesToJs
    # expose_to_javascript :enabled, :search_bar
    # ```
    module ExposeAttributesToJs
      extend ActiveSupport::Concern

      class_methods do
        def expose_to_javascript(*names)
          javascript_exposed_attribute_names.concat(names.map(&:to_s))
          javascript_exposed_attribute_names.uniq!
        end

        def javascript_exposed_attribute_names
          @javascript_exposed_attribute_names ||= []
        end
      end
    end
  end
end
