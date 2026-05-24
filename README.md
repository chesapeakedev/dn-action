# chesapeakedev/dn-action

A GitHub Action that installs the [`dn`](https://github.com/chesapeakedev/dn) CLI from
GitHub Releases.

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dn
        uses: chesapeakedev/dn-action@v1

      - name: Run dn kickstart
        run: dn --awp --opencode "${{ github.event.issue.html_url }}"
```

### With version pinning

Pin to a specific release to avoid unexpected updates:

```yaml
      - uses: chesapeakedev/dn-action@v1
        with:
          version: "1.2.3"
```

Or use a semver range:

```yaml
      - uses: chesapeakedev/dn-action@v1
        with:
          version: ">=1.2.0"
```

### Custom install directory

```yaml
      - uses: chesapeakedev/dn-action@v1
        with:
          version: "latest"
          install-dir: "$HOME/bin"
```

## Inputs

| Input         | Default       | Description                                     |
| ------------- | ------------- | ----------------------------------------------- |
| `version`     | `"latest"`    | Release tag or semver range to install          |
| `install-dir` | `"~/.local/bin"` | Directory to install the binary into        |
| `github-token`| workflow token | Optional override; defaults to `github.token` (see below) |

## Authentication

You do **not** need to set `github-token` or add an earlier step for a **public**
[`chesapeakedev/dn`](https://github.com/chesapeakedev/dn) release. The action uses the
workflow’s built-in `GITHUB_TOKEN` automatically.

The `github-token` input is optional. Use it only when you need a different credential
(for example a PAT that can read a **private** `dn` repo in another org).

For private release repos, ensure the job can read repository contents:

```yaml
permissions:
  contents: read
```

If the default `GITHUB_TOKEN` cannot access the release repo (common across orgs),
pass a PAT:

```yaml
      - uses: chesapeakedev/dn-action@v1
        with:
          github-token: ${{ secrets.DN_RELEASES_TOKEN }}
```

## Outputs

| Output     | Description                        |
| ---------- | ---------------------------------- |
| `dn-version` | Version tag of the installed dn |
| `dn-path`    | Absolute path to the installed `dn` binary (`dn` or `dn.exe`) |

## Platforms

The action auto-detects `runner.os` and `runner.arch`, downloads the matching
release asset, and installs it as `dn` (or `dn.exe` on Windows) in the install
directory:

| OS      | Arch   | Release asset        | Installed as |
| ------- | ------ | -------------------- | ------------ |
| Linux   | x64    | `dn-linux-x64`       | `dn`         |
| Linux   | ARM64  | `dn-linux-arm64`     | `dn`         |
| macOS   | x64    | `dn-macos-x64`       | `dn`         |
| macOS   | ARM64  | `dn-macos-arm64`     | `dn`         |
| Windows | x64    | `dn-windows-x64.exe` | `dn.exe`     |

Subsequent workflow steps can run `dn` directly once the install directory is on
`PATH` (the action appends it via `GITHUB_PATH`).

## Unsupported platforms

For platforms not listed above, install from source with `deno compile`:

```yaml
      - uses: denoland/setup-deno@v1
        with:
          deno-version: ">=2.6.3"

      - name: Install dn from source
        run: |
          deno compile --allow-all -o dn https://esm.sh/chesapeake/dn/cli/main.ts
          echo "$PWD" >> $GITHUB_PATH
```
