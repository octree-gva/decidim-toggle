# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/toggle/version"

Gem::Specification.new do |s|
  s.version = Decidim::Toggle.version
  s.authors = ["hadrien@octree.ch"]
  s.email = ["hadrien@octree.ch"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/example/decidim-toggle"
  s.required_ruby_version = ">= 3.2"
  s.name = "decidim-toggle"
  s.summary = "Feature toggle for Decidim system administration"
  s.description = "Tabbed System organization settings (registration, emails, language, security, other) " \
                  "with an API for other modules to add tabs. Overrides decidim-system organization views via prepended paths."

  s.files = Dir.chdir(__dir__) do
    tracked = `git ls-files -z 2>/dev/null`.split("\x0").reject(&:empty?)
    if tracked.any?
      tracked
    else
      Dir["{app,config,lib}/**/*", "Rakefile", "README.md"].reject { |f| f.match(%r{^(spec|decidim_dummy_app)/}) }
    end
  end

  s.require_paths = ["lib"]

  s.add_dependency "decidim-core", Decidim::Toggle.decidim_version
  s.add_dependency "decidim-system", Decidim::Toggle.decidim_version

  s.metadata["rubygems_mfa_required"] = "true"
end
