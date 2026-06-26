---
sidebar_position: 3
title: Tab registry
description: SettingsTabRegistry, add_tab, and boot-time registration
---

# Tab registry

Extensions register tabs at boot; the System UI reads the registry to render panels and route PATCH requests.

## Boot flow

```text
Engine initializer decidim_toggle.organization_settings_tabs
  └── OrganizationSettingsTabs.register!
Your engine initializer
  └── Decidim::Toggle.settings_tabs(:organization_settings) { |tabs| tabs.add_tab ... }
        └── SettingsTabRegistry.register_form_tab(identifier, form, command, module_name:)
```

## Key files

```text
lib/decidim/toggle/settings_tabs.rb           # add_tab / remove_tab DSL
lib/decidim/toggle/settings_tab_registry.rb   # form + command map per tab id
lib/decidim/toggle/settings_tab_item.rb       # tab metadata (position, partials, if:)
lib/decidim/toggle/organization_settings_tabs.rb
app/controllers/decidim_toggle/system/settings_tab_controller.rb
```

## `add_tab` contract

One tab = one `Decidim::Form` subclass + one `Decidim::Command`.

- `identifier` — URL segment and DOM id (`panel-toggle-<identifier>`)
- `module_name:` — optional; links tab to JSON config row (`ModuleConfigForm` path)
- `remove_tab(id)` — drop a built-in tab before registering a replacement

Duplicate registration: last `add_tab` wins. In development/test, same id with a **different** form/command raises `DuplicateTabRegistrationError`.

## Save endpoint

`PATCH /decidim_toggle/system/organizations/:organization_id/settings_tab/:tab_id`

Controller resolves `registry.form_tab(tab_id)`, builds the form from params, runs the command.

## See also

- [Contribute](./contribute.md)
- [Error handling](./error-handling.md)
- [Add a settings tab](../integrate/quickstart.md) — integrator walkthrough
