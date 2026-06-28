# Decidim Toggle

<p align="center">
  <img src="website/static/img/logo.svg" alt="Decidim Toggle" width="120" />
</p>

Decidim Toggle is a **settings tab registry** for Decidim modules. It replaces decidim-system’s flat organization edit form with tabs and gives each `decidim-*` gem one place to register org configuration.

**Documentation:** [octree-gva.github.io/decidim-toggle](https://octree-gva.github.io/decidim-toggle/) — integrator guides and contributor docs.

## Add a tab

1. **Form** — include `Decidim::Toggle::ModuleConfigForm`, set `module_config_name`, declare attributes.

```ruby
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"
    mimic :organization
    attribute :enabled, :boolean
  end
end
```

2. **Register** — in your engine, after `decidim_toggle.organization_settings_tabs`:

```ruby
initializer "decidim_my_module.organization_settings_tab", after: "decidim_toggle.organization_settings_tabs" do
  Decidim::Toggle.settings_tabs :organization_settings do |tabs|
    tabs.add_tab :my_module, "My module",
                 form: MyModule::AdminConfigForm,
                 command: Decidim::Toggle::UpdateModuleConfigCommand,
                 module_name: :my_module
  end
end
```

3. **Read** — `Decidim::Toggle.config_for(organization, :my_module)`.

Optional view: `form_layout_partial:` on `add_tab` — see [Customize views](https://octree-gva.github.io/decidim-toggle/integrate/customize-views).

Full walkthrough: [Add a settings tab](https://octree-gva.github.io/decidim-toggle/integrate/quickstart).

## Host app install

```ruby
gem "decidim-toggle"
```

```bash
bundle install
rails decidim_toggle:install:migrations
rails db:migrate
```

## Development (this gem)

Docker + `./bin/check` (RuboCop, erblint, RSpec) — see [CONTRIBUTING.md](CONTRIBUTING.md) and [Contribute](https://octree-gva.github.io/decidim-toggle/contributing).

## License

AGPL-3.0.
