---
sidebar_position: 7
title: JavaScript
description: Expose organization settings to window.DecidimToggle
---

# JavaScript

Opt in per attribute to expose config on `window.DecidimToggle`. By default, settings stay server-side (`Decidim::Toggle.config_for`).

## Opt in on the form

Include `Decidim::Toggle::ExposeAttributesToJs` and list attributes explicitly — secrets are **not** exposed unless you add them.

```ruby
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::TabForm
    include Decidim::Toggle::ModuleConfigForm
    include Decidim::Toggle::ExposeAttributesToJs

    self.module_config_name = "my_module"
    mimic :organization

    attribute :enabled, :boolean
    attribute :search_bar, :boolean
    attribute :api_key, :string

    expose_to_javascript :enabled, :search_bar
    # api_key is intentionally omitted
  end
end
```

| Macro | Role |
|-------|------|
| `expose_to_javascript :attr, ...` | Registers attribute names for the current organization's config |

The tab must be registered with `module_name:` matching `module_config_name` so `config_for` can resolve values.

## Key format

Flat string keys: `"<module_config_name>.<attribute_name>"`.

```js
if (window.DecidimToggle["my_module.enabled"]) {
  document.querySelector(".search-bar")?.classList.remove("hidden");
}
```

## Supported value types

Serialized into JSON-safe values:

| Type | Exposed as |
|------|------------|
| boolean | `true` / `false` |
| string, integer, float | scalar |
| array | JSON array (elements stringified when needed) |
| hash | plain object (keys stringified) |
| translatable attribute | raw locale hash (`{ "en": "...", "ca": "..." }`) |

Unsupported types are skipped (development/test may log a warning via `ExposeAttributesToJsValidator`).

## Server-side read

Browser and server use the same underlying config:

```ruby
Decidim::Toggle.config_for(organization, :my_module)[:enabled]
Decidim::Toggle.javascript_config_for(organization) # => { "my_module.enabled" => true, ... }
```

`javascript_config_for` aggregates every registered form that includes `ExposeAttributesToJs`.

## How it reaches the page

Deface overrides insert `layouts/decidim/toggle/javascript_config` into decidim-core layouts.

## See also

- [Attributes](./attributes.md)
- [Add a settings tab](./quickstart.md)
- [Deface usage](../developer/deface-usage.md)
