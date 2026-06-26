---
sidebar_position: 2
title: Add a settings tab
description: Form, engine registration, verify
---

# Add a settings tab

Register a form and command, then verify persistence.

## 1. Form

```ruby
# app/forms/my_module/admin_config_form.rb
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"

    mimic :organization

    attribute :enabled, :boolean
  end
end
```

## 2. Register tab

In your module engine, **after** `decidim_toggle.organization_settings_tabs`:

```ruby
# lib/decidim/my_module/engine.rb
initializer "decidim_my_module.organization_settings_tab", after: "decidim_toggle.organization_settings_tabs" do
  Decidim::Toggle.settings_tabs :organization_settings do |tabs|
    tabs.add_tab :my_module,
                 "My module",
                 form: MyModule::AdminConfigForm,
                 command: Decidim::Toggle::UpdateModuleConfigCommand,
                 module_name: :my_module,
                 position: 10
  end
end
```

| Option | Role |
|--------|------|
| `module_name:` | JSON row key; must match `module_config_name` on the form |
| `position:` | Tab order (default: append) |
| `open:` | Open this panel by default |
| `if:` | Hide tab when false |
| `form_layout_partial:` | Custom tab layout — [Customize views](./customize-views.md) |

## 3. Verify

1. Boot the host app.
2. **System → Organizations → Edit** → open **My module**.
3. Toggle **enabled**, save.
4. Console: `Decidim::Toggle.config_for(organization, :my_module)[:enabled]`

## Read / write config

```ruby
Decidim::Toggle.config_for(organization, :my_module)
Decidim::Toggle.save_config!(organization, :my_module, { "enabled" => true })
```

## Organization columns

When settings live on `Decidim::Organization` (SMTP, host, locales, …), use a custom `Decidim::Form` + custom `Decidim::Command` with the same `add_tab` contract. See built-in tabs in `lib/decidim/toggle/organization_settings_tabs.rb`.

## See also

- [Integrate](./index.md)
- [Attributes](./attributes.md)
- [Informative callouts](./informative_callout.md)
- [Customize views](./customize-views.md)
