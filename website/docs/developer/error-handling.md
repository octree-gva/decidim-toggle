---
sidebar_position: 5
title: Error handling
description: Invalid tab saves, flash replay, and redirect anchors
---

# Error handling

Each tab PATCH is independent. Validation failures must re-open the same tab with errors — without a full page POST/redirect cycle per field.

## Happy path

`SettingsTabController#update` runs the tab command. On `:ok`:

- `flash[:notice]` — success copy
- Redirect to `decidim_system.edit_organization_path(organization)` with optional `anchor: "panel-toggle-<tab_id>"` when `decidim_toggle_active_tab` matches a registered tab

## Invalid form

On `:invalid`, the controller stores a payload in `flash[:decidim_toggle_invalid_settings_tab]`:

```ruby
{
  organization_id:,
  tab_id:,
  params: { ... submitted organization params ... },
  errors: { "attribute" => ["message", ...] }
}
```

Redirect to the organization edit page (same anchor rules).

## Replay on re-render

`decidim_toggle_settings_tab_form` checks that flash key. When `organization_id` and `tab_id` match the current tab:

1. Rebuilds the form from stored params (not the DB model)
2. Re-applies error messages on the form object
3. Renders the tab with `form-error` markup

Custom `form_layout_partial:` tabs must use `tf.object` (or fields through `tf`) inside `decidim_toggle_settings_tab_form` so replayed errors bind to inputs — see `tabs/_language_tab.html.erb`.

## Unknown tab

`PATCH …/settings_tab/<unknown>` → `404`.

## See also

- [Tab registry](./tab-registry.md)
- [View customization](./view-customization.md)
- [Contribute](./contribute.md)
