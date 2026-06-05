#!/usr/bin/env bats

# Integration tests that run the script as a subprocess. These exercise only
# argument parsing and validation paths that exit before any network access or
# filesystem mutation.

setup() {
  HUGOV="$BATS_TEST_DIRNAME/../hugov"
}

@test "no arguments prints usage" {
  run "$HUGOV"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--help prints usage and exits 0" {
  run "$HUGOV" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Actions (mutually exclusive):"* ]]
}

@test "--version reports the package.json version" {
  run "$HUGOV" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"Script version:"* ]]
}

@test "unknown option fails" {
  run "$HUGOV" --nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid option"* ]]
}

@test "two actions are mutually exclusive" {
  run "$HUGOV" --list --download
  [ "$status" -eq 1 ]
  [[ "$output" == *"cannot be combined"* ]]
}

@test "--prune rejects a non-numeric --keep" {
  run "$HUGOV" --prune --keep abc
  [ "$status" -eq 1 ]
  [[ "$output" == *"non-negative integer"* ]]
}

@test "--keep without a value fails" {
  run "$HUGOV" --keep
  [ "$status" -eq 1 ]
  [[ "$output" == *"--keep requires"* ]]
}

@test "--bindir without a value fails" {
  run "$HUGOV" --bindir
  [ "$status" -eq 1 ]
  [[ "$output" == *"--bindir requires"* ]]
}

@test "--log-dir without a value fails" {
  run "$HUGOV" --log-dir
  [ "$status" -eq 1 ]
  [[ "$output" == *"--log-dir requires"* ]]
}
