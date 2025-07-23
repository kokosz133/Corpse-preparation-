local self = require('openmw.self')
local types = require('openmw.types')
local AI=require('openmw.interfaces').AI


local function onUpdate()

end


local function Equip(data)
  types.Actor.setEquipment(self,data.Equipment)
end

local function setAttributes(data)
  for i, attribute in pairs(types.NPC.stats.attributes) do
    attribute(self).base=data.attributes[i]
  end
end

local function setSkills(data)
  for i, skill in pairs(types.NPC.stats.skills) do
    skill(self).base=data.skills[i]
  end
end

local function setLevel(data)
  types.NPC.stats.level(self).current=data.level
end


local function Order(data)
  if data.Order=="Follow" then
    AI.startPackage({type='Follow',target=data.Target})
  end
end


return {
    eventHandlers = {Equip=Equip, Order=Order, setSkills=setSkills, setAttributes=setAttributes, setLevel=setLevel
    },
    engineHandlers = {onUpdate=onUpdate,
  
  
  }
  }

