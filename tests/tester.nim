import os, osproc, unittest

test "can list":
  check execCmdEx("../wpm list").exitCode == QuitSuccess