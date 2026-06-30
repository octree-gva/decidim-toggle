# frozen_string_literal: true

module Decidim
  # This holds the decidim-toggle version.
  module Toggle
    def self.version
      "0.1.3" # DO NOT UPDATE MANUALLY
    end

    def self.decidim_version
      [">= 0.29", "< 0.33"].freeze
    end
  end
end
