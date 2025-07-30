local keyboard = require("keyboard")
local serialization = require("serialization")

local programLib = require("lib.program-lib")
local guiLib = require("lib.gui-lib")

local chargeBar = require("lib.gui-widgets.charge-bar")
local scrollList = require("lib.gui-widgets.scroll-list")

package.loaded.config = nil
local config = require("config")

local version = require("version")

local repository = "Navatusein/GTNH-OC-LSC-Control"
local archiveName = "LSCControl"

local program = programLib:new(config.logger, config.enableAutoUpdate, version, repository, archiveName)
local gui = guiLib:new(program)

local logo = {
  " _     ____   ____    ____            _             _ ",
  "Logo goes here lmao",
}

local generatorStatuses = {}

local localModeTemplate = {
  width = 60,
  background = gui.palette.black,
  foreground = gui.palette.white,
  widgets = {
    chargeBar = chargeBar:new("percent", "charge", 5, 8),
    generatorList = scrollList:new("generatorList", "generatorStatuses", keyboard.keys.up, keyboard.keys.down)
  },
  lines = {
    "Charge: $percent:s,%.2f$% $stored:mu,EU$ / $capacity:mu,EU$",
    "In: &green;$input:mu,EU/t$&white; Out: &red;$output:mu,EU/t$",
    "@c;?charge >=0|&green;|&red;?$charge:mu,EU/t$",
    "#chargeBar#",
    "?(percent >= 99.9 and charge == 0)|&green;@c;Fully charged|?"..
      "?(percent == 0 and charge == 0)|&red;@c;Completely discharged|?"..
      "?(percent < 99.9 and charge > 0)|Time to full: &green;$chargeLeft:t,2$|?"..
      "?(percent < 99.9 and charge < 0)|Time to empty: &red;$chargeLeft:t,2$|?"..
      "?(percent > 0 and percent < 99.9 and charge == 0)|@c;Idle|?",
    "?isWorkAllowed == false|@c;&&golden; LSC Disabled |?"..
      "?needMaintenance == true|@c;&&red; Need Maintenance |?",
    "#generatorList#",
    "#generatorList#",
    "#generatorList#",
    "#generatorList#",
    "#generatorList#",
  }
}

local wirelessModeTemplate = {
  width = 60,
  background = gui.palette.black,
  foreground = gui.palette.white,
  widgets = {
    chargeBar = chargeBar:new("percent", "charge", 5, 8),
    generatorList = scrollList:new("generatorList", "generatorStatuses", keyboard.keys.up, keyboard.keys.down)
  },
  lines = {
    "Wireless Charge: $wirelessStored:mu,EU$",
    "@c;?wirelessCharge >=0|&green;|&red;?$wirelessCharge:mu,EU/t$",
    "",
    "Charge: $percent:s,%.2f$% $stored:mu,EU$ / $capacity:mu,EU$",
    "#chargeBar#",
    "@c;?charge >=0|&green;|&red;?$charge:mu,EU/t$",
    "?(percent >= 99.9 and charge == 0)|&green;@c;Fully charged|?"..
      "?(percent == 0 and charge == 0)|&red;@c;Completely discharged|?"..
      "?(percent < 99.9 and charge > 0)|Time to full: &green;$chargeLeft:t,2$|?"..
      "?(percent < 99.9 and charge < 0)|Time to empty: &red;$chargeLeft:t,2$|?"..
      "?(percent > 0 and percent < 99.9 and charge == 0)|@c;Idle|?",
    "?isWorkAllowed == false|@c;&&golden; LSC Disabled |?"..
      "?needMaintenance == true|@c;&&red; Need Maintenance |?",
    "#generatorList#",
    "#generatorList#",
    "#generatorList#",
  }
}

local function init()
  gui:setTemplate(config.lsc.wirelessMode and wirelessModeTemplate or localModeTemplate)
  config.lsc:init()
end

local function loop()
  while true do
    config.lsc:update()

    for index, generator in pairs(config.generators) do
      if not generator:getState() and config.lsc.percent < generator.enableEuPercent then
        generator:setState(true)
      end

      if generator:getState() and config.lsc.percent > generator.disableEuPercent then
        generator:setState(false)
      end

      generatorStatuses[index] = "[G] "..generator.name..": "..(generator:getState() and "&green;On" or "&red;Off")
    end

    for index, machine in pairs(config.machines) do
      if not machine:getState() and config.lsc.percent > machine.enableEuPercent then
        machine:setState(true)
      end

      if machine:getState() and config.lsc.percent < machine.disableEuPercent then
        machine:setState(false)
      end

      generatorStatuses[index + #config.generators] = "[M] "..machine.name..": "..(machine:getState() and "&green;On" or "&red;Off")
    end

    os.sleep(3)
  end
end

local function guiLoop()
  gui:render({
    isWorkAllowed = config.lsc.isWorkAllowed,
    percent = config.lsc.percent,
    stored = config.lsc.stored,
    capacity = config.lsc.capacity,
    charge = config.lsc.charge,
    input = config.lsc.input,
    output = config.lsc.output,
    chargeLeft = config.lsc.chargeLeft,
    wirelessStored = config.lsc.wirelessStored,
    wirelessCharge = config.lsc.wirelessCharge,
    needMaintenance = config.lsc.needMaintenance,
    generatorStatuses = generatorStatuses
  })
end

program:registerLogo(logo)
program:registerInit(init)
program:registerThread(loop)
program:registerTimer(guiLoop, math.huge)
program:start()