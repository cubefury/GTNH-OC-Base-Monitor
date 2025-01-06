local componentDiscoverLib = require("lib.component-discover-lib")

---@class RedstoneBundledControllerConfig
---@field address string
---@field side number
---@field color number
---@field name string
---@field enableEuPercent number
---@field disableEuPercent number

local redstoneBundledController = {}

---Crate new RedstoneBundledController object from config
---@param config RedstoneBundledControllerConfig
---@return RedstoneBundledController
function redstoneBundledController:newFormConfig(config)
  return self:new(config.address, config.side, config.color, config.name, config.enableEuPercent, config.disableEuPercent)
end

---Crate new RedstoneBundledController object
---@param address string
---@param side number
---@param color number
---@param name string
---@param enableEuPercent number
---@param disableEuPercent number
---@return RedstoneBundledController
function redstoneBundledController:new(address, side, color, name, enableEuPercent, disableEuPercent)

  ---@class RedstoneBundledController
  local obj = {}

  obj.name = name
  obj.enableEuPercent = enableEuPercent
  obj.disableEuPercent = disableEuPercent
  obj.side = side
  obj.color = color

  obj.proxy = componentDiscoverLib.discoverProxy(address, name.." redstone", "redstone")

  ---Get machine state
  ---@return boolean
  function obj:getState()
    return self.proxy.getBundledOutput(self.side, self.color) == 15
  end

  ---Set machine state
  ---@param state boolean
  ---@return boolean
  function obj:setState(state)
    local signal = (state and 15 or 0)
    return self.proxy.setBundledOutput(self.side, self.color, signal) == 15
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return redstoneBundledController