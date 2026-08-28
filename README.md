# crabbox-cli

Builds of the [Crabbox](https://github.com/openclaw/crabbox) CLI from
[`gperezmz/crabbox@gcp-desktop`](https://github.com/gperezmz/crabbox/tree/gcp-desktop), which adds the GCP
capabilities our coordinator needs: desktop, browser and code leases, TTL-bounded instances, machine-family
boot disks, and snapshot defaults.

This repository holds no source. It checks out a Crabbox tree, cross-compiles `cmd/crabbox`, and publishes the
archives, so the fork stays a clean set of changes against upstream.

## Install

```sh
brew install gperezmz/tap/crabbox        # macOS and Linux
nix run github:gperezmz/crabbox-cli      # or add the flake as an input
```

Or take an archive directly:

```sh
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m); [ "$arch" = x86_64 ] && arch=amd64; [ "$arch" = aarch64 ] && arch=arm64
gh release download --repo ddc-neoris/crabbox-cli --pattern "crabbox_*_${os}_${arch}.tar.gz" --dir /tmp
tar -xzf /tmp/crabbox_*_"${os}"_"${arch}".tar.gz -C /tmp
mkdir -p ~/.local/bin && install -m 0755 /tmp/crabbox ~/.local/bin/crabbox
```

Windows archives are `.zip` with `crabbox.exe`.

## Release

**Release CLI** runs daily and on demand. It builds whatever `gperezmz/crabbox@gcp-desktop` points at, skips
the run when that commit is already published, and derives the version from Crabbox's own version plus a UTC
stamp unless you pass one. The six targets build in parallel, one job each, and a final job collects the
archives, writes `checksums.txt` and publishes. Release notes record the exact source commit.

**Upstream sync** runs daily. When the fork trails `openclaw/crabbox@main` it rebases onto upstream, builds,
runs the GCP CLI tests, the mint contract test and the worker suite, force-pushes the rebased branch, and
triggers a release. It opens an issue here instead when the rebase conflicts, the tests fail, or no
`PUBLISH_TOKEN` secret is set — so a human is only involved when the automation cannot proceed.

The chain is therefore unattended: upstream moves → the fork is rebased and pushed → a release is built and
published → `release.json` and the Homebrew formula are updated. Only the Crabbox **coordinator** deploy stays
manual, because it runs from a local checkout and its version is not readable without admin credentials.

One secret drives it: `PUBLISH_TOKEN`, a fine-grained token covering `gperezmz/crabbox` and
`gperezmz/homebrew-tap` with **Contents: write**, plus **Workflows: write** — the latter because upstream
commits routinely touch `.github/workflows/`, and GitHub rejects a token push carrying workflow changes
without it. Without the secret the sync still rebases and tests, then reports. Archives are `crabbox_<version>_<os>_<arch>.tar.gz` (`.zip` on Windows) plus
`checksums.txt`, each containing the binary and Crabbox's MIT `LICENSE`.

Build locally with the same script:

```sh
CRABBOX_SRC=../crabbox-fork scripts/build-cli.sh 0.0.0-dev
scripts/update-channels.sh 0.0.0-dev dist ../homebrew-tap   # refresh the flake pin and formula
```

## Disclaimer

Unofficial builds. Not affiliated with, endorsed by, or supported by the Crabbox project. Crabbox is
MIT-licensed, copyright openclaw; each archive ships that licence, and issues with these builds belong here,
not upstream.
