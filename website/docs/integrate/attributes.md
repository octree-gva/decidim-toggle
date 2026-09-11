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
    include Decidim::Toggle::TabForm
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"
    mimic :organization

    attribute :enabled, :boolean
    attribute :api_key, :string
    attribute :max_items, :integer
    attribute :mode, :string
    attribute :notes, :string
    attribute :tags, [String]

    disable :api_key, if_unchecked: :enabled
    encrypted :api_key

    def self.select_for_mode
      [%w[live Live], %w[draft Draft]]
    end

    def self.cols_for_notes
      55
    end

    def self.collection_for_tags
      [%w[a Alpha], %w[b Beta]]
    end
  end
end
```

## Supported attribute types

| Declaration | Widget | Notes |
|-------------|--------|-------|
| `attribute :x, :boolean` | Checkbox | |
| `attribute :x, :string` | Text field | Max width `55rem` in the settings UI |
| `attribute :x, :integer` | Number field | |
| `cols_for_x` | Text area | Declaring cols opts the string attribute into a textarea |
| `secondary_hosts` (string) | Text area | Built-in exception; use `cols_for_secondary_hosts` for width |
| Other scalar types | Text field | Fallback when no collection |
| `attribute :x, [String]` + `collection_for_x` | Check boxes | Multi-select |
| Scalar + `collection_for_x` | Radio buttons | Single choice |
| Scalar + `select_for_x` | Dropdown (`<select>`) | Prefer over `collection_for_x` when both exist |
| `translatable_attribute :x, String` | Translated field | Requires `Decidim::TranslatableAttributes`; locale keys hidden from `all_fields` |
| `translatable_attribute :x, Decidim::Attributes::RichText` | Translated editor | Rich text per locale |
| `encrypted :x` plus `attribute :x, :string` | Mask + empty password | Stored with `Decidim::AttributeEncryptor`; never sent to `window.DecidimToggle` |

`id` and per-locale keys (e.g. `name_en`) are excluded from `all_fields` when they belong to a translatable hash.

## Filter authorization workflows

Do not prepend `Decidim::Toggle::UpdateAuthorizationsForm`. Register a filter so the System authorizations tab only lists workflows your module allows:

```ruby
Decidim::Toggle.filter_authorization_workflows do |workflow, organization|
  MyModule.workflow_allowed?(workflow, organization)
end
```

Instance `collection_for_available_authorizations` (and the ephemeral picker collection) uses `Decidim::Toggle.authorization_workflows_for(organization)`.

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

### Dropdowns

Use `select_for_<attribute_name>` (same `[[value, label], ...]` shape) for a compact `<select>`:

```ruby
def self.select_for_mode
  [%w[live Live], %w[draft Draft]]
end
```

## Text areas

Declare `cols_for_<attribute>` to render a string attribute as a textarea:

```ruby
def self.cols_for_notes
  55
end
```

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
- `#disabled_for_<attribute>?` per attribute, or
- `disable :field, if_unchecked: :boolean_attr` (via `TabForm` / `FieldConditions`)

### Disable when a checkbox is unchecked

```ruby
include Decidim::Toggle::TabForm # or FieldConditions

attribute :enabled, :boolean
attribute :api_key, :string

disable :api_key, if_unchecked: :enabled
```

That is enough: the builder marks the field disabled on render, and the settings-tab JS toggles it live when the checkbox changes.

```ruby
def attribute_disabled?(attribute)
  attribute == :beta_enabled && !Decidim::Toggle.gem_present?("decidim-beta")
end
```

Disabled inputs are not submitted; keep your command aligned (ignore or reject unknown params).

The field wrapper is BEM: `field field--<attribute> field--<type>` (`--checkbox`, `--checkboxes`, `--radios`, `--text`, `--textarea`, `--select`, `--password`). Disabled fields also get `is-disabled` (Decidim convention) so you can style muted labels/inputs in CSS.

## Encrypted strings

Keep the string attribute and register the secret:

```ruby
attribute :api_key, :string
encrypted :api_key
```

`UpdateModuleConfigCommand` encrypts with `Decidim::AttributeEncryptor` and stores `api_key_count` / `api_key_last4` beside the ciphertext. A blank submit omits those keys so the previous secret is kept. `config_for` decrypts for Ruby callers. The admin UI shows a non-editable mask (`*` per character, or the last four characters when length is greater than 32) and an **edit secret** link that reveals an empty password field.

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
