local component = require("component")

---@class GtnhControllerConfig
---@field address string
---@field name string
---@field enableEuPercent number
---@field disableEuPercent number

local gtnhController = {}

---Crate new GtnhController object from config
---@param config GtnhControllerConfig
---@return GtnhController
function gtnhController:newFormConfig(config)
  return self:new(config.address, config.name, config.enableEuPercent, config.disableEuPercent)
end

---Crate new GtnhController object
---@param address string
---@param name string
---@param enableEuPercent number
---@param disableEuPercent number
---@return GtnhController
function gtnhController:new(address, name, enableEuPercent, disableEuPercent)

  ---@class GtnhController
  local obj = {}

  obj.address = address
  obj.name = name
  obj.enableEuPercent = enableEuPercent
  obj.disableEuPercent = disableEuPercent

  obj.proxy = component.proxy(address, "gt_machine")

  ---Get machine state
  ---@return boolean
  function obj:getState()
    return self.proxy.isMachineActive()
  end

  ---Set machine state
  ---@param state boolean
  ---@return boolean
  function obj:setState(state)
    self.proxy.setWorkAllowed(state)
    return self.proxy.isMachineActive()
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return gtnhController