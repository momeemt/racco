# Package

version       = "0.1.0"
author        = "Mutsuha Asada"
description   = "A new awesome nimble package"
license       = "Apache-2.0"
backend       = "js"
srcDir        = "src"
binDir        = "../web"
bin           = @["frontend"]

# Dependencies

requires "nim >= 1.6.8"
requires "karax == 1.2.2"
