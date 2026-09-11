# frozen_string_literal: true

module Decidim
  module Toggle
    # Lets other gems hide verification workflows on the System authorizations tab
    # without prepending {UpdateAuthorizationsForm}.
    module AuthorizationWorkflows
      class << self
        def filters
          @filters ||= []
        end

        def add_filter(&block)
          filters << block
        end

        def reset_filters!
          @filters = []
        end

        def for(organization)
          Decidim.authorization_workflows.select do |workflow|
            allowed?(workflow, organization)
          end
        end

        def allowed?(workflow, organization)
          filters.all? { |filter| filter.call(workflow, organization) }
        end
      end
    end
  end
end
