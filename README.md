## `hugov`

A quick and dirty GoHugo version selector for bash

> [!CAUTION]
> Use at your own peril. This is a quick and dirty script that might not work for you. It's a bash script that is supposed to be run on a Linux system. It's not tested on MacOS or Windows. It's not tested on all Linux distributions. It's not tested with all versions of GoHugo. It's not tested with all versions of bash. It's not tested with all versions of Linux. And it uses `sudo`. So, you know, be careful.

### Installation

Either do a soft link:

```bash
sudo ln -s /home/patrick/github.com/davidsneighbour/hugov/hugov /usr/local/bin/
```

Then run it:

```bash
hugov
```

Or run it from within this repository:

```bash
./hugov
```

### Configuration

| Variable             | Default    | Description                                                                          |
| -------------------- | ---------- | ------------------------------------------------------------------------------------ |
| `HUGOV_STOP_VERSION` | `v0.140.0` | Oldest version to download. Downloads stop once this version is reached and fetched. |

```bash
# Download back to v0.120.0 instead of the default floor
HUGOV_STOP_VERSION=v0.120.0 ./hugov --download
```

## Development

The script is linted with [ShellCheck](https://www.shellcheck.net/). Run it
locally before pushing:

```bash
npm run lint
# or directly:
shellcheck hugov
```

The same check runs in CI on every push to `main` and on pull requests.

## Read on

* [Blog post presenting `hugov`](https://kollitsch.dev/blog/2024/hugov-managing-multiple-gohugo-versions/)
