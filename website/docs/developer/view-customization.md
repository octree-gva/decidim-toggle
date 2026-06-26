---
sidebar_position: 4
title: View customization
description: Internal views that render the tabbed organization settings UI
---

# View customization

Internal templates for decidim-toggle. Integrators customize **their** tab via `form_layout_partial:` — see [Customize views](../integrate/customize-views.md).

## Override entry point

`app/views/decidim/system/organizations/edit.html.erb` — replaces the flat org edit form with `settings_tabs` partial.

## Tab shell

| Partial | Role |
|---------|------|
| `_settings_tabs.html.erb` | Tab nav + panels; encryption gate |
| `_default_form_tab.html.erb` | Default wrapper: `decidim_toggle_settings_tab_form` + `all_fields` |
| `tabs/_omniauth_tab.html.erb` | Built-in OmniAuth layout |
| `tabs/_emails_tab.html.erb` | Built-in SMTP layout |
| `_settings_tab_submit.html.erb` | Cancel / save |
| `_settings_tab_active_tab_field.html.erb` | Hidden `decidim_toggle_active_tab` |
| `_encryption_not_configured_callout.html.erb` | Shown when `encryption_configured?` is false |
| `tabs/_language_tab.html.erb` | Built-in locale table layout |
| `tabs/_security_tab.html.erb` | Built-in security layout |
| `tabs/_authorizations_tab.html.erb` | Built-in authorizations layout |
| `tabs/_file_upload_tab.html.erb` | Built-in file upload layout |

## Helpers

`Decidim::Toggle::SystemSettingsTabHelper`:

- `decidim_toggle_settings_tab_form(organization, tab)` — form shell, flash error replay, callouts
- `decidim_toggle_update_settings_tab_organization_path(organization, tab_id:)`
- `encryption_configured?`

`Decidim::Toggle::SettingsFormBuilder` — `all_fields`, `fields_for_names`, `informative_callouts`.

## Styles

`app/packs/stylesheets/decidim/toggle/organization_settings.scss` — tab accordion layout.

## See also

- [Customize views](../integrate/customize-views.md) — integrator partials
- [Tab registry](./tab-registry.md)
- [Error handling](./error-handling.md)
