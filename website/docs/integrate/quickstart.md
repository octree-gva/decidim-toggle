---
sidebar_position: 2
title: Add a settings tab
description: Form, engine registration, optional view, verify
---

# Add a settings tab

**Who reads this:** module developers shipping a JSON-backed org settings tab.  
**Prerequisite:** `decidim-toggle` in the host Gemfile, `rails decidim_toggle:install:migrations`, and `rails db:migrate` done.

Default path: **`ModuleConfigForm`** + **`UpdateModuleConfigCommand`**.

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

More attribute types, collections, helptext, and callouts: [Attributes](./attributes.md).

## 2. Register tab

In your module engine:

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

Without `partial:` or `form_layout_partial:`, the tab renders all form attributes via the default shell.

## 3. Optional: customize form view

| Option | When | Locals | You render |
|--------|------|--------|------------|
| `partial:` | Custom field body inside the default form shell | `f`, `organization` | Fields only — toggle wraps PATCH form, submit, callouts |
| `form_layout_partial:` | Full tab layout (fieldsets, tables, mixed markup) | `tab`, `organization` | Entire tab via `decidim_toggle_settings_tab_form` |

### `partial:` — body inside default shell

```erb
<%# app/views/decidim/my_module/admin/_organization_settings_fields.html.erb %>
<%= f.fields_for_names(:enabled) %>
```

```ruby
partial: "decidim/my_module/admin/organization_settings_fields"
```

Optional: `extra_locals:` hash merged into the partial.

### `form_layout_partial:` — full tab layout

```erb
<%# app/views/decidim/my_module/admin/_organization_settings_tab.html.erb %>
<%= decidim_toggle_settings_tab_form(organization, tab) do |tf| %>
  <fieldset>
    <legend class="form-legend">My module</legend>
    <%= tf.fields_for_names(:enabled) %>
  </fieldset>
<% end %>
```

```ruby
form_layout_partial: "decidim/my_module/admin/organization_settings_tab"
```

Built-in examples in `lib/decidim/toggle/organization_settings_tabs.rb` (omniauth/emails use `partial:`; language/security use `form_layout_partial:`).

## 4. Verify

1. Boot the host app.
2. **System → Organizations → Edit** → open **My module**.
3. Toggle **enabled**, save.
4. Console: `Decidim::Toggle.config_for(organization, :my_module)[:enabled]`

## Runtime API

```ruby
Decidim::Toggle.config_for(organization, :my_module)
Decidim::Toggle.save_config!(organization, :my_module, { "enabled" => true })
```

## When this path is not enough

| Need | Use |
|------|-----|
| Fields on `Organization` (SMTP, host, …) | Custom `Decidim::Form` + custom `Decidim::Command` — [Integrate](./index.md#other-cases) |
| Reuse a decidim-system partial | `partial: "decidim/system/organizations/..."` |

## See also

- [Attributes](./attributes.md) — builder types and callouts
- [Troubleshooting](./troubleshooting.md) — tab missing, save issues
- [API surface](../reference/api-surface.md) — all `add_tab` options
- [Integrate](./index.md) — back to section overview
