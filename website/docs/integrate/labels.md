---
sidebar_position: 4
title: Labels
description: Field labels and helptext for module config tabs
---

# Labels

Forms that include `Decidim::Toggle::ModuleConfigForm` resolve **field labels** and **helptext** from a module-specific I18n scope derived from `module_config_name`.

## Label scope

| Form setting | I18n scope |
|--------------|------------|
| `self.module_config_name = "decidim_geo"` | `decidim_toggle.system.decidim_geo` |
| `self.module_config_name = "spaces"` | `decidim_toggle.system.spaces` |

Example locale file in your module gem:

```yaml
# config/locales/my_module_en.yml
en:
  decidim_toggle:
    system:
      decidim_geo:
        enabled: Enable Decidim Geo
        search_bar: Enable search in geo drawer
        helptext:
          search_bar: Shown in the map drawer when geo is enabled.
```

Field labels use:

`decidim_toggle.system.<module_config_name>.<attribute>`

Add one key per form attribute in your module locale files.

## Helptext

Optional copy under a field uses a `helptext` sub-key in the same module scope:

`decidim_toggle.system.<module_config_name>.helptext.<attribute>`

## Tab title vs field labels

The **tab button label** is the second argument to `add_tab` — it is not read from this scope:

```ruby
tabs.add_tab :decidim_geo, I18n.t("decidim.geo.system.tab"), ...
```

Keep tab titles in your module’s own locale tree; keep **field** labels under `decidim_toggle.system.<module_config_name>`.

## Custom labels

Override only when you need an exception:

```ruby
def self.human_attribute_name(attr, options = {})
  return "Special case" if attr == :legacy_flag

  super
end
```

## See also

- [Add a settings tab](./quickstart.md)
- [Attributes](./attributes.md)
- [Customize views](./customize-views.md)
