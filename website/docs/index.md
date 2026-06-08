---
sidebar_position: 1
slug: /
title: Overview
description: Register organization settings tabs from your Decidim module
---

# Decidim Toggle

Register a **settings tab** in **System → Organizations**. Each tab is one **Form** and one **Command**.

**Who reads this:** anyone new to the gem. Module developers continue to [Integrate](./integrate/index.md).

## Start here

| You build | Go to |
|-----------|-------|
| A `decidim-*` module with org settings | [Integrate → Add a settings tab](./integrate/quickstart.md) |
| Changes to `decidim-toggle` itself | [Contribute](./developer/contribute.md) |
| API lookup while coding | [API surface](./reference/api-surface.md) |

## How it fits

```text
Your engine (after decidim_toggle.organization_settings_tabs)
  └── Decidim::Toggle.settings_tabs(:organization_settings) → add_tab form:, command:
        └── System → Organizations → your tab → PATCH → your Command
```

## Host install

```ruby
gem "decidim-toggle"
```

```bash
bundle install
rails decidim_toggle:install:migrations
rails db:migrate
```

Decidim **~> 0.29**.

## See also

- [Integrator reading order](./README.md#integrator-reading-order)
- [Integrate](./integrate/index.md)
