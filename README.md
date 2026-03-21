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

- **Add a tab**: register a new tab in the settings tabs (API to be defined).
- **Form**: pass the same organization form builder `f` so data is submitted with the organization form.
- **Custom form view**: you can define a custom partial for your tab content.

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
