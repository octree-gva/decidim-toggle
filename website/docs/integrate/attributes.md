---
sidebar_position: 3
title: Attributes
description: Form attributes supported by SettingsFormBuilder
---

# Attributes

**Who reads this:** module developers defining tab form fields.  
**Prerequisite:** [Add a settings tab](./quickstart.md) — form class from step 1.  
**Next:** [Informative callouts](./informative_callout.md) or [Customize views](./customize-views.md).

Declare attributes on your `Decidim::Form`. `Decidim::Toggle::SettingsFormBuilder` renders them via `all_fields` (default tab) or `fields_for_names` (inside a `form_layout_partial:`).

```ruby
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"
    mimic :organization

    attribute :enabled, :boolean
    attribute :api_key, :string
    attribute :max_items, :integer
    attribute :mode, :string
    attribute :tags, [String]

    def self.collection_for_mode
      [%w[live Live], %w[draft Draft]]
    end
  end
end
```

## Supported attribute types

| Declaration | Widget | Notes |
|-------------|--------|-------|
| `attribute :x, :boolean` | Checkbox | |
| `attribute :x, :string` | Text field | `secondary_hosts` renders as textarea |
| `attribute :x, :integer` | Number field | |
| Other scalar types | Text field | Fallback when no collection |
| `attribute :x, [String]` + `collection_for_x` | Check boxes | Multi-select |
| Scalar + `collection_for_x` | Radio buttons | Single choice |
| `translatable_attribute :x, String` | Translated field | Requires `Decidim::TranslatableAttributes`; locale keys hidden from `all_fields` |
| `translatable_attribute :x, Decidim::Attributes::RichText` | Translated editor | Rich text per locale |

`id` and per-locale keys (e.g. `name_en`) are excluded from `all_fields` when they belong to a translatable hash.

## Collections

Add `collection_for_<attribute_name>` returning `[[value, label], ...]`:

```ruby
attribute :users_registration_mode, :string

def self.collection_for_users_registration_mode
  Decidim::Organization.users_registration_modes.map do |mode|
    [mode.first, I18n.t("decidim.system.organizations.users_registration_mode.#{mode.first}")]
  end
end
```

- **Scalar attribute** → radio buttons  
- **Array attribute** (`[String]`, etc.) → check boxes  

## Field helptext

Optional copy under a field — see [Labels](./labels.md).

```yaml
# config/locales/my_module_en.yml
en:
  decidim_toggle:
    system:
      my_module:
        helptext:
          api_key: "Shown to server-side jobs only."
```

## Disabled fields

Disable a field in the default builder by implementing either:

- `#attribute_disabled?(attribute)` on the form instance, or
- `#disabled_for_<attribute>?` per attribute

```ruby
def attribute_disabled?(attribute)
  attribute == :beta_enabled && !Decidim::Toggle.gem_present?("decidim-beta")
end
```

Disabled inputs are not submitted; keep your command aligned (ignore or reject unknown params).

The field wrapper gets `class="field is-disabled"` (Decidim convention) so you can style muted labels/inputs in CSS.

## Builder methods

| Method | Use |
|--------|-----|
| `f.all_fields` | Every form attribute (default tab body) |
| `f.fields_for_names(:enabled, :mode)` | Named subset inside a partial or layout |

Used in views as `f` / `tf` (`Decidim::Toggle::SettingsFormBuilder`).

## Nested or custom widgets

Nested forms (e.g. `Decidim::System::FileUploadSettingsForm`) or non-standard markup are **not** auto-rendered. Use `form_layout_partial:` — [Customize views](./customize-views.md).

For info, warning, and danger banners above the fields, see [Informative callouts](./informative_callout.md).

## See also

- [Add a settings tab](./quickstart.md)
- [Labels](./labels.md)
- [Informative callouts](./informative_callout.md)
- [Customize views](./customize-views.md)
- [JavaScript](./javascript.md)
- [Integrate](./index.md)
