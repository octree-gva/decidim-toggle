---
sidebar_position: 2
slug: /contributing
title: Contribute
description: Who maintains decidim-toggle and where to send issues and merge requests
---

# Contribute

**decidim-toggle** is maintained by [Voca](https://voca.city), a project from [Octree](https://octree.ch).

Issues and merge requests are welcome on GitLab:

- [Repository](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle)
- [Issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/issues)
- [Merge requests](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle/-/merge_requests)

Read the [Code of conduct](/code-of-conduct) before participating.

Module developers adding a tab to their own gem: [Integrate](../integrate/index.md).

## Before you push

```bash
docker compose up -d
docker compose exec toggle bash -lc 'cd /home/module && bundle install -j$(nproc) && ./bin/check'
cd website && yarn build
```

| Check | Command |
|-------|---------|
| All | `./bin/check` (RuboCop, erblint, RSpec) |
| RSpec | `unset DATABASE_URL && RAILS_ENV=test bundle exec rspec` |
| Docs | `cd website && yarn build` |

## Deep dives

| Topic | Page |
|-------|------|
| Registry and `add_tab` internals | [Tab registry](./tab-registry.md) |
| Gem-owned views and layouts | [View customization](./view-customization.md) |
| Invalid form replay and redirects | [Error handling](./error-handling.md) |
| Deface overrides (`window.DecidimToggle`) | [Deface usage](./deface-usage.md) |
| Editing this documentation site | [Documentation website](./documentation.md) |

## See also

- [Code of conduct](/code-of-conduct)
- [Integrate](../integrate/index.md)
- [Overview](../index.md)
