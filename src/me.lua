local component = require("component")
local event = require("event")
local computer = require("computer")

local componentDiscoverLib = require("lib.component-discover-lib")

---@class MeMonitorConfig
---@field meInterfaceAddress string
---@field materialList table<string, integer, string>

local meMonitor = {}

---Create new MeMonitor object from config
--@param config MeMonitorConfig
--@param meInterfaceAddress string
--@return MeMonitor
function meMonitor:newFormConfig(config)
  return self:new(
    config.meInterfaceAddress,
    config.materialList
  )
end


--Create new meMonitor object
--@param meInterfaceAddress string
--@param materialList table<string, integer, string>
function meMonitor:new(
  meInterfaceAddress,
  materialList
)
  ---@class meMonitor
  local obj = {}

  obj.meInterfaceProxy = nil
  obj.materialList = {}

  ---Init
  function obj:init()
    self.meInterfaceProxy = componentDiscoverLib.discoverProxy(meInterfaceAddress, "Me Interface", "me_interface")

    -- Populate initial values
    self.itemCount = self:getItemCount()
  end

  ---Update
  function obj:update()
    local newItemCount = self:getItemCount()
    self.updatedItemCount = {}
    for itemIndex = 1, #self.materialList do
      local itemName = materialList[itemIndex][3]
      self.updatedItemCount[itemName] = {
        amount = newItemCount[itemName].amount, 
        change = newItemCount[itemName] - self.itemCount[itemName]
      }
    end
    self.itemCount = newItemCount
  end

  --Get items and fluids from ae
  --@return table<string, integer>
  function obj:getItemCount()
    local itemList = {}
    for itemIndex = 1, #self.materialList do
      local item = obj.meInterfaceProxy.getItemsInNetwork({
        name = materialList[itemIndex][1], -- name
        damage = materialList[itemIndex][2] -- damage
      })
      itemList[materialList[itemIndex][3]] = {amount = item[1].size or 0, change = 0}
    end

    local liquids = obj.meInterfaceProxy.getFluidsInNetwork()
    for _, value in pairs(liquids) do
      for itemIndex = 1, #self.materialList do
        if value.label == materialList[itemIndex][1] then
          itemList[materialList[itemIndex][3]] = {amount = value.amount or 0, change = 0}
        end
      end
    end
    return itemList
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return meMonitor