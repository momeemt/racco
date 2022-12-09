import brack
import brack/api
import brack/ast

initExpander(Html)
initGenerator(Json)

import std/os
import std/times
import std/strformat
import std/strutils
import std/sequtils
import std/algorithm
import std/sugar
import std/json

import utils
import parsetoml

include "../scfs/index.html.nimf"
include "../scfs/daily_index.html.nimf"
include "../scfs/article.html.nimf"
include "../scfs/daily.html.nimf"

proc build* () =
  let
    currentDir = getCurrentDir()
    appDir = getAppDir()
  createDir(currentDir / "dist")
  os.copyFile(appDir / "css/style.css", currentDir / "dist/style.css")
  os.copyFile(appDir / "web/frontend.js", currentDir / "dist/frontend.js")
  os.copyFile(appDir / "web/index.html", currentDir / "dist/index.html")
  os.copyDir(appDir / "assets/", currentDir / "dist/assets/")

  var articles: seq[Page] = @[]
  for (dayInDir, year, month, day) in dateInDir(currentDir / "articles"):
    for dir in walkDir(dayInDir.path):
      let
        name = dir.path.split('/')[^1]
        toml = parsetoml.parseFile(dir.path / "settings.toml")
        title = toml["blog"]["title"].getStr()
        overview = toml["blog"]["overview"].getStr()
        tags = toml["blog"]["tags"].getElems().map(t => t.getStr())
        thumbnail = toml["blog"]["thumbnail"].getInt()
        published = toml["blog"]["published"].getBool()
        page = (
          title,
          overview,
          &"{year}-{month}-{day}",
          &"{year}/{month}/{day}/{name}",
          &"{thumbnail}.png",
          tags
        )

      block:
        createDir(currentDir / &"dist/{year}/{month}/{day}/")
        for assets in walkFiles(dir.path / "assets"):
          copyFile(assets, currentDir / &"dist/{year}/{month}/{day}/")
        var outputFile = open(currentDir / &"dist/{year}/{month}/{day}/{name}.json", FileMode.fmWrite)
        defer: outputFile.close()
        let tokens = tokenize(dir.path / "index.[]")
        let ast = tokens.parse()
        var json = ast.expand().generate()
        json["title"] = newJString(title)
        json["overview"] = newJString(overview)
        json["tags"] = newJArray()
        for tag in tags:
          json["tags"].add newJString(tag)
        json["thumbnail"] = newJInt(thumbnail)
        json["published"] = newJBool(published)
        outputFile.write(json.pretty)
      
      articles.add page

  var dailies: seq[Page] = @[]
  for (dir, year, month, day) in dateInDir(currentDir / "dailies"):
    let
      toml = parsetoml.parseFile(dir.path / "settings.toml")
      overview = toml["blog"]["overview"].getStr()
      thumbnail = toml["blog"]["thumbnail"].getInt()
      published = toml["blog"]["published"].getBool()
      page: Page = (
        &"{year}.{month}.{day}",
        overview,
        &"{year}-{month}-{day}",
        &"{year}/{month}/{day}",
        &"{thumbnail}.png",
        @[]
      )

    block:
      createDir(currentDir / &"dist/daily/{year}/{month}/{day}/")
      for assets in walkDir(dir.path / "assets/"):
        let name = $assets.path.split('/')[^1]
        copyFile(assets.path, currentDir / &"dist/daily/{year}/{month}/{day}/{name}")
      var outputFile = open(currentDir / &"dist/daily/{year}/{month}/{day}/daily.json", FileMode.fmWrite)
      defer: outputFile.close()
      var json = tokenize(dir.path / "index.[]").parse().expand().generate()
      json["overview"] = newJString(overview)
      json["thumbnail"] = newJInt(thumbnail)
      json["published"] = newJBool(published)
      outputFile.write(json.pretty)
    
    dailies.add page

  block:
    var outputFile = open(currentDir / &"dist/articles.json", FileMode.fmWrite)
    defer: outputFile.close()
    var json = %* { "articles": [] }
    for article in articles:
      json["articles"].add(%* {
        "title": article.title,
        "overview": article.overview,
        "date": article.date,
        "href": article.href,
        "thumbnail": article.thumbnail,
        "tags": article.tags
      })
    outputFile.write(json.pretty)

  block:
    createDir(currentDir / &"dist/daily/")
    var outputFile = open(currentDir / &"dist/dailies.json", FileMode.fmWrite)
    defer: outputFile.close()
    var json = %* { "dailies": [] }
    for daily in dailies:
      json["dailies"].add(%* {
        "title": daily.title,
        "overview": daily.overview,
        "date": daily.date,
        "href": daily.href,
        "thumbnail": daily.thumbnail,
        "tags": daily.tags
      })
    outputFile.write(json.pretty)

  let now = now().format("yyyy-MM-dd HH:mm:ss")
  echo &"[{now}] 🎉 Success to build!"
