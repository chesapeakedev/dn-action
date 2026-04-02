# chesapeake/dn-action

A GitHub Action that installs the [`dn`](https://github.com/chesapeake/dn) CLI from
GitHub Releases.

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dn
        uses: chesapeake/dn-action@v1

      - name: Run dn kickstart
        run: dn --awp --opencode "${{ github.event.issue.html_url }}"
```

### With version pinning

Pin to a specific release to avoid unexpected updates:

```yaml
      - uses: chesapeake/dn-action@v1
        with:
          version: "1.2.3"
```

Or use a semver range:

```yaml
      - uses: chesapeake/dn-action@v1
        with:
          version: ">=1.2.0"
```

### Custom install directory

```yaml
      - uses: chesapeake/dn-action@v1
        with:
          version: "latest"
          install-dir: "$HOME/bin"
```

## Inputs

| Input         | Default       | Description                                     |
| ------------- | ------------- | ----------------------------------------------- |
| `version`     | `"latest"`    | Release tag or semver range to install          |
| `install-dir` | `"~/.local/bin"` | Directory to install the binary into        |
| `github-token`| `""`          | GitHub token for API requests (higher rate limit) |

## Outputs

| Output     | Description                        |
| ---------- | ---------------------------------- |
| `dn-version` | Version tag of the installed dn |
| `dn-path`    | Absolute path to the dn binary   |

## Platforms

| OS      | Arch   | Binary name         |
| ------- | ------ | ------------------- |
| Linux   | x64    | `dn-linux-x64`      |
| Linux   | ARM64  | `dn-linux-arm64`    |
| macOS   | x64    | `dn-macos-x64`       |
| macOS   | ARM64  | `dn-macos-arm64`     |
| Windows | x64    | `dn-windows-x64.exe` |

The action auto-detects `runner.os` and `runner.arch` to select the correct binary.

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
