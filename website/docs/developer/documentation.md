---
sidebar_position: 2
title: Documentation site
description: Edit and build this Docusaurus site
---

# Documentation site

**Who reads this:** contributors editing docs in `website/docs/`.

## Rules

Follow the [structure map](../README.md): reading order, page shape, illustration policy.

- Flat folders under each category when possible.
- Overview → context → detail → **See also** on every page.
- Module integrator path starts at [Integrate](../integrate/index.md), not Developer.

## Edit docs

Add or change files under `website/docs/`.

## Local preview

```bash
cd website
yarn
yarn start
```

## Build (required before merge)

```bash
cd website && yarn build
```

`onBrokenLinks: 'throw'` — fix broken links before merging.

## CI

GitLab runs `node::docs` (`yarn build` in `website/`) on merge requests and `main`.

## See also

- [Documentation structure](../README.md)
- [Contribute](./contribute.md)
