# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_toggle do
  namespace :webpacker do
    desc "Installs Toggle webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_toggle_npm
    end

    desc "Adds Toggle dependencies in package.json"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_toggle_npm
    end

    def install_toggle_npm
      return if toggle_npm_dependencies.empty?

      puts "install NPM packages. You can also do this manually with this command:"
      puts "npm i #{toggle_npm_dependencies.join(" ")}"
      toggle_system! "npm i #{toggle_npm_dependencies.join(" ")}"
    end

    def toggle_npm_dependencies
      @toggle_npm_dependencies ||= begin
        return [] if toggle_path.nil? || !File.exist?(toggle_path.join("package.json"))

        package_json = JSON.parse(File.read(toggle_path.join("package.json")))

        (package_json["dependencies"] || {}).map { |package, version| "#{package}@#{version}" }
      end
    end

    def toggle_path
      @toggle_path ||= Pathname.new(toggle_gemspec.full_gem_path) if Gem.loaded_specs.has_key?(toggle_gem_name)
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def toggle_system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def toggle_gemspec
      @toggle_gemspec ||= Gem.loaded_specs[toggle_gem_name]
    end

    def toggle_gem_name
      "decidim-toggle"
    end
  end
end

