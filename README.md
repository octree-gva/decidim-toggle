# Decidim Toggle

A Decidim module that enables a **feature toggle** for system administration: it replaces the default "Advanced settings" panel with a tabbed interface and allows other modules to register their own tabs and forms.

Contributing and repo layout: [CONTRIBUTING.md](CONTRIBUTING.md).

## Run locally

Use Docker and `./bin/check` as described in **Development and checks** below. If you only need a quick reference: `docker compose up -d`, then `docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc) && ./bin/check'`.

## What it does

- Replaces the single "Show advanced settings" button and collapsed panel in **System → Organizations** with a tabbed UI.
- Organizes settings into tabs: **OmniAuth**, **Emails**, **Language**, **Security**, **Other** (and extensible by other modules).
- Supplies [`app/views/decidim/system/organizations/edit.html.erb`](app/views/decidim/system/organizations/edit.html.erb) via a prepended view path (no outer `<form>`; each tab has its own form and submit).

### HTML / view overrides

- **Mechanism:** `prepend_view_path` in the engine (not Deface). Templates live under `app/views/decidim/` and `app/views/decidim_toggle/`.
- **Upstream template:** virtual path `decidim/system/organizations/edit` — compare with `decidim-system` when upgrading Decidim.
- **Verified against Decidim:** `~> 0.29` (see `lib/decidim/toggle/version.rb`). Drift coverage: `spec/decidim/overrides/advanced_settings_spec.rb`.

## Installation

Add to your Gemfile:

```ruby
gem "decidim-toggle"
```

Then:

```bash
bundle install
```

## Extending (other modules)

### System UI tabs

Register a block with `Decidim::Toggle.settings_tabs :organization_settings` (after the gem’s initializer) and call `add_tab` with your `Decidim::Form` and `Decidim::Command` (optionally pass `partial:` to render a vanilla Decidim core partial inside the tab form).

Optional **`module_name:`** (e.g. `:decidim_geo`) ties the tab to JSON config storage and to the runtime API below. Use **one tab per `module_name`** for config.

### JSON module config (no extra tables)

Run `rails db:migrate` so `decidim_toggle_organization_module_configs` exists.

- **`Decidim::Toggle.save_config!(organization, :your_module, { "enabled" => true })`** — shallow-merges into the JSON blob by default; pass **`merge: false`** to replace the whole object.
- **`Decidim::Toggle.config_for(organization, :your_module)`** — if a form is registered for that `module_name` via `add_tab ..., module_name:`, returns a **`Decidim::Toggle::ModuleConfigurationPresenter`** (typed readers, `enabled?`, nil → `[]` / `{}` for array/hash attributes). Otherwise returns an indifferent hash of raw JSON.

Use **`Decidim::Toggle::ModuleConfigForm`** on your form: set **`self.module_config_name = "your_module"`** and implement attributes as usual; **`from_model(organization)`** loads from JSON. Submit the system tab through **`Decidim::Toggle::UpdateModuleConfigCommand`** when you do not need custom persistence logic.

### Tab layout

- **`add_tab`**: each tab renders a `form_with` to the generic settings-tab endpoint (`SettingsTabController`). Implement **`form_layout_partial:`** when you need a custom layout; otherwise the default `form_tab` partial is used. If you pass **`partial:`**, that partial is rendered inside the tab form body.

If another engine also overrides **`decidim/system/organizations/edit`**, resolve the conflict by merging templates or adjusting view path precedence so the tabbed layout and per-tab forms stay consistent.

## Development and checks (Docker)

Use **`octree/decidim-dev:0.29`** and **`postgres:17`** via Compose. Do not rely on the host for Ruby/Yarn for this module.

```bash
docker compose up -d
docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc)'
```

| Check | Command (inside `/home/module`) |
|--------|----------------------------------|
| All (RuboCop + ERB Lint + RSpec) | `./bin/check` |
| RuboCop | `bundle exec rubocop .` |
| ERB Lint | `bundle exec erblint --lint-all --enable-all-linters` |
| Prettier | `yarn install --frozen-lockfile && yarn format:check` |
| Dummy app | `DISABLED_DOCKER_COMPOSE=true bundle exec rake test_app` (if `spec/decidim_dummy_app` is missing) |
| RSpec | `unset DATABASE_URL && RAILS_ENV=test bundle exec rspec` |

From the repo root with Compose running: `docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc) && ./bin/check'`.

For tests, **`unset DATABASE_URL`** so the dummy app’s `config/database.yml` is used (Compose sets `DATABASE_URL` for development). **`./bin/check`** does that before RSpec.

**CI parity:** `./bin/check` matches the **Ruby** lint + test jobs (RuboCop, erblint, RSpec). Full GitLab CI also runs **Prettier**, **Crowdin** lint/upload (and optional translation bot jobs), and **gem publish** on tags — run `yarn format:check` locally when you change files Prettier owns. Details: [CONTRIBUTING.md — Local checks and CI](CONTRIBUTING.md#local-checks-and-ci).

## License

AGPL-3.0.
