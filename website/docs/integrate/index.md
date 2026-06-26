---
sidebar_position: 1
title: Integrate
description: Add organization settings from your Decidim module
---

# Integrate your module
Three steps to ship a settings tab: register the tab, declare form attributes, optionally customize the view.

## 1. Add a tab

Register a form and command in your engine after `decidim_toggle.organization_settings_tabs`.

→ [Add a settings tab](./quickstart.md)

## 2. Define attributes and validation

Declare fields on your `Decidim::Form` — booleans, collections, translatable fields.

→ [Attributes](./attributes.md) · [Informative callouts](./informative_callout.md) (optional)

## 3. Customize the form view (optional)

Default rendering uses `all_fields`. Override with `form_layout_partial:` when you need custom markup.

→ [Customize views](./customize-views.md)

## Optional: JavaScript exposure

Expose selected settings to `window.DecidimToggle` on the participant and admin frontends.

→ [JavaScript](./javascript.md)

## See also

- [Overview](../index.md)
- [Contribute](../developer/contribute.md) — hacking the gem itself
- [GitLab issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/issues)
