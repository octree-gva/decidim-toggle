---
sidebar_position: 1
slug: /
title: Overview
description: Tabbed System administration for Decidim — register org settings from your module
---

# Decidim Toggle

decidim-toggle rewrites **System → Organizations** in the Decidim admin. Instead of one long form, settings are grouped in tabs. The gem ships built-in tabs (name, OmniAuth, SMTP, language, authorizations, security, file upload) and exposes a small API so your `decidim-*` module can add its own tab.

With this gem you **add a tab**, **plug in your form and command**, and **read or write configuration** per organization through `Decidim::Toggle.config_for` — no extra tables .


<div class="full">

![Decidim Toggle /system menu for security](/img/screenshots_security_tab.png)

</div>


## Compare


|  | Decidim | Decidim Toggle |
| -- | ------| --------------- |
| Update tenant name, host | ✅ | ✅ |
| Advanced configuration | ✅ | ✅ |
| Update SMTP credentials | ✅ | ✅ |
| Configure machine translation | ❌ | ✅ |
| Change locales | ❌ | ✅ |
| Can extend the /system | ❌ | ✅ |



## Get started

<div class="full">

![How it works](/img/schema_overview.png)

</div>


### Use in your `decidim-*` gem

Add the dependency in your gemspec:

```ruby
# decidim-my_module.gemspec
s.add_dependency "decidim-toggle"
```

Then register a tab in your engine — full steps in [Add a settings tab](./integrate/quickstart.md).

### Install in a Decidim app (optional)

Add to the Gemfile:

```ruby
gem "decidim-toggle"
```

```bash
bundle install
rails decidim_toggle:install:migrations
rails db:migrate
```

## Compatibility

Tested on Decidim **0.29**. Works on **0.31** as well (same System organization surface and Form/Command contract).

## See also

| You are… | Read |
|----------|------|
| Building a module tab | [Integrate](./integrate/index.md) → [Add a settings tab](./integrate/quickstart.md) |
| Hacking decidim-toggle | [Contribute](/contributing) |
| Something wrong | [GitLab issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/issues) |
