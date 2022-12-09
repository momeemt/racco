include karax / prelude
import std/jsfetch
import std/[asyncjs, jsconsole, jsheaders, jsformdata]
import std/sugar
import std/json
import std/dom


proc doFetch (url: string): Future[Response] {.async.} =
  fetch cstring(url)

proc example() {.async.} =
  let response: Response = await doFetch("2022/10/22/test.json")
  console.log(await response.json())


window.history.pushState(0, cstring("articles"), cstring("/"))

proc render (): VNode =
  result = buildHtml(tdiv):
    if window.location.pathname == "/":
      button(onclick = () => window.history.pushState(0, cstring("articles"), cstring("/articles"))):
        text "articles"
    elif window.location.pathname == "/articles":
      button(onclick = () => window.history.pushState(0, cstring("articles"), cstring("/"))):
        text "default"

setRenderer render