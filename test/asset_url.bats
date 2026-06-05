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
