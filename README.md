## `hugov`

A quick and dirty GoHugo version selector for bash

> [!CAUTION]
> Use at your own peril. This is a quick and dirty script that might not work for you. It's a bash script that is supposed to be run on a Linux system. It's not tested on MacOS or Windows. It's not tested on all Linux distributions. It's not tested with all versions of GoHugo. It's not tested with all versions of bash. It's not tested with all versions of Linux. And it uses `sudo`. So, you know, be careful.

### Installation

Clone the repository, then either symlink the script into your `PATH` (run this
from inside the clone so `$(pwd)` resolves to the repository root):

```bash
sudo ln -s "$(pwd)/hugov" /usr/local/bin/hugov
```

Then run it:

```bash
hugov
```

Or run it from within this repository:

```bash
./hugov
```

### Commands

```text
--download [version]  Download missing versions, or a single <version> if given.
--list                List already downloaded Hugo versions.
--link                Symlink a chosen version into BINDIR.
--update              Download the latest versions and link the newest.
--current             Show which version BINDIR/hugo currently points at.
--uninstall           Remove the BINDIR/hugo symlink.
--prune               Delete old downloaded versions (keeps the newest --keep, default 5).
--version             Display the script version.
--help                Display this help message.
```

Options: `--bindir <dir>`, `--extended` (default) / `--standard` / `--both`,
`--keep <n>`, `--log-dir <dir>`, `--no-verify`.

`hugov` downloads only the **extended** build by default (use `--standard` or
`--both` to change that), verifies each download against Hugo's published
SHA256 checksums, and detects your OS/architecture (`uname`) to pick the right
release asset.

### Configuration

| Variable             | Default    | Description                                                                          |
| -------------------- | ---------- | ------------------------------------------------------------------------------------ |
| `HUGOV_STOP_VERSION` | `v0.140.0` | Oldest version to download. Downloads stop once this version is reached and fetched. |
| `GITHUB_TOKEN`       | _(unset)_  | GitHub token; raises the API rate limit from 60 to 5000 requests/hour.               |
| `GH_TOKEN`           | _(unset)_  | Alternative token variable, used when `GITHUB_TOKEN` is unset.                       |

```bash
# Download back to v0.120.0 instead of the default floor
HUGOV_STOP_VERSION=v0.120.0 ./hugov --download

# Download a single version (extended build, checksum-verified)
./hugov --download v0.150.0

# Keep only the five newest versions on disk
./hugov --prune --keep 5
```

## Development

The script is linted with [ShellCheck](https://www.shellcheck.net/). Run it
locally before pushing:

```bash
npm run lint
# or directly:
shellcheck hugov
```

Tests use [bats](https://github.com/bats-core/bats-core) (installed as a dev
dependency):

```bash
npm test
# or directly:
./node_modules/.bin/bats test
```

Both checks run in CI on every push to `main` and on pull requests.

## Read on

* [Blog post presenting `hugov`](https://kollitsch.dev/blog/2024/hugov-managing-multiple-gohugo-versions/)
