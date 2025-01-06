local componentDiscoverLib = require("lib.component-discover-lib")

---@class WirelessRedstoneControllerConfig
---@field address string
---@field frequency number
---@field name string
---@field enableEuPercent number
---@field disableEuPercent number

local wirelessRedstoneController = {}

---Crate new WirelessRedstoneController object from config
---@param config WirelessRedstoneControllerConfig
---@return WirelessRedstoneController
function wirelessRedstoneController:newFormConfig(config)
  return self:new(config.address, config.frequency, config.name, config.enableEuPercent, config.disableEuPercent)
end

---Crate new WirelessRedstoneController object
---@param address string
---@param frequency number
---@param name string
---@param enableEuPercent number
---@param disableEuPercent number
---@return WirelessRedstoneController
function wirelessRedstoneController:new(address, frequency, name, enableEuPercent, disableEuPercent)

  ---@class WirelessRedstoneController
  local obj = {}

  obj.name = name
  obj.enableEuPercent = enableEuPercent
  obj.disableEuPercent = disableEuPercent
  obj.frequency = frequency

  obj.proxy = componentDiscoverLib.discoverProxy(address, name.." redstone", "redstone")

  ---Get machine state
  ---@return boolean
  function obj:getState()
    self.proxy.setWirelessFrequency(self.frequency)
    return self.proxy.getWirelessOutput()
  end

  ---Set machine state
  ---@param state boolean
  ---@return boolean
  function obj:setState(state)
    self.proxy.setWirelessFrequency(self.frequency)
    return self.proxy.setWirelessOutput(state)
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return wirelessRedstoneController