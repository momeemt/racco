import env
import std/os
import std/json
import std/httpclient

proc times* (content: string, env: EnvKind) =
  let json = block:
    var f = open(getHomeDir() / ".racco/settings.json", fmRead)
    defer: f.close()
    let data = f.readAll()
    data.parseJson()
  let webhookUrl = json["times"]["discord_webhook_url"].getStr
  var client = newHttpClient()
  client.headers = newHttpHeaders({
    "Content-Type": "application/json"
  })
  let body = %* {
    "content": content
  }
  discard client.request(webhookUrl, HttpPost, $body)