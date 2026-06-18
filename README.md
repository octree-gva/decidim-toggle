# Decidim Toggle

Decidim Toggle is a **settings tab registry** for Decidim modules.

**For:** developers of `decidim-*` gems who ship per-organization configuration in **System → Organizations**.  
**Delivers:** one tab = one `Decidim::Form` + one `Decidim::Command`; JSON-backed settings without new tables.  
**Not for:** host-only installs with no custom modules, or feature toggles outside Decidim admin.

## Add a tab (module developer)

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
# lib/decidim/my_module/engine.rb
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

Optional view: `partial:` (field body) or `form_layout_partial:` (full tab) on `add_tab` — see [quickstart](website/docs/integrate/quickstart.md#3-optional-customize-form-view).

Full walkthrough: [doc site reading order](website/docs/README.md#integrator-reading-order) (`cd website && yarn start`).

## Deface overrides

| Virtual path | Name | Purpose |
|--------------|------|---------|
| `layouts/decidim/_decidim_javascript` | `toggle_add_javascript_config_public` | Injects `window.DecidimToggle` on the participant site |
| `layouts/decidim/admin/_header` | `toggle_add_javascript_config_admin` | Injects `window.DecidimToggle` in the admin layout |

Files: `app/overrides/add_toggle_javascript_public.rb`, `app/overrides/add_toggle_javascript_admin.rb`.

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

Docker + `./bin/check` — see [CONTRIBUTING.md](CONTRIBUTING.md) and [Developer docs](website/docs/developer/contribute.md).

## License

AGPL-3.0.
