---
name: publish
description: Publish approved dn-action repository changes with Sapling and move the public GitHub Action v1 tag to the new main commit. Use when the user asks to publish, release, deploy, or update chesapeakedev/dn-action at v1.
---

# Publish dn-action

Publish only when the user explicitly requests the external release. Use
Sapling for repository work and Git only for the moving `v1` tag.

## 1. Inspect and validate

Read `CONTRIBUTING.md`, then inspect the complete pending change:

```bash
sl status
sl diff
```

Stop if the working copy contains unrelated or unexplained changes. Run tests
appropriate to every changed file. At minimum, run `bash -n entrypoint.sh` when
the entrypoint changed.

## 2. Commit and push main

Record only the intended paths and create a non-interactive commit:

```bash
sl addremove <paths>
sl commit -m "<descriptive message>" <paths>
sl status
sl log -r . -T "{node} {desc|firstline}\n"
```

Require a clean working copy before publishing. Push the current commit to the
existing GitHub `main` branch without force:

```bash
sl push --to main
```

Stop on any push or required-check failure.

## 3. Move v1

Fetch the pushed branch and prove its commit ID matches the full node ID from
the preceding Sapling log before moving the public tag:

```bash
git fetch origin refs/heads/main:refs/remotes/origin/main
git rev-parse origin/main
git tag --force v1 origin/main
git push origin refs/tags/v1 --force
```

Keep the force push scoped to `refs/tags/v1`. Never force-push `main`.

## 4. Verify

Verify the remote references:

```bash
git ls-remote origin refs/heads/main refs/tags/v1
```

Require both lines to report the same commit ID. Report the published commit
ID, validation performed, and verification result. Do not claim success unless
both remote references match.
