import ospaths, parseutils, pegs

mode = ScriptMode.Silent

const
  name = "wpm"

proc strip*(s: string): string =
  var
    first = 0
    last = len(s)-1
    chars = {' ', '\t', '\v', '\r', '\l', '\f'}

  while s[first] in chars: inc(first)
  while last >= 0 and s[last] in chars: dec(last)
  result = substr(s, first, last)

task debug, "debug build":
  # get build, inc and write
  if existsFile(".version"):
    var build: int
    discard parseInt(gorge("cat .version"), build)
    build += 1
    writeFile(".version", $build)

  # delete debug dir
  rmDir("debug")
  # compile
  exec(r"nim c --cincludes:zlib\include -l:libs\zlib1.dll --cpu:i386 -t:-m32 -l:-m32 -t:-DWIN32 src\wpm.nim")
  # make debug dir
  mkDir("debug")
  # copy files
  cpFile(r"src\wpm.exe", r"debug\wpm.exe")
  cpFile(r"libs\zlib1.dll", r"debug\zlib1.dll")
  setCommand "nop"


task release, "release build":
  # reset build
  writeFile(".version", "0")
  # delete release dir
  rmDir("release")
  # compile
  exec(r"nim c -d:release --cincludes:zlib\include -l:libs\zlib1.dll --cpu:i386 -t:-m32 -l:-m32 -t:-DWIN32 src\wpm.nim")
  # make release dir
  mkDir("release")
  # copy files
  cpFile(r"src\wpm.exe", r"release\wpm.exe")
  cpFile(r"libs\zlib1.dll", r"release\zlib1.dll")
  # pack with upx
  exec("upx -q release\\wpm.exe")
  # create release zip
  var version = gorge(r"egrep -o -m 1 ""([0-9]{1,}\.)+[0-9]{1,}"" src\wpm.nim").strip
  var zipname = name & version.strip & ".zip"
  exec("zip -jq " & zipname & " release\\*")
  setCommand "nop"
