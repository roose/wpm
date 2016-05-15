# wpm — a CLI for managing Wox plugins

`wpm` is an CLI for managing and assisting in the development of plugins for Wox.

I'm writing this for fun and learning Nim

## Building

`nim c -d:release --cincludes:zlib\include -l:zlib1.dll --cpu:i386 -t:-m32 -l:-m32 -t:-DWIN32 wpm.nim`

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
  pack            pack developing plugin files to one .wox file

Options:
  -h,--help       show this help
  -v, --version   print version

```

## Todo

- [ ] `wpm install` - install plugin(s)
- [x] `wpm pack` - pack developing plugin files to one .wox file
 
