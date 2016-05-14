# wpm — a CLI for managing Wox plugins

`wpm` is an CLI for managing and assisting in the development of plugins for Wox.

I'm writing this for fun and learning Nim

## Building

x32 — `nim c -d:release --cpu:i386 --os:windows --passC:-m32 --passL:-m32 wpm.nim`

x64 — `nim c -d:release wpm.nim`

## Installing

Place or add wpm.exe to the `PATH`

## Usage

```
Usage: wpm <command>

where <command> is one of:
  init            interactively create a plugin.json file
  list, ls        list installed plugins
  search          search for a specified plugin
  refresh         refresh plugins list

Options:
  -h,--help       show this help
  -v, --version   print version

```

## Todo

- [ ] `wpm install` - install plugin(s)
- [ ] `wpm pack` - pack developing plugin files to one .wox file
 
