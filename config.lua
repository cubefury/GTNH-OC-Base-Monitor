local sides = require("sides")
local colors = require("colors")

local loggerLib = require("lib.logger-lib")
local discordLoggerHandler = require("lib.logger-handler.discord-logger-handler-lib")
local fileLoggerHandler = require("lib.logger-handler.file-logger-handler-lib")

local lsc = require("src.lsc")

local gtnhController = require("src.controllers.gtnh-controller")
local wirelessRedstoneController = require("src.controllers.wireless-redstone-controller")
local redstoneController = require("src.controllers.redstone-controller")
local redstoneBundledController = require("src.controllers.redstone-bundled-controller")

local config = {
  enableAutoUpdate = true, -- Enable auto update on start

  logger = loggerLib:newFormConfig({
    name = "LSC Control",
    timeZone = 3, -- Your time zone
    handlers = {
      discordLoggerHandler:newFormConfig({
        logLevel = "warning",
        messageFormat = "{Time:%d.%m.%Y %H:%M:%S} [{LogLevel}]: {Message}",
        discordWebhookUrl = "" -- Discord Webhook URL
      }),
      fileLoggerHandler:newFormConfig({
        logLevel = "info",
        messageFormat = "{Time:%d.%m.%Y %H:%M:%S} [{LogLevel}]: {Message}",
        filePath = "logs.log"
      })
    }
  }),

  lsc = lsc:newFormConfig({
    useMedian = false, -- Use median in calculations
    wirelessMode = false, -- Use wireless network mode
    version = "2.7", -- Your game version allow ["2.6", "2.7", "custom"]
    customLines = { -- Lines number in SensorInformation for version ["custom"]
      storedEu = 2, -- EU Stored line
      capacity = 5, -- Total Capacity line
      avgEuIn = 10, -- Avg EU IN: 0 (last 5 seconds) line
      avgEuOut = 11, -- Avg EU OUT: 0 (last 5 seconds) line
      capacitorUHV = 19, -- UHV Capacitors detected line
      capacitorUEV = 20, -- UEV Capacitors detected line
      capacitorUIV = 21, -- UIV Capacitors detected line
      capacitorUMV = 22, -- UMV Capacitors detected line
      wirelessStored = 23 -- Total wireless EU line
    },
  }),

  generators = { -- List of generators to control 
    -- redstoneBundledController:newFormConfig({ -- Controller for control with redstone bundled cable
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of redstone IO
    --   side = sides.north, -- Side of redstone IO to which connected bundled cable
    --   color = colors.magenta, -- Color of bundled cable line
    --   name = "Name", -- Name of generator
    --   enableEuPercent = 75, -- EU percent (0 - 100) at which the generator switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the generator switches off
    -- }),

    -- redstoneController:newFormConfig({ -- Controller for control with redstone cable
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of redstone IO
    --   side = sides.north, -- Side of redstone IO to which connected redstone
    --   name = "Name", -- Name of generator
    --   enableEuPercent = 75, -- EU percent (0 - 100) at which the generator switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the generator switches off
    -- }),

    -- gtnhController:newFormConfig({ -- Controller for direct control of the generator
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of adapter which connected to gtnh generator
    --   name = "Name", -- Name of generator
    --   enableEuPercent = 20, -- EU percent (0 - 100) at which the generator switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the generator switches off
    -- }),

    -- wirelessRedstoneController:newFormConfig({ -- Controller for control with wireless redstone (FOR MOD WR-CBE NOT FOR GT WIRELESS COVERS)
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of adapter which connected to gtnh generator
    --   frequency = 100, -- Frequency of wireless redstone (FOR MOD WR-CBE NOT FOR GT WIRELESS COVERS)
    --   name = "Name", -- Name of generator
    --   enableEuPercent = 20, -- EU percent (0 - 100) at which the generator switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the generator switches off
    -- })
  },

  machines = { -- List of machines to control
  -- redstoneBundledController:newFormConfig({ -- Controller for control with redstone bundled cable
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of redstone IO
    --   side = sides.north, -- Side of redstone IO to which connected bundled cable
    --   color = colors.magenta, -- Color of bundled cable line
    --   name = "Name", -- Name of machine
    --   enableEuPercent = 75, -- EU percent (0 - 100) at which the machine switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the machine switches off
    -- }),

    -- redstoneController:newFormConfig({ -- Controller for control with redstone cable
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of redstone IO
    --   side = sides.north, -- Side of redstone IO to which connected redstone
    --   name = "Name", -- Name of machine
    --   enableEuPercent = 75, -- EU percent (0 - 100) at which the machine switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the machine switches off
    -- }),

    -- gtnhController:newFormConfig({ -- Controller for direct control of the machine
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of adapter which connected to gtnh machine
    --   name = "Name", -- Name of machine
    --   enableEuPercent = 20, -- EU percent (0 - 100) at which the machine switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the machine switches off
    -- }),

    -- wirelessRedstoneController:newFormConfig({ -- Controller for control with wireless redstone (FOR MOD WR-CBE NOT FOR GT WIRELESS COVERS)
    --   address = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of adapter which connected to gtnh machine
    --   frequency = 100, -- Frequency of wireless redstone (FOR MOD WR-CBE NOT FOR GT WIRELESS COVERS)
    --   name = "Name", -- Name of machine
    --   enableEuPercent = 20, -- EU percent (0 - 100) at which the machine switches on
    --   disableEuPercent = 98 -- EU percent (0 - 100) at which the machine switches off
    -- })
  }
}

return config