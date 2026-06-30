# Decidim Toggle

<p align="center">
  <img src="website/static/img/logo.svg" alt="Decidim Toggle" width="120" />
</p>

[![pipeline status](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/badges/main/pipeline.svg)](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/commits/main)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](LICENSE.md)
[![Docs](https://img.shields.io/badge/docs-octree--gva.github.io-informational)](https://octree-gva.github.io/decidim-toggle/)

Register organization settings tabs for Decidim modules—one form, one command, one read API per gem.

## Contents

- [Quick start](#quick-start)
- [Host app install](#host-app-install)
- [Documentation](#documentation)
- [Development](#development-this-gem)
- [Support](#support)
- [Contributing](#contributing)
- [License](#license)

## Quick start

Add a settings tab in three steps:

1. **Form** — include `Decidim::Toggle::ModuleConfigForm`, set `module_config_name`, declare attributes.

```ruby
module MyModule
  class AdminConfigForm < Decidim::Form
    include Decidim::Toggle::ModuleConfigForm

    self.module_config_name = "my_module"
    mimic :organization
    attribute :enabled, :boolean
  end
end
```

2. **Register** — in your engine, after `decidim_toggle.organization_settings_tabs`:

```ruby
initializer "decidim_my_module.organization_settings_tab", after: "decidim_toggle.organization_settings_tabs" do
  Decidim::Toggle.settings_tabs :organization_settings do |tabs|
    tabs.add_tab :my_module, "My module",
                 form: MyModule::AdminConfigForm,
                 command: Decidim::Toggle::UpdateModuleConfigCommand,
                 module_name: :my_module
  end
end
```

3. **Read** — `Decidim::Toggle.config_for(organization, :my_module)`.

Optional view partial: `form_layout_partial:` on `add_tab` — see [Customize views](https://octree-gva.github.io/decidim-toggle/integrate/customize-views).

Full walkthrough: [Add a settings tab](https://octree-gva.github.io/decidim-toggle/integrate/quickstart).

## Host app install

```ruby
gem "decidim-toggle"
```

```bash
bundle install
rails decidim_toggle:install:migrations
rails db:migrate
```

## Documentation

[octree-gva.github.io/decidim-toggle](https://octree-gva.github.io/decidim-toggle/) — integrator guides (registration, views, storage) and contributor docs.

## Development (this gem)

Docker + `./bin/check` (RuboCop, erblint, RSpec) — see [CONTRIBUTING.md](CONTRIBUTING.md) and [Contribute](https://octree-gva.github.io/decidim-toggle/contributing).

## Support

[GitLab issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/issues) for bugs and integration questions.

## Contributing

Pull requests welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a merge request.

## License

[AGPL-3.0](LICENSE.md).
