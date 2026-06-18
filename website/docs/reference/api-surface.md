---
sidebar_position: 1
title: API surface
description: Form + Command registration contract
---

# API surface

**Who reads this:** module developers and gem contributors needing a quick lookup.  
**Tutorial:** [Integrate](../integrate/index.md) → [Add a settings tab](../integrate/quickstart.md).  
**Form fields:** [Attributes](../integrate/attributes.md).

## Register a tab

In your module engine, after `decidim_toggle.organization_settings_tabs`:

```ruby
initializer "decidim_my_module.organization_settings_tab", after: "decidim_toggle.organization_settings_tabs" do
  Decidim::Toggle.settings_tabs(:organization_settings) do |tabs|
    tabs.add_tab :id, "Label", form:, command:, module_name: :my_module
  end
end
```

| Method / option | Role |
|-----------------|------|
| `settings_tabs(:organization_settings)` | Registry block at boot |
| `add_tab(id, label, form:, command:, **opts)` | One tab = one form + one command |
| `module_name:` | JSON row key; required for `ModuleConfigForm` path |
| `position:`, `open:` | Tab order / default panel |
| `partial:` | Field body inside default form shell; locals `f`, `organization` |
| `form_layout_partial:` | Replaces default shell; locals `tab`, `organization`; use `decidim_toggle_settings_tab_form` |
| `extra_locals:` | Merged into `partial:` locals |
| `if:` | Hide tab when false |
| `remove_tab(id)` | Drop a built-in tab |

## Form + Command (default)

| Piece | Class / concern |
|-------|-----------------|
| Form concern | `Decidim::Toggle::ModuleConfigForm` — set `self.module_config_name` |
| Command | `Decidim::Toggle::UpdateModuleConfigCommand` |
| Optional base | `Decidim::Toggle::TabForm` — callouts + conventions |

## Save endpoint

`PATCH /system/organizations/:organization_id/settings_tab/:tab_id`  
Route helper: `decidim_toggle_update_settings_tab_organization_path`.

## Read / write config

```ruby
Decidim::Toggle.config_for(organization, :my_module) # => ActiveSupport::HashWithIndifferentAccess
Decidim::Toggle.save_config!(organization, :my_module, attrs, merge: true)
Decidim::Toggle.javascript_config_for(organization) # => { "my_module.enabled" => true, ... }
Decidim::Toggle.gem_present?("decidim-other")  # optional gem in bundle
```

`config_for` returns a normalized hash (`nil` booleans → `false`, `nil` arrays → `[]`, `nil` hashes → `{}`). Use key access: `config_for(org, :my_module)[:enabled]`.

## Expose attributes to JS

| Piece | Class / concern |
|-------|-----------------|
| `Decidim::Toggle::ExposeAttributesToJs` | `expose_to_javascript` on form classes |
| `Decidim::Toggle.javascript_config_for` | Build flat hash for `window.DecidimToggle` |

See [Attributes — Expose attributes to JS](../integrate/attributes.md#expose-attributes-to-js).

## UI helpers

| API | Use |
|-----|-----|
| `Decidim::Toggle::TabForm` | Includes `InformativeCallouts` on tab forms |
| `Decidim::Toggle::InformativeCallouts` | `info` / `warning` / `danger` — see [Attributes](../integrate/attributes.md#informative-callouts-info-warning-danger) |
| `Decidim::Toggle::SettingsFormBuilder` | `all_fields`, `fields_for_names` — see [Attributes](../integrate/attributes.md) |

## See also

- [Troubleshooting](../integrate/troubleshooting.md)
- [Documentation structure](../README.md#integrator-reading-order)
