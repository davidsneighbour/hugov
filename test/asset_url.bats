#!/usr/bin/env bats

# Unit tests for the pure helper functions. The script is sourced (not run),
# which is possible because main() only executes when the file is invoked
# directly.

setup() {
  source "$BATS_TEST_DIRNAME/../hugov"
}

@test "version_ge: equal versions compare as >=" {
  run version_ge v0.140.0 v0.140.0
  [ "$status" -eq 0 ]
}

@test "version_ge: greater is >=" {
  run version_ge v0.141.0 v0.140.0
  [ "$status" -eq 0 ]
}

@test "version_ge: lesser is not >=" {
  run version_ge v0.139.0 v0.140.0
  [ "$status" -eq 1 ]
}

@test "version_ge: numeric (not lexical) ordering" {
  # 0.100.0 must be newer than 0.99.0 despite the shorter string.
  run version_ge v0.100.0 v0.99.0
  [ "$status" -eq 0 ]
}

@test "build_asset_url: modern linux/amd64 extended" {
  OS=linux ARCH=amd64
  run build_asset_url v0.140.0 extended
  [ "$output" = "https://github.com/gohugoio/hugo/releases/download/v0.140.0/hugo_extended_0.140.0_linux-amd64.tar.gz" ]
}

@test "build_asset_url: modern linux/amd64 standard" {
  OS=linux ARCH=amd64
  run build_asset_url v0.140.0 standard
  [ "$output" = "https://github.com/gohugoio/hugo/releases/download/v0.140.0/hugo_0.140.0_linux-amd64.tar.gz" ]
}

@test "build_asset_url: old linux/amd64 uses Linux-64bit naming" {
  OS=linux ARCH=amd64
  run build_asset_url v0.100.0 standard
  [ "$output" = "https://github.com/gohugoio/hugo/releases/download/v0.100.0/hugo_0.100.0_Linux-64bit.tar.gz" ]
}

@test "build_asset_url: cutover boundary v0.102.3 is modern naming" {
  OS=linux ARCH=amd64
  run build_asset_url v0.102.3 standard
  [[ "$output" == *"_linux-amd64.tar.gz" ]]
}

@test "build_asset_url: just below cutover is legacy naming" {
  OS=linux ARCH=amd64
  run build_asset_url v0.102.2 standard
  [[ "$output" == *"_Linux-64bit.tar.gz" ]]
}

@test "build_asset_url: linux/arm64 uses modern naming for all versions" {
  OS=linux ARCH=arm64
  run build_asset_url v0.100.0 extended
  [ "$output" = "https://github.com/gohugoio/hugo/releases/download/v0.100.0/hugo_extended_0.100.0_linux-arm64.tar.gz" ]
}

@test "build_asset_url: darwin maps to darwin-universal" {
  OS=darwin ARCH=arm64
  run build_asset_url v0.140.0 extended
  [ "$output" = "https://github.com/gohugoio/hugo/releases/download/v0.140.0/hugo_extended_0.140.0_darwin-universal.tar.gz" ]
}

@test "detect_platform: normalizes x86_64 to amd64 on Linux" {
  uname() { case "$1" in -s) echo Linux ;; -m) echo x86_64 ;; esac; }
  detect_platform
  [ "$OS" = "linux" ]
  [ "$ARCH" = "amd64" ]
}

@test "detect_platform: normalizes aarch64 to arm64" {
  uname() { case "$1" in -s) echo Linux ;; -m) echo aarch64 ;; esac; }
  detect_platform
  [ "$ARCH" = "arm64" ]
}

@test "has_extended_build: versions before v0.170.0 have an extended build" {
  run has_extended_build v0.169.0
  [ "$status" -eq 0 ]
}

@test "has_extended_build: v0.170.0 and later have no extended build" {
  run has_extended_build v0.170.0
  [ "$status" -eq 1 ]
  run has_extended_build v0.171.2
  [ "$status" -eq 1 ]
}

@test "has_extended_build: accepts versions without the v prefix" {
  run has_extended_build 0.170.0
  [ "$status" -eq 1 ]
}

@test "resolve_executable: extended request after cut-over uses standard and warns" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR" FLAVOR=extended FLAVOR_SET=true
  run resolve_executable v0.170.0
  [ "$status" -eq 0 ]
  [[ "$output" == *"Warning: Hugo v0.170.0 has no extended build"* ]]
  [[ "$output" == *"$BATS_TEST_TMPDIR/hugo-v0.170.0" ]]
}

@test "resolve_executable: standard request after cut-over does not warn" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR" FLAVOR=standard FLAVOR_SET=true
  run resolve_executable v0.170.0
  [ "$output" = "$BATS_TEST_TMPDIR/hugo-v0.170.0" ]
}

@test "resolve_executable: no prompt after cut-over when no flavor is set" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR" FLAVOR_SET=false
  run resolve_executable v0.170.0 </dev/null
  [ "$output" = "$BATS_TEST_TMPDIR/hugo-v0.170.0" ]
}

@test "resolve_executable: falls back to an older -extended file after cut-over" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR" FLAVOR=extended FLAVOR_SET=true
  touch "$BATS_TEST_TMPDIR/hugo-v0.170.0-extended"
  run resolve_executable v0.170.0
  [[ "$output" == *"$BATS_TEST_TMPDIR/hugo-v0.170.0-extended" ]]
}

@test "resolve_executable: extended request before cut-over keeps extended" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR" FLAVOR=extended FLAVOR_SET=true
  run resolve_executable v0.169.0
  [ "$output" = "$BATS_TEST_TMPDIR/hugo-v0.169.0-extended" ]
}

@test "download_single_version: --both after cut-over downloads only standard" {
  FLAVOR=both
  download_flavor() { echo "flavor=$2"; }
  run download_single_version v0.170.0
  [[ "$output" == *"Warning:"* ]]
  [[ "$output" == *"flavor=standard"* ]]
  [[ "$output" != *"flavor=extended"* ]]
}

@test "download_flavor: skips standard download when an older -extended file exists" {
  DOWNLOAD_DIR="$BATS_TEST_TMPDIR"
  touch "$BATS_TEST_TMPDIR/hugo-v0.170.0-extended"
  curl() { echo "curl must not run"; return 1; }
  run download_flavor v0.170.0 standard
  [ "$status" -eq 0 ]
  [[ "$output" == *"identical build already exists"* ]]
  [[ "$output" != *"curl must not run"* ]]
}
