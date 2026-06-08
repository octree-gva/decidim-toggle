# frozen_string_literal: true

module Decidim
  module Toggle
    # Recommended base for organization settings tab forms.
    #
    #   class MyModule::AdminConfigForm < Decidim::Form
    #     include Decidim::Toggle::TabForm
    #     include Decidim::Toggle::ModuleConfigForm
    #     ...
    #   end
    module TabForm
      extend ActiveSupport::Concern

      included do
        include InformativeCallouts
      end
    end
  end
end
