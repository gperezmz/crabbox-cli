# crabbox-cli

Builds of the [Crabbox](https://github.com/openclaw/crabbox) CLI from
[`gperezmz/crabbox@gcp-desktop`](https://github.com/gperezmz/crabbox/tree/gcp-desktop), which adds the GCP
capabilities our coordinator needs: desktop, browser and code leases, TTL-bounded instances, machine-family
boot disks, and snapshot defaults.

This repository holds no source. It checks out a Crabbox tree, cross-compiles `cmd/crabbox`, and publishes the
archives, so the fork stays a clean set of changes against upstream.

## Install

```sh
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m); [ "$arch" = x86_64 ] && arch=amd64; [ "$arch" = aarch64 ] && arch=arm64
gh release download --repo ddc-neoris/crabbox-cli --pattern "crabbox_*_${os}_${arch}.tar.gz" --dir /tmp
tar -xzf /tmp/crabbox_*_"${os}"_"${arch}".tar.gz -C /tmp
mkdir -p ~/.local/bin && install -m 0755 /tmp/crabbox ~/.local/bin/crabbox
```

Windows archives are `.zip` with `crabbox.exe`.

## Release

**Release CLI** runs weekly and on demand. It builds whatever `gperezmz/crabbox@gcp-desktop` points at, skips
the run when that commit is already published, and derives the version from Crabbox's own version plus a UTC
stamp unless you pass one. The six targets build in parallel, one job each, and a final job collects the
archives, writes `checksums.txt` and publishes. Release notes record the exact source commit.

**Upstream sync** runs weekly too. When the fork trails `openclaw/crabbox@main` it rebases onto upstream,
builds, runs the GCP CLI tests, the mint contract test and the worker suite, and opens a pull request on the
fork's `upstream-sync` branch. It falls back to an issue here when the rebase conflicts, the tests fail, or no
`FORK_TOKEN` secret is set.

Merging that pull request is deliberate rather than automatic: it moves the branch both the coordinator and the
CLI are built from, so `make apply` has to run from the rebased tree before new builds ship.

Set `FORK_TOKEN` for the pull-request path; without it the workflow still rebases, tests and reports. It is a
fine-grained token on `gperezmz/crabbox` with **Contents: read and write**, **Pull requests: read and write**
and **Workflows: read and write** — the last one because upstream commits routinely touch
`.github/workflows/`, and GitHub rejects a token push carrying workflow changes without it. Archives are `crabbox_<version>_<os>_<arch>.tar.gz` (`.zip` on Windows) plus
`checksums.txt`, each containing the binary and Crabbox's MIT `LICENSE`.

Build locally with the same script:

```sh
CRABBOX_SRC=../crabbox-fork scripts/build-cli.sh 0.0.0-dev
```

## Disclaimer

Unofficial builds. Not affiliated with, endorsed by, or supported by the Crabbox project. Crabbox is
MIT-licensed, copyright openclaw; each archive ships that licence, and issues with these builds belong here,
not upstream.
