---
sidebar_position: 1
title: Integrate
description: Register a settings tab from your Decidim module
---

# Integrate your module

**Who reads this:** developers of a `decidim-*` gem adding organization settings.  
**Next:** [Add a settings tab](./quickstart.md).

## Default: Form + Command

Most modules only need per-organization JSON (enabled flags, small config).  
No new tables — settings live in `decidim_toggle_organization_module_configs`.

| Piece | Class |
|-------|-------|
| Form | Your form including `Decidim::Toggle::ModuleConfigForm` |
| Command | `Decidim::Toggle::UpdateModuleConfigCommand` |
| Register | `add_tab` in your engine with `form:`, `command:`, `module_name:` |

Walkthrough: [Add a settings tab](./quickstart.md).

## Registration (all cases)

In `lib/decidim/my_module/engine.rb`, **after** `decidim_toggle.organization_settings_tabs`:

```ruby
initializer "decidim_my_module.organization_settings_tab", after: "decidim_toggle.organization_settings_tabs" do
  Decidim::Toggle.settings_tabs :organization_settings do |tabs|
    tabs.add_tab :my_module, "My module",
                 form: MyModule::AdminConfigForm,
                 command: Decidim::Toggle::UpdateModuleConfigCommand,
                 module_name: :my_module
  end
end
```

## Customize the form view

Optional `partial:` (field body) or `form_layout_partial:` (full layout) on `add_tab`.  
Details: [quickstart → step 3](./quickstart.md#3-optional-customize-form-view).

## Other cases

**Organization columns** (SMTP, host, …) — custom `Decidim::Form` + custom `Decidim::Command`; same `add_tab` contract.

## See also

1. [Add a settings tab](./quickstart.md) — procedure
2. [Attributes](./attributes.md) — field types, helptext, callouts
3. [Troubleshooting](./troubleshooting.md) — common issues
4. [API surface](../reference/api-surface.md) — option reference
