---
sidebar_position: 6
title: Customize views
description: form_layout_partial for custom settings tab layouts
---

# Customize views

Without `form_layout_partial:`, decidim-toggle renders every form attribute through the default shell (`all_fields` + submit). For custom markup, provide a full tab layout partial.

## Default vs custom

| | Default | `form_layout_partial:` |
|---|---------|------------------------|
| When | Simple JSON-backed settings | Tables, fieldsets, reused decidim-system partials, mixed markup |
| Locals | — | `tab`, `organization` |
| You render | Nothing — toggle uses `all_fields` | Entire tab inside `decidim_toggle_settings_tab_form` |

Built-in examples: `lib/decidim/toggle/organization_settings_tabs.rb` and `app/views/decidim_toggle/system/organizations/tabs/`.

## Custom tab layout

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
tabs.add_tab :my_module,
             "My module",
             form: MyModule::AdminConfigForm,
             command: Decidim::Toggle::UpdateModuleConfigCommand,
             module_name: :my_module,
             form_layout_partial: "decidim/my_module/admin/organization_settings_tab"
```

`decidim_toggle_settings_tab_form` provides the PATCH form, hidden active-tab field, informative callouts, and save/cancel buttons. Do not drop the hidden `decidim_toggle_active_tab` field.

Use `tf` (`Decidim::Toggle::SettingsFormBuilder`) for fields — `tf.all_fields`, `tf.fields_for_names(:enabled)`, or pass `f: tf` to existing partials.

## Reuse decidim-system partials

```erb
<%= decidim_toggle_settings_tab_form(organization, tab) do |tf| %>
  <%= render "decidim/system/organizations/smtp_settings", f: tf %>
<% end %>
```

See `tabs/_emails_tab.html.erb` and `tabs/_file_upload_tab.html.erb` in this gem.

## See also

- [Attributes](./attributes.md) — `fields_for_names`, helptext
- [Informative callouts](./informative_callout.md)
- [Add a settings tab](./quickstart.md)
- [JavaScript](./javascript.md)
- [View customization (contributor)](../developer/view-customization.md) — internal gem views
