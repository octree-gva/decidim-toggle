# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

# Decidim 0.29 uses Webpacker; 0.32+ uses Shakapacker.
registry = defined?(Decidim::Shakapacker) ? Decidim::Shakapacker : Decidim::Webpacker

registry.register_path("#{base_path}/app/packs")
registry.register_entrypoints(
  decidim_toggle: "#{base_path}/app/packs/entrypoints/decidim_toggle.js"
)
