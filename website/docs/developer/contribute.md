---
sidebar_position: 1
slug: /contribute
title: Contribute
description: Hack on decidim-toggle
---

# Contribute to decidim-toggle

**Who reads this:** contributors changing the **decidim-toggle** gem (not module integrators).

Module developers: [Add a settings tab](../integrate/quickstart.md).

## What this gem does

Prepends views so **System → Organizations** uses a tabbed UI.  
Extensions register tabs via `Decidim::Toggle.settings_tabs :organization_settings`.

Each tab submits to one PATCH endpoint; `SettingsTabController` runs the tab's command.

Decidim **~> 0.29** (`lib/decidim/toggle/version.rb`).

## Key files

```text
lib/decidim/toggle/settings_tabs.rb          # add_tab DSL
lib/decidim/toggle/settings_tab_registry.rb  # form/command map
lib/decidim/toggle/organization_settings_tabs.rb
app/commands/decidim/toggle/update_module_config_command.rb
lib/decidim/toggle/module_config_form.rb
lib/decidim/toggle/tab_form.rb
lib/decidim/toggle/informative_callouts.rb
app/controllers/decidim_toggle/system/settings_tab_controller.rb
```

Compare upstream drift: `spec/decidim/overrides/advanced_settings_spec.rb`.

## Checks (Docker)

```bash
docker compose up -d
docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc) && ./bin/check'
```

| Check | Command |
|-------|---------|
| All | `./bin/check` |
| RSpec | `unset DATABASE_URL && RAILS_ENV=test bundle exec rspec` |
| Docs | `cd website && yarn build` |

Unset `DATABASE_URL` before RSpec in Compose (dummy app uses `config/database.yml`).

## Doc site

Edit `website/docs/`. Build: `cd website && yarn build`.

Rules: [Documentation structure](../README.md).

## See also

- [Documentation site](./documentation.md)
- [API surface](../reference/api-surface.md)
