#!/usr/bin/env bash
set -euo pipefail

SRC="${CRABBOX_SRC:?path to a crabbox checkout}"
version="${1:-${CRABBOX_VERSION:-}}"
out_dir="${CRABBOX_DIST:-$PWD/dist}"
targets="${CRABBOX_TARGETS:-darwin/amd64 darwin/arm64 linux/amd64 linux/arm64 windows/amd64 windows/arm64}"

if [[ -z "$version" ]]; then
  printf 'usage: CRABBOX_SRC=<checkout> scripts/build-cli.sh <version>\n' >&2
  exit 2
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for target in $targets; do
  goos="${target%%/*}"
  goarch="${target##*/}"
  stage="$(mktemp -d)"
  binary=crabbox
  [[ "$goos" == "windows" ]] && binary=crabbox.exe
  (cd "$SRC" && CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" go build -trimpath \
    -ldflags "-s -w -X github.com/openclaw/crabbox/internal/cli.version=$version" \
    -o "$stage/$binary" ./cmd/crabbox)
  cp "$SRC/LICENSE" "$stage/LICENSE"
  if [[ "$goos" == "windows" ]]; then
    (cd "$stage" && zip -q "$out_dir/crabbox_${version}_${goos}_${goarch}.zip" "$binary" LICENSE)
  else
    tar -czf "$out_dir/crabbox_${version}_${goos}_${goarch}.tar.gz" -C "$stage" "$binary" LICENSE
  fi
  rm -rf "$stage"
done

(cd "$out_dir" && shasum -a 256 ./crabbox_* >checksums.txt)
printf 'built %s into %s\n' "$version" "$out_dir"
