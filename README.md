# Decidim Toggle

A Decidim module that enables a **feature toggle** for system administration: it replaces the default "Advanced settings" panel with a tabbed interface and allows other modules to register their own tabs and forms.

## What it does

- Replaces the single "Show advanced settings" button and collapsed panel in **System → Organizations** with a tabbed UI.
- Organizes settings into tabs: **Registration**, **Emails**, **Language**, **Security**, **Other** (and extensible by other modules).
- Uses [Deface](https://github.com/spree/deface) to override `decidim/system/organizations/edit` without forking Decidim.

## Installation

Add to your Gemfile:

```ruby
gem "decidim-toggle"
gem "deface", "~> 1.9"
```

Then:

```bash
bundle install
```

## Extending (other modules)

### System UI tabs

Register a block with `Decidim::Toggle.settings_tabs :organization_settings` (after the gem’s initializer) and call `add_tab` with your `Decidim::Form` and `Decidim::Command`, or `add_custom_tab` for a vanilla Decidim partial.

Optional **`module_name:`** (e.g. `:decidim_geo`) ties the tab to JSON config storage and to the runtime API below. Use **one tab per `module_name`** for config.

### JSON module config (no extra tables)

Run `rails db:migrate` so `decidim_toggle_organization_module_configs` exists.

- **`Decidim::Toggle.save_config!(organization, :your_module, { "enabled" => true })`** — shallow-merges into the JSON blob by default; pass **`merge: false`** to replace the whole object.
- **`Decidim::Toggle.config_for(organization, :your_module)`** — if a form is registered for that `module_name` via `add_tab ..., module_name:`, returns a **`Decidim::Toggle::ModuleConfigurationPresenter`** (typed readers, `enabled?`, nil → `[]` / `{}` for array/hash attributes). Otherwise returns an indifferent hash of raw JSON.

Use **`Decidim::Toggle::ModuleConfigForm`** on your form: set **`self.module_config_name = "your_module"`** and implement attributes as usual; **`from_model(organization)`** loads from JSON. Submit the system tab through **`Decidim::Toggle::UpdateModuleConfigCommand`** when you do not need custom persistence logic.

### Tab layout

- **Form**: use the same organization form builder `f` so the tab panels submit with the main organization form where applicable.
- **Custom form view**: set **`form_layout_partial:`** on `add_tab` or rely on the default `form_tab` partial.

## Development and checks (Docker)

Use **`octree/decidim-dev:0.29`** and **`postgres:17`** via Compose. Do not rely on the host for Ruby/Yarn for this module.

```bash
docker compose up -d
docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc)'
```

| Check | Command (inside `/home/module`) |
|--------|----------------------------------|
| RuboCop | `bundle exec rubocop .` |
| ERB Lint | `bundle exec erblint --lint-all --enable-all-linters` |
| Prettier | `yarn install --frozen-lockfile && yarn format:check` |
| Dummy app | `DISABLED_DOCKER_COMPOSE=true bundle exec rake test_app` (if `spec/decidim_dummy_app` is missing) |
| RSpec | `unset DATABASE_URL && RAILS_ENV=test bundle exec rspec` |

For tests, **`unset DATABASE_URL`** so the dummy app’s `config/database.yml` is used (Compose sets `DATABASE_URL` for development).

## License

AGPL-3.0.
