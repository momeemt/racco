import std/os
import std/times
import std/strformat
import std/strutils
import std/random
import std/json

import racco/builds
import racco/env
import racco/previews

include "scfs/article.settings.toml.nimf"
include "scfs/xly.settings.toml.nimf"

proc today (): string =
  result = now().format("yyyy-MM-dd")

proc splitDate (date: string): tuple[year: string, month: string, day: string] =
  let s = date.split("-")
  result = (s[0], s[1], s[2])

proc newArticle (slug: string, date: string = today()): int =
  let
    (year, month, day) = splitDate(date)
    path = &"{getCurrentDir()}/articles/{year}/{month}/{day}/{slug}"
  createDir(path)
  block:
    var brack = open(&"{path}/index.[]", fmReadWrite)
    brack.close()
  block:
    var setting = open(&"{path}/settings.toml", fmReadWrite)
    setting.write(articleSettingsToml(rand(1..16)))
    setting.close()

proc newDaily (date: string = today()): int =
  let
    (year, month, day) = splitDate(date)
    path = &"{getCurrentDir()}/dailies/{year}/{month}/{day}"
  createDir(path)
  block:
    var brack = open(&"{path}/index.[]", fmReadWrite)
    brack.close()
  block:
    var setting = open(&"{path}/settings.toml", fmReadWrite)
    setting.write(xlySettingsToml(rand(1..16)))
    setting.close()

proc newWeekly (date: string = today()): int =
  let
    (year, month, day) = splitDate(date)
    weekNo = day.parseInt div 7 + 1
    path = &"{getCurrentDir()}/weeklies/{year}/{month}/week0{weekNo}"
  createDir(path)
  block:
    var brack = open(&"{path}/index.[]", fmReadWrite)
    brack.close()
  block:
    var setting = open(&"{path}/settings.toml", fmReadWrite)
    setting.write(xlySettingsToml(rand(1..16)))

proc newMonthly (date: string = today()): int =
  let
    (year, month, _) = splitDate(date)
    path = &"{getCurrentDir()}/monthlies/{year}/{month}"
  createDir(path)
  block:
    var brack = open(&"{path}/index.[]", fmReadWrite)
    brack.close()
  block:
    var setting = open(&"{path}/settings.toml", fmReadWrite)
    setting.write(xlySettingsToml(rand(1..16)))

proc buildCommand (env: EnvKind = ekUser): int =
  build(env)

proc previewCommand (env: EnvKind = ekUser): int =
  preview(env)

when isMainModule:
  import cligen

  dispatchMulti(
    [newArticle, cmdName = "new:article"],
    [newDaily, cmdName = "new:daily"],
    [newWeekly, cmdName = "new:weekly"],
    [newMonthly, cmdName = "new:monthly"],
    [previewCommand, cmdName = "preview"],
    [buildCommand, cmdName = "build"]
  )
