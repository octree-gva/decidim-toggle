# frozen_string_literal: true

module Decidim
  module Toggle
    # Per-organization JSON configuration for a module (see {Decidim::Toggle.config_for}).
    class OrganizationModuleConfig < Decidim::ApplicationRecord
      self.table_name = "decidim_toggle_organization_module_configs"

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: :decidim_organization_id

      validates :module_name, presence: true
      validates :module_name, uniqueness: { scope: :decidim_organization_id }
    end
  end
end
