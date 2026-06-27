---
sidebar_position: 4
title: Labels
description: Field labels and helptext for module config tabs
---

# Labels

Forms that include `Decidim::Toggle::ModuleConfigForm` resolve **field labels**, **helptext**, and the **tab title** from `decidim_toggle.system.<module_name>`.

## Module name

Define one constant in your module and reuse it everywhere:

```ruby
# lib/decidim/my_module.rb
module Decidim
  module MyModule
    MODULE_NAME = "my_module"
  end
end
```

```ruby
# app/forms/my_module/admin_config_form.rb
self.module_config_name = Decidim::MyModule::MODULE_NAME

# lib/decidim/my_module/engine.rb
tabs.add_tab :my_module,
             I18n.t("decidim_toggle.system.#{Decidim::MyModule::MODULE_NAME}.tab"),
             form: MyModule::AdminConfigForm,
             command: Decidim::Toggle::UpdateModuleConfigCommand,
             module_name: Decidim::MyModule::MODULE_NAME
```

`module_config_name`, `module_name:` on `add_tab`, and the locale path must all match.

## Locale files

Keep toggle strings in dedicated files — one per locale:

```
config/locales/decidim_toggle.en.yml
config/locales/decidim_toggle.fr.yml
```

```yaml
# config/locales/decidim_toggle.en.yml
en:
  decidim_toggle:
    system:
      my_module:
        tab: My module
        enabled: Enable my module
        helptext:
          enabled: Applies to this organization only.
```

| Key | Use |
|-----|-----|
| `tab` | Tab button label (`I18n.t("decidim_toggle.system.<module_name>.tab")`) |
| `<attribute>` | Field label (via `ModuleConfigForm`) |
| `helptext.<attribute>` | Optional help copy under a field |

Field labels use:

`decidim_toggle.system.<module_name>.<attribute>`

## Helptext

Optional copy under a field uses a `helptext` sub-key in the same module scope:

`decidim_toggle.system.<module_name>.helptext.<attribute>`

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
