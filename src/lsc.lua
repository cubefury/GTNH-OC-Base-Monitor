local computer = require("computer")

local listLib = require("lib.list-lib")
local componentDiscoverLib = require("lib.component-discover-lib")
local gtSensorParserLib = require("lib.gt-sensor-parser")

---@class SensorInformationFields
---@field storedEu integer
---@field capacity integer
---@field avgEuIn integer
---@field avgEuOut integer
---@field capacitorUHV integer
---@field capacitorUEV integer
---@field capacitorUIV integer
---@field capacitorUMV integer
---@field wirelessStored integer

---@class LSCConfig
---@field useMedian boolean
---@field wirelessMode boolean
---@field version "custom"|"2.6"|"2.7"
---@field customLines SensorInformationFields

local capacitors = {
  UHV = 10000000000,
  UEV = 1000000000000,
  UIV = 100000000000000,
  UMV = 10000000000000000
}

local lsc = {}

---Crate new LSC object from config
---@param config LSCConfig
---@return LSC
function lsc:newFormConfig(config)
  return self:new(config.useMedian, config.wirelessMode, config.version, config.customLines)
end

---Crate new LSC object
---@param useMedian boolean
---@param wirelessMode boolean
---@param version "custom"|"2.6"|"2.7"
---@param customLines SensorInformationFields
---@return LSC
function lsc:new(useMedian, wirelessMode, version, customLines)

  ---@class LSC
  local obj = {}

  obj.proxy = nil
  obj.gtSensorParser = nil

  obj.wirelessMode = wirelessMode
  obj.useMedian = useMedian

  obj.inputHistory = listLib:new(20)
  obj.outputHistory = listLib:new(20)

  obj.version = version

  obj.lines = {
    ["custom"] = customLines,
    ["2.6"] = {
      storedEu = 2,
      capacity = 5,
      avgEuIn = 10,
      avgEuOut = 11,
      capacitorUHV = 14,
      capacitorUEV = 15,
      capacitorUIV = 16,
      capacitorUMV = 17,
      wirelessStored = 18
    },
    ["2.7"] = {
      storedEu = 2,
      capacity = 5,
      avgEuIn = 10,
      avgEuOut = 11,
      capacitorUHV = 19,
      capacitorUEV = 20,
      capacitorUIV = 21,
      capacitorUMV = 22,
      wirelessStored = 23
    }
  }

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

  ---Init
  function obj:init()
    self.proxy = componentDiscoverLib.discoverGtMachine("multimachine.supercapacitor")
    self.gtSensorParser = gtSensorParserLib:new(self.proxy)
  end

  ---Update
  function obj:update()
    self.gtSensorParser:getInformation()

    self.inputHistory:pushBack(self.gtSensorParser:getNumber(self.lines[self.version].avgEuIn))
    self.outputHistory:pushBack(self.gtSensorParser:getNumber(self.lines[self.version].avgEuOut))

    self.stored = self.gtSensorParser:getNumber(self.lines[self.version].storedEu)

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
    self.capacity = self.gtSensorParser:getNumber(self.lines[self.version].capacity)
  end

  function obj:updateWireless()
    local capacity = 0

    capacity = capacity + capacitors["UHV"] * self.gtSensorParser:getNumber(self.lines[self.version].capacitorUHV)
    capacity = capacity + capacitors["UEV"] * self.gtSensorParser:getNumber(self.lines[self.version].capacitorUEV)
    capacity = capacity + capacitors["UIV"] * self.gtSensorParser:getNumber(self.lines[self.version].capacitorUIV)
    capacity = capacity + capacitors["UMV"] * self.gtSensorParser:getNumber(self.lines[self.version].capacitorUMV)

    self.capacity = capacity * 20 * 60 * 5

    self.wirelessStored = self.gtSensorParser:getNumber(self.lines[self.version].wirelessStored)

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
