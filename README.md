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

Run the **Release CLI** workflow with a version, and the source repository and ref to build. Release notes
record the exact source commit. Archives are `crabbox_<version>_<os>_<arch>.tar.gz` (`.zip` on Windows) plus
`checksums.txt`, each containing the binary and Crabbox's MIT `LICENSE`.

Build locally with the same script:

```sh
CRABBOX_SRC=../crabbox-fork scripts/build-cli.sh 0.0.0-dev
```

## Disclaimer

Unofficial builds. Not affiliated with, endorsed by, or supported by the Crabbox project. Crabbox is
MIT-licensed, copyright openclaw; each archive ships that licence, and issues with these builds belong here,
not upstream.
