# Contributing to `decidim-toggle`

This guide is for contributors and maintainers who need to understand where the important code is and how the UI override works. Install and usage are in [README.md](README.md).

## 1. Overview: what the module is, how it works

`decidim-toggle` replaces the “Advanced settings” UI in **System → Organizations** with a **tabbed** interface.

It also lets other modules register their own organization settings tabs and (optionally) persist small per-organization module configs in a JSONB table.

High-level flow:

1. The Rails engine prepends this gem’s `app/views` so our templates win before `decidim-system` (no Deface).
2. `Decidim::Toggle::OrganizationSettingsTabs.register!` registers default tabs for the `:organization_settings` registry.
3. `Decidim::Toggle::SettingsTabs` builds the ordered tab panels.
4. Each tab panel renders either:
   - a generic PATCH “form tab” (backed by a `form` + `command`), or
   - a “custom tab” that wraps a Decidim core partial.
5. After submitting a “form tab”, `SettingsTabController` runs the configured command and redirects back with the correct accordion panel opened.

Last verified Decidim line: `~> 0.29` (see `lib/decidim/toggle/version.rb`).

## 2. `/system` form: what it changes, how

### What we override

We override Decidim’s virtual view `decidim/system/organizations/edit`.

In this repo, the entrypoint is:

- `app/views/decidim/system/organizations/edit.html.erb`

That template renders the page title/callouts and then delegates the whole settings UI to:

- `app/views/decidim_toggle/system/organizations/_settings_tabs.html.erb`

### How tab panels and forms are generated

`_settings_tabs.html.erb` instantiates `Decidim::Toggle::SettingsTabs.new(:organization_settings)`, calls `build_for(self)`, and then renders:

- one accordion tab button per registered tab
- one accordion panel per tab

For each panel:

- if the tab was registered with `add_tab ... form: ..., command: ...`, we render a generic tab form (`_form_tab.html.erb`)
- if `partial:` was provided to `add_tab`, that partial is rendered inside the generic tab form

The generic “form tab” (`_form_tab.html.erb`) submits to the gem endpoint:

- PATCH `/system/organizations/:organization_id/settings_tab/:tab_id`

and includes a hidden `decidim_toggle_active_tab` field so the controller can redirect back to `System → Organizations` and reopen the saved accordion panel.

### Where PATCH requests land

- Route: `config/routes.rb`
- Controller: `app/controllers/decidim_toggle/system/settings_tab_controller.rb`

The controller:

- looks up the tab config in `SettingsTabRegistry` using `params[:tab_id]`
- builds the tab form from permitted params
- calls the configured command class with `(organization, form)`
- redirects back (with an anchor) whether the command succeeds or returns invalid.

## 3. Tab system and tab registry

### Extension contract

Other modules register tabs with:

```ruby
Decidim::Toggle.settings_tabs :organization_settings do |tabs|
  tabs.add_tab :my_tab,
                "My tab label",
                form: MyModule::AdminForm,
                command: MyModule::UpdateCommand,
                position: 8
end
```

Notes:

- `identifier` is the stable tab id (used for accordion buttons/panels and redirect anchors).
- Registration order matters: if two engines register the same `identifier`, the last one wins (see `SettingsTabRegistry#register_form_tab`).
- `add_tab` can optionally provide `module_name: ...`:
  - it ties the tab to JSON config storage (`OrganizationModuleConfig.config`) so runtime code can read module settings via `Decidim::Toggle.config_for`.

### Default registrations

Default tabs are registered in:

- `lib/decidim/toggle/organization_settings_tabs.rb`

To replace one, register your block after this engine initializer and call `remove_tab(<identifier>)` and then `add_tab` again with the same identifier.

## 4. Configuration table: why it exists, how to use it

### Why we have a config table

Modules often need per-organization admin settings, but we don’t want every module to add its own DB migration.

`decidim-toggle` stores per-organization module settings in:

- `decidim_toggle_organization_module_configs`
  - `decidim_organization_id`
  - `module_name`
  - `config` (`jsonb`)

### Public API

- `Decidim::Toggle.save_config!(organization, module_name, attributes, merge: true)`
- `Decidim::Toggle.config_for(organization, module_name, registry_name: :organization_settings)`

Behavior details:

- `save_config!` shallow-merges by default (top-level keys overwrite).
- `config_for` returns:
  - a typed presenter when a form is registered for that module name
  - otherwise the raw JSON hash (as an indifferent hash).

### Example: persist an `enabled` boolean

1) Create a config-backed form:

```ruby
class DecidimGeo::AdminConfigForm < Decidim::Form
  include Decidim::Toggle::ModuleConfigForm

  self.module_config_name = "decidim_geo"

  attribute :enabled, :boolean
end
```

2) Register the tab and use the generic persistence command:

```ruby
tabs.add_tab :geo,
              "Geo",
              form: DecidimGeo::AdminConfigForm,
              command: Decidim::Toggle::UpdateModuleConfigCommand,
              position: 8,
              module_name: :decidim_geo
```

3) Read it at runtime:

```ruby
geo_cfg = Decidim::Toggle.config_for(organization, :decidim_geo)
geo_cfg.enabled? # => true/false
```

## 5. File architecture

This is the minimum set of files a newcomer should read first (UI override, tab registry, config persistence).

```text
.
├── lib/decidim/toggle/engine.rb # Rails engine: mounts routes + prepends views
├── lib/decidim/toggle.rb # Public API: `settings_tabs` registration hook
├── lib/decidim/toggle/module_config.rb # JSONB API: `config_for` + `save_config!`
├── lib/decidim/toggle/organization_settings_tabs.rb # Default tab registrations
├── lib/decidim/toggle/settings_tabs.rb # Builds the list of tabs/panels
├── lib/decidim/toggle/settings_tab_registry.rb # Registry of form/command per tab/module
├── lib/decidim/toggle/settings_tab_item.rb # Tab metadata (open/visible/partial/form)
├── config/routes.rb # Tab PATCH endpoint route
├── app/controllers/decidim_toggle/system/settings_tab_controller.rb # Handles tab form PATCH requests
├── app/views/decidim/system/organizations/edit.html.erb # Override entrypoint for System → Organizations
├── app/views/decidim_toggle/system/organizations/_settings_tabs.html.erb # Accordion + panel renderer
├── app/views/decidim_toggle/system/organizations/_form_tab.html.erb # Generic “form tab” wrapper (PATCH + submit)
├── app/views/decidim_toggle/system/organizations/_custom_organization_tab.html.erb # Wraps Decidim core partials
├── app/views/decidim_toggle/system/organizations/_settings_tab_submit.html.erb # Save button partial for form tabs
├── app/views/decidim_toggle/system/organizations/_settings_tab_active_tab_field.html.erb # Hidden field used for redirect anchors
├── app/views/decidim_toggle/system/organizations/tabs/language_tab.html.erb # Language tab UI layout
├── app/views/decidim_toggle/system/organizations/tabs/authorizations_tab.html.erb # Authorizations tab UI layout
├── app/views/decidim_toggle/system/organizations/tabs/security_tab.html.erb # Security tab UI layout
├── app/views/decidim_toggle/system/organizations/tabs/file_upload_tab.html.erb # File upload tab UI layout
├── app/forms/concerns/decidim/toggle/module_config_form.rb # Mixin: reads/writes JSON config in forms
├── app/commands/decidim/toggle/update_module_config_command.rb # Generic command: persists a ModuleConfigForm into JSONB
└── db/migrate/20260321120000_create_decidim_toggle_organization_module_configs.rb # Creates `decidim_toggle_organization_module_configs`
```

## 6. References

- Decidim 0.29 stable “System → Organizations edit” template (the one we override):
  - [`decidim-system/app/views/decidim/system/organizations/edit.html.erb`](https://github.com/decidim/decidim/blob/release/0.29-stable/decidim-system/app/views/decidim/system/organizations/edit.html.erb)
- Deface (we do **not** use it): [spree/deface](https://github.com/spree/deface)
- Similar registry pattern in Decidim (menu customization docs): [Decidim menu customization (0.29)](https://docs.decidim.org/en/v0.29/customize/menu.html)
