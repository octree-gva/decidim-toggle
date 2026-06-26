---
sidebar_position: 6
title: Deface usage
description: JavaScript config injection overrides
---

# Deface usage

Deface injects `window.DecidimToggle` into participant and admin layouts without forking decidim-core. Overrides live in `app/overrides/` and are **ignored by Zeitwerk** — Deface loads them at boot.

## Public site

| File | Virtual path | Inserts |
|------|--------------|---------|
| `add_toggle_javascript_public.rb` | `layouts/decidim/_decidim_javascript` | `layouts/decidim/toggle/javascript_config` after `js_configuration` |

## Admin

| File | Virtual path | Inserts |
|------|--------------|---------|
| `add_toggle_javascript_admin.rb` | `layouts/decidim/admin/_header` | same partial after admin stylesheet pack tag |

## Partial

`app/views/layouts/decidim/toggle/_javascript_config.html.erb` — sets `window.DecidimToggle` from `Decidim::Toggle.javascript_config_for(current_organization)`.

Forms opt in with `Decidim::Toggle::ExposeAttributesToJs` and `expose_to_javascript` — see [JavaScript](../integrate/javascript.md).

## Drift check

When upgrading decidim-core, diff upstream layout templates against the `original:` strings in override files. System specs in `spec/system/decidim_toggle/javascript_config_spec.rb` assert injection end-to-end.

## See also

- [JavaScript](../integrate/javascript.md)
- [Contribute](./contribute.md)
- [Documentation website](./documentation.md)
