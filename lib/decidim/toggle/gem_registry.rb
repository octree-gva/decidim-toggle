# frozen_string_literal: true

module Decidim
  module Toggle
    # Detects whether a Ruby gem is loaded in the current Bundler bundle.
    class GemRegistry
      def self.present?(gem_name)
        name = gem_name.to_s
        return false if name.blank?

        Bundler.load.specs.any? { |spec| spec.name == name }
      end
    end
  end
end
