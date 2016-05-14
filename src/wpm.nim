import os, osproc, strutils, json, marshal, pegs, terminal, httpclient, times
import nuuid

type
  PluginJson = object
    ID: string
    ActionKeywords: seq[string]
    Name: string
    Description: string
    Author: string
    Version: string
    Language: string
    Website: string
    IcoPath: string
    ExecuteFileName: string

const
    MAX_AGE = 7*24*60*60

let
  version = "0.1.0"
  help = """
Wox Plugin Manager $1

Usage: wpm <command>

where <command> is one of:
  init            interactively create a plugin.json file
  list, ls        list installed plugins
  search          search for a specified plugin
  refresh         refresh plugins list

Options:
  -h,--help       show this help
  -v, --version   print version

Project repo:
  https://github.com/roose/wpm-cli
""".format(version)
  args = commandLineParams()

proc input(question: string): string =
  stdout.write(question)
  let answer = stdin.readLine()
  return answer

proc echoPlugin*(plugin: JsonNode) =
  echo plugin["name"].str & ":"
  echo "  version:     " & plugin["version"].str
  echo "  description: " & plugin["description"].str
  echo "  author:      " & plugin["created_by"]["username"].str
  let website = (if plugin["website"] == newJNull(): plugin["github"].str else: plugin["website"].str)
  echo "  website:     " & website & "\n"

proc getAge(filepath: string): int64 =
  if fileExists(filepath):
    return getTime() - getLastModificationTime(filepath)
  else:
    return 0

proc init() =
  var homeDir = getHomeDir()
  let id = nuuid.generateUUID().split("-").join.toUpper
  let baseName = splitPath(getCurrentDir()).tail
  var defaultAuthor = homeDir[0..^2].splitPath.tail.toLower.split.join
  if findExe("git") != "":
    let (name, exitCode) = execCmdEx("git config --global user.name")
    if exitCode == QuitSuccess and name.len > 0:
      defaultAuthor = name.strip()

  var result = PluginJson(
    ID: id,
    ActionKeywords: @[baseName],
    Name: baseName,
    Description: "desc",
    Author: defaultAuthor,
    Version: "0.1.0",
    Language: "",
    Website: "",
    IcoPath: "",
    ExecuteFileName: ""
  )

  let name = input("name: ($1) " % baseName)
  if name.len != 0:
    result.Name = name

  let version = input("version: (0.1.0) ")
  if version.len != 0:
      result.Version = version

  let description = input("description: ")
  if description.len != 0:
      result.Description = description

  let language = input("language: ")
  if language.len != 0:
      result.Language = language

  let execute_file_name = input("execute file name: ")
  if execute_file_name.len != 0:
      result.ExecuteFileName = execute_file_name

  let web_site = input("web site: ")
  if web_site.len != 0:
      result.Website = web_site

  let keywords = input("keyword(s): ($1) " % basename)
  if keywords.len != 0:
      result.ActionKeywords = keywords.split(peg"(\s / [,])+")

  let author = input("author: ($1) " % defaultAuthor)
  if author.len != 0:
      result.Author = author

  result.IcoPath = "Images\\$1.png" % (if name.len != 0: name else: baseName)

  let pluginFileName = joinPath(getCurrentDir(), "plugin.json")

  echo "\n" & "About to write to $1: " % pluginFileName & "\n"
  let pluginJson = pretty(parseJson($$result), 4)
  echo pluginJson & "\n"

  let yes = input("Is this ok? (yes) ")
  if yes == "" or yes.toLower in ["y", "yes", "ok"]:
      writeFile(pluginFileName, pluginJson)
  else:
      echo "Aborted."

  # let pluginJson = pretty(parseJson($$result))
  # echo pluginJson
  # writeFile("test.json", pluginJson)

proc list() =
  let path = joinPath(getEnv("appdata"), "Wox\\Plugins")
  if existsDir(path):
    for kind, path in walkDir(path):
      let plugin = joinPath(path, "plugin.json")
      if existsFile(plugin):
        let pluginFile = parseFile(plugin)
        echo pluginFile["Name"].str & " " & pluginFile["Version"].str
      else:
        styledEcho fgRed, "Incorrect plugin in folder '$1'" % path.splitPath.tail
        # styledEcho("\033[1;31mbold red text\033[0m\n")
  else:
    echo "You use old Wox version, please update it"

proc refresh() =
  let url = "http://api.getwox.com/plugin/?page_size=1000"
  let path = joinPath(getTempDir(), "wox.plugins.json")
  echo "Downloading plugins list..."
  downloadFile(url, path)
  echo "Done."

proc search(search: string) =
  let path = joinPath(getTempDir(), "wox.plugins.json")
  let age = getAge(path)
  if age > MAX_AGE or age == 0:
    echo "Need refresh plugins list"
    refresh()

  let plugins = parseFile(path)
  let searchList = search.split(peg"(\s / [,])+")
  var found = false

  template onFound: stmt =
    echoPlugin(plugin)
    found = true
    break

  for plugin in plugins["results"]:
    for word in searchList:
      if word.toLower in plugin["name"].str.toLower:
        onFound()
      if word.toLower in plugin["description"].str.toLower:
        onFound()

  if not found:
    echo "No plugins found."

when isMainModule:
  if args.len != 0:
    case args[0]:
      of "init":
        try:
          init()
        except IOError:
          echo "Aborted."
      of "ls", "list":
        list()
      of "search":
        if args.len < 2:
          echo help
        else:
          search(args[1])
      of "refresh":
        refresh()
      of "-h", "--help":
        echo help
      of "-v", "--version":
        echo version
      else:
        echo help
  else:
    echo help
