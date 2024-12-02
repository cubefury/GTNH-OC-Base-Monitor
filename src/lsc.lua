local component = require("component")
local computer = require("computer")

local listLib = require("lib.list-lib")

---@class LSCConfig
---@field address string
---@field useMedian boolean
---@field wirelessMode boolean

---Parse information from SensorInformation
---@param value string
---@return number?
local function parseSensorInformation(value)
  local str = string.gsub(string.match(value, "[^§%d][%d,]+"), "[%D]", "")
  return tonumber(str)
end

local capacitors = {
  10000000000,
  1000000000000,
  100000000000000,
  10000000000000000
}

local lsc = {}

---Crate new LSC object from config
---@param config LSCConfig
---@return LSC
function lsc:newFormConfig(config)
  return self:new(config.address, config.useMedian, config.wirelessMode)
end

---Crate new LSC object
---@param address string
---@param useMedian boolean
---@return LSC
function lsc:new(address, useMedian, wirelessMode)

  ---@class LSC
  local obj = {}

  obj.proxy = component.proxy(address, "gt_machine")

  obj.wirelessMode = wirelessMode
  obj.useMedian = useMedian

  obj.inputHistory = listLib:new(20)
  obj.outputHistory = listLib:new(20)

  obj.stored = 0
  obj.capacity = 0
  obj.percent = 0
  obj.input = 0
  obj.output = 0
  obj.charge = 0
  obj.chargeLeft = 0

  obj.wirelessStored = 0
  obj.wirelessCharge = 0

  obj.lastWirelessStored = 0
  obj.lastReadWirelessStored = 0

  ---Update
  function obj:update()
    if self.wirelessMode then
      self:updateWireless()
    else
      self:updateLocal()
    end

    if useMedian then
      self.input = self.inputHistory:median()
      self.output = self.outputHistory:median()
    else
      self.input = self.inputHistory:average()
      self.output = self.outputHistory:average()
    end

    self.charge = self.input - self.output

    local chargeLeft = 0

    if self.charge > 0 then
      chargeLeft = (self.capacity - self.stored) / self.charge
    elseif self.charge < 0 then
      chargeLeft = self.stored / -self.charge
    else
      chargeLeft = 0
    end

    self.chargeLeft = math.floor(chargeLeft / 20)

    local percentRaw = self.stored / self.capacity * 100
    self.percent = math.floor(percentRaw * 100) / 100
  end

  function obj:updateLocal()
    local sensorInformation = self.proxy.getSensorInformation()

    self.inputHistory:pushBack(parseSensorInformation(sensorInformation[10]))
    self.outputHistory:pushBack(parseSensorInformation(sensorInformation[11]))

    self.stored = parseSensorInformation(sensorInformation[2])
    self.capacity = parseSensorInformation(sensorInformation[5])
  end

  function obj:updateWireless()
    local sensorInformation = self.proxy.getSensorInformation()

    self.inputHistory:pushBack(parseSensorInformation(sensorInformation[10]))
    self.outputHistory:pushBack(parseSensorInformation(sensorInformation[11]))

    local totalCapacity = 0

    totalCapacity = totalCapacity + capacitors[1] * parseSensorInformation(sensorInformation[15])
    totalCapacity = totalCapacity + capacitors[2] * parseSensorInformation(sensorInformation[16])
    totalCapacity = totalCapacity + capacitors[3] * parseSensorInformation(sensorInformation[17])
    totalCapacity = totalCapacity + capacitors[4] * parseSensorInformation(sensorInformation[18])

    self.stored = parseSensorInformation(sensorInformation[2])
    self.capacity = totalCapacity * 20 * 60 * 5

    self.wirelessStored = parseSensorInformation(sensorInformation[19])

    if self.lastWirelessStored ~= self.wirelessStored and self.wirelessStored >= 10 then
      local delta = self.wirelessStored - self.lastWirelessStored
      local time = computer.uptime() - self.lastReadWirelessStored

      self.wirelessCharge = delta / time
      self.lastWirelessStored = self.wirelessStored
      self.lastReadWirelessStored = computer.uptime()
    end
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return lsc