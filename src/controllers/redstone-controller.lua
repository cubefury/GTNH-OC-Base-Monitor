local componentDiscoverLib = require("lib.component-discover-lib")

---@class RedstoneControllerConfig
---@field address string
---@field side number
---@field name string
---@field enableEuPercent number
---@field disableEuPercent number

local redstoneController = {}

---Crate new RedstoneController object from config
---@param config RedstoneControllerConfig
---@return RedstoneController
function redstoneController:newFormConfig(config)
  return self:new(config.address, config.side, config.name, config.enableEuPercent, config.disableEuPercent)
end

---Crate new RedstoneController object
---@param address any
---@param side number
---@param name string
---@param enableEuPercent number
---@param disableEuPercent number
---@return RedstoneController
function redstoneController:new(address, side, name, enableEuPercent, disableEuPercent)

  ---@class RedstoneController
  local obj = {}

  obj.name = name
  obj.enableEuPercent = enableEuPercent
  obj.disableEuPercent = disableEuPercent
  obj.side = side

  obj.proxy = componentDiscoverLib.discoverProxy(address, name.." redstone", "redstone")

  ---Get machine state
  function obj:getState()
    return self.proxy.getOutput(self.side) == 15
  end

  ---Set machine state
  ---@param state boolean
  ---@return boolean
  function obj:setState(state)
    local signal = (state and 15 or 0)
    return self.proxy.setOutput(self.side, signal) == 15
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return redstoneController