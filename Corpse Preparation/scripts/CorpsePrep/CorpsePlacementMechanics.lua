local types = require('openmw.types')
local core = require('openmw.core')
--local anim = require('openmw.animation')
local world = require('openmw.world')
local player = world.players[1]
local PropID = nil
local UndeadChoiceActor = nil
local NavmeshPosition
local DoOnce = nil
local function ChoosePropPlace()
	if NavmeshPosition == nil then
	return
	end
	if PropID == nil then
	return
	end
	player = world.players[1]
	print(NavmeshPosition)
	PropID:teleport(world.players[1].cell.name, NavmeshPosition)
	if DoOnce == nil then
		--anim.clearAnimationQueue(PropID, true)
	end


	

end

local function CheckGlobalVariable()
	local UndeadChoice = world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"]
	if UndeadChoice == 0 and UndeadChoiceActor == nil and PropID == nil then
		world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"] = 0
	return
	end
	UndeadChoice = world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"]
	if UndeadChoice == 1 then
		world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"] = 0
		core.sendGlobalEvent("SpawnProp", "ksn_zombie_summon_prop")
		UndeadChoiceActor:remove()
		UndeadChoiceActor = nil
	end
	UndeadChoice = world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"]
	if UndeadChoice == 2 then
		world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"] = 0
		UndeadChoiceActor:remove()
		UndeadChoiceActor = nil
	end
	UndeadChoice = world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"]
	if UndeadChoice == 3 then
	world.mwscript.getGlobalVariables()["CorpsePreparation_UndeadChoice"] = 0
	core.sendGlobalEvent("HarvestCorpse", UndeadChoiceActor)
	UndeadChoiceActor = nil
	end

	ChoosePropPlace()

	

end

local function SetPropPosition(Position)
	--Dodać tutaj efekt paraliżu coby skurwysynu sie nie ruszały
	DoOnce = nil
	PropID = nil
	
end

local function GetNavmeshPosition(Position)
	NavmeshPosition = Position
	
end



local function SpawnProp(obj)
	player = world.players[1]
	Prop = world.createObject(obj, 1)
	Prop:teleport(world.players[1].cell.name, world.players[1].position)
        Prop:sendEvent("PlayAnimation", "knockout")
	PropID = Prop
end

local function SetFacedActor(Actor)
	UndeadChoiceActor = Actor
	
end

return {
    eventHandlers = { SpawnProp = SpawnProp, GetNavmeshPosition = GetNavmeshPosition, SetPropPosition = SetPropPosition, SetFacedActor = SetFacedActor },
    engineHandlers = {onUpdate = ChoosePropPlace, onUpdate = CheckGlobalVariable} 
}


