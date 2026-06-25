---
sidebar_position: 3
title: Attributes
description: Form attributes and callouts supported by SettingsFormBuilder
---

# Attributes

**Who reads this:** module developers defining tab form fields.  
**Prerequisite:** [Add a settings tab](./quickstart.md) step 1 (form class).  
**Next:** apply in [quickstart step 3](./quickstart.md#3-optional-customize-form-view) if you use a partial, or save with the default `all_fields`.

Declare attributes on your `Decidim::Form`.  
`Decidim::Toggle::SettingsFormBuilder` renders them via `all_fields` (default tab) or `fields_for_names` (in a `partial:` / `form_layout_partial:`).

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

Optional copy under a field via I18n (use `helptext`, not the attribute label key):

```yaml
# config/locales/my_module_en.yml
en:
  activemodel:
    attributes:
      organization:  # or your form model_name i18n_key
        helptext:
          api_key: "Shown to server-side jobs only."
```

Lookup: `activemodel.attributes.<model>.helptext.<attribute_name>`.

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

Nested forms (e.g. `Decidim::System::FileUploadSettingsForm`) or non-standard markup are **not** auto-rendered. Use `partial:` or `form_layout_partial:` — [quickstart step 3](./quickstart.md#3-optional-customize-form-view).

## Informative callouts (info, warning, danger)

Callouts render **above** the tab field body, inside the shared form shell (submit + active-tab field unchanged).

Include `Decidim::Toggle::TabForm` (recommended) or `Decidim::Toggle::InformativeCallouts` on the form class:

```ruby
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::TabForm
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"
    mimic :organization

    attribute :enabled, :boolean

    info "Defaults apply to new organizations only."

    info :installed_modules_callout,
         if_predicate: ->(form) { form.missing_modules.any? }

    warning ->(form) { "Disabling removes public access to #{form.module_label}." },
             if_predicate: ->(form) { form.enabled == false }

    danger "Requires decidim-other in the Gemfile.",
           if_predicate: ->(*) { Decidim::Toggle.gem_present?("decidim-other") }

    def installed_modules_callout
      I18n.t("my_module.admin.missing_modules", missing: missing_modules.join(", "))
    end
  end
end
```

| Macro | Style | When to use |
|-------|-------|-------------|
| `info "message"` | Info (blue) | Static context, pointers to other tabs |
| `info :method_name` | Info (blue) | Dynamic copy from a form instance method |
| `info ->(form) { ... }` | Info (blue) | Inline dynamic copy |
| `warning "message", if_predicate:` | Warning (yellow) | Reversible caution before save |
| `danger "message", if_predicate:` | Alert (red) | Strong caution, destructive or risky change |

`if_predicate` receives the form instance; omit it to always show the callout.

`message` (first argument to `info` / `warning` / `danger`) may be:

| Form | Resolved at render time by `InformativeEntry#message_for` |
|------|-----------------------------------------------------------|
| `String` | Used as-is |
| `Symbol` | `form.public_send(symbol)` — e.g. `info :installed_modules_callout` |
| `Proc` | `proc.call(form)` — e.g. `info ->(form) { ... }` |

Dynamic example (symbol + conditional visibility):

```ruby
info :installed_modules_callout,
     if_predicate: ->(form) { form.missing_modules.any? }

def installed_modules_callout
  I18n.t("my_module.admin.missing_modules", missing: missing_modules.join(", "))
end
```

Callouts render via `SettingsFormBuilder#informative_callouts` in the default tab shell (`decidim_toggle_settings_tab_form`), **above** the field body or `partial:`.

## Expose attributes to JS

Expose selected config values to the browser as a flat global `window.DecidimToggle` hash (participant and admin layouts). Opt in explicitly — secrets such as API keys are **not** exposed unless you mark them.

Include `Decidim::Toggle::ExposeAttributesToJs` on your form:

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
    expose_to_javascript :enabled, :search_bar
  end
end
```

| Mechanism | Use |
|-----------|-----|
| `expose_to_javascript :attr` | List attributes to expose on `window.DecidimToggle` |

**Key format:** `"<module_config_name>.<attribute_name>"` (dot in the string), e.g. `"my_module.enabled"`.

**Supported value types:** boolean, string, integer, array, hash. Translatable attributes are exposed as the raw locale hash.

**Client usage:**

```js
if (window.DecidimToggle["my_module.enabled"]) {
  // ...
}
```

Values reflect the current organization (`current_organization`). Server-side reads remain `Decidim::Toggle.config_for(organization, :my_module)`.

## See also

- [Add a settings tab](./quickstart.md)
- [API surface](../reference/api-surface.md) — `TabForm`, `partial:`, `form_layout_partial:`
- [Troubleshooting](./troubleshooting.md)
