import json

type
  Plugin* = object
    ID*: string
    ActionKeywords*: seq[string]
    Name*: string
    Description*: string
    Author*: string
    Version*: string
    Language*: string
    Website*: string
    IcoPath*: string
    ExecuteFileName*: string

proc getField(obj: JsonNode, name: string, default = ""): string =
  ## Queries ``obj`` for the optional ``name`` string.
  ##
  ## Returns the value of ``name`` if it is a valid string, or aborts execution
  ## if the field exists but is not of string type. If ``name`` is not present,
  ## returns empty ``default``.
  if hasKey(obj, name):
    if obj[name].kind == JString:
      return obj[name].str
    else:
      raise newException(Exception, "Corrupted packages.json file. " & name &
          " field is of unexpected type.")
  else: return default

proc getPluginInfo*(filename: string): Plugin =
  ## Construct a Plugin object from file
  let plugin = parseFile(filename)

  result.ID = plugin.getField("ID")
  result.ActionKeywords = @[]
  if plugin.getField("ActionKeyword") != "":
    result.ActionKeywords = @[plugin["ActionKeyword"].str]
  else:
    for keyword in plugin["ActionKeywords"]:
      result.ActionKeywords.add(keyword.str)
  result.Name = plugin.getField("Name")
  result.Description = plugin.getField("Description")
  result.Author = plugin.getField("Author")
  result.Version = plugin.getField("Version")
  result.Language = plugin.getField("Language")
  result.Website = plugin.getField("Website")
  result.IcoPath = plugin.getField("IcoPath")
  result.ExecuteFileName = plugin.getField("ExecuteFileName")