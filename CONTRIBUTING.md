# Contributing

This repository publishes a composite GitHub Action. Changes are not available
to workflows that use `chesapeakedev/dn-action@v1` until the `v1` Git tag is
moved to the new commit.

## Prerequisites

- [Sapling](https://sapling-scm.com/) (`sl`) for normal version-control work
- Git, used only to update and verify the public action tag
- Push access to `chesapeakedev/dn-action`

## Make and test a change

Start from the latest `main` commit:

```bash
sl pull
sl goto origin/main
```

After editing the action, review and test the change. At minimum, validate the
shell entrypoint when it was modified:

```bash
bash -n entrypoint.sh
sl diff
sl status
```

Record new and deleted files, then commit the change:

```bash
sl addremove
sl commit -m "Describe the change"
sl log -r . -T "{node|short} {desc|firstline}\n"
```

Push the current commit to the GitHub `main` branch:

```bash
sl push --to main
```

Do not update `v1` until the push succeeds and the commit is ready for public
use.

## Publish the change to `v1`

The `v1` tag is a moving major-version tag. Updating it immediately changes the
action code used by every workflow that references
`chesapeakedev/dn-action@v1`.

Fetch the branch you just pushed, move the local tag to that exact remote
commit, and force-update only the tag:

```bash
git fetch origin refs/heads/main:refs/remotes/origin/main
git tag --force v1 origin/main
git push origin refs/tags/v1 --force
```

The force push is required because `v1` already exists. Keep it scoped to
`refs/tags/v1`; do not force-push `main`.

Verify the remote branch and tag after publishing:

```bash
git ls-remote origin refs/heads/main refs/tags/v1
```

For the lightweight `v1` tag used here, both lines should report the same
commit ID. If they do not, stop and correct the tag before announcing the
release.
