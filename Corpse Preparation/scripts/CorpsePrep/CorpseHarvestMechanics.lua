local world = require('openmw.world')
local core = require('openmw.core')
local types = require('openmw.types')
local I = require("openmw.interfaces")
local PlayerInventory = world.players[1]
local TorsoDropped = false

local function HarvestCorpse(Actor)
TorsoDropped = false

if math.random() >= 0.5 then
money = world.createObject('KSN_Misc_BoneSkelArmR', 1)
money:moveInto(types.Actor.inventory(Actor))		
end

if math.random() >= 0.5 then
money = world.createObject('KSN_Misc_BoneSkelPelvis', 1)
money:moveInto(types.Actor.inventory(Actor))		
end

if math.random() >= 0.5 then
money = world.createObject('KSN_Misc_BoneSkelSkullUpper', 1)
money:moveInto(types.Actor.inventory(Actor))		
end

if math.random() >= 0.5 then
money = world.createObject('KSN_Misc_BoneSkelTorso', 1)
money:moveInto(types.Actor.inventory(Actor))
TorsoDropped = true		
end

if math.random() >= 0.5 then
money = world.createObject('KSN_Misc_Leg', 1)
money:moveInto(types.Actor.inventory(Actor))		
end

if math.random() >= 0.5 and TorsoDropped == false then
money = world.createObject('KSN_misc_TorsoBroken', 1)
money:moveInto(types.Actor.inventory(Actor))
TorsoDropped = false		
end

world.players[1]:sendEvent("OpenHarvestingContainer", Actor)

end


local function OpenNecroCrafting(obj)
    zombie = world.createObject('ksn_craftingmenuobj', 1)
    zombie:teleport(world.players[1].cell.name, world.players[1].position)

end

local function RemoveCorpse(actor)
actor:remove()
end


local function ReanimateCrippledSkeleton(obj)
	zombie = world.createObject('_Skeleton', 1)
	ReanimEffect = world.createObject('sprigganup', 1)
	zombie:teleport(obj.cell.name, obj.position)
	zombie:sendEvent('StartAIPackage', {type='Follow', target=world.players[1]})
	ReanimEffect:teleport(obj.cell.name, obj.position)
	obj:remove(1)
	obj:moveInto(types.Actor.inventory(PlayerInventory))
	return

end

local function SetBlackSoul(actor)
				local PlayerInventory = world.players[1]
					local BlackSoulGem = types.Actor.inventory(PlayerInventory):findAll('Misc_SoulGem_Grand')
					for i, gems in ipairs(BlackSoulGem) do
						local isDead = types.Actor.isDead(actor)
						if isDead == true then
							gems:remove(1)
							world.players[1]:sendEvent("ShowMessage", core.getGMST("sSoultrapSuccess"))
							money = world.createObject('Misc_SoulGem_Grand', 1)
							money.type.setSoul(money, "CorpsePreparation_soul")
							money:moveInto(types.Actor.inventory(PlayerInventory))
							effect = types.Actor.activeEffects(actor):remove("soultrap")
							world.players[1]:sendEvent("playSoundEvent", "conjuration hit")
							anim.addVfx(actor, "VFX_Soul_Trap")
						end

							
					end

end


return {
    eventHandlers = { HarvestCorpse = HarvestCorpse, OpenNecroCrafting = OpenNecroCrafting, ReanimateCrippledSkeleton = ReanimateCrippledSkeleton, RemoveCorpse = RemoveCorpse, SetBlackSoul = SetBlackSoul },
}


