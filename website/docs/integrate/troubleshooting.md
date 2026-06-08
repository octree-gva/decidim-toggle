---
sidebar_position: 4
title: Troubleshooting
description: Common integrator issues
---

# Troubleshooting

**Who reads this:** module developers when a tab does not show, save fails, or config does not persist.  
**Start with:** [Add a settings tab](./quickstart.md) if you have not completed the basic path.

## Tab does not appear

- Confirm `decidim-toggle` is in the Gemfile and the engine loaded.
- Registration must run **after** `decidim_toggle.organization_settings_tabs` (`after:` on your engine initializer).
- Check `tabs.add_tab` `position` and optional `if:` visibility.

## Save succeeds but wrong panel opens

- Tab `identifier` must match the accordion id (`panel-toggle-<identifier>`).
- Hidden field `decidim_toggle_active_tab` is set by the form shell; do not drop it in custom layouts.

## Config does not persist

- `module_name:` on `add_tab` must match `self.module_config_name` on the form.
- Run host `rails decidim_toggle:install:migrations` then `rails db:migrate` for `decidim_toggle_organization_module_configs`.

## Duplicate tab or silent override

- Last `add_tab` with the same `identifier` wins. In development/test, re-registering the same id raises.

## Custom layout without callouts or submit

- Use `decidim_toggle_settings_tab_form(organization, tab)` in `form_layout_partial:` — see [quickstart step 3](./quickstart.md#3-optional-customize-form-view).

## Contributor-only: tests fail with DATABASE_URL

- When developing **decidim-toggle** itself, run `unset DATABASE_URL` before RSpec in Docker (`./bin/check`). See [Contribute](../developer/contribute.md).

## See also

- [Attributes](./attributes.md) — field types and callouts
- [API surface](../reference/api-surface.md)
- [Integrate](./index.md)
