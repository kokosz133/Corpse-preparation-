local nearby = require('openmw.nearby')
local types = require('openmw.types')
local AI = require('openmw.interfaces').AI
local time = require('openmw_aux.time')
local self = require('openmw.self')
local core = require('openmw.core')
local UndeadTable = {"ksn_zombie_summon_prop", "ksn_skeleton_weak_prop", "corpsepreparation_bonelord", "_skeleton"}
local Player
local GameTime = core.getGameTime()/time.day
local OldTime
local CurrentTime
local WasInJail = false

local function onUpdate()
	if self.recordId == "player" then
		Player = self
	end
	OldTime = GameTime
	GameTime = core.getGameTime()/time.day
	CurrentTime = GameTime-OldTime
	if (CurrentTime) > 5 then
	WasInJail = true
	core.sendGlobalEvent("CrimeRemoveUndead")
	return
	end
	for i, Undead in ipairs(UndeadTable) do
		if self.recordId == Undead then
			if types.Actor.isDead(self) == false and WasInJail == false and AI.getActivePackage().type == "Follow"  then
				core.sendGlobalEvent("NecromancyCrime")
				return
			end
		end
	end
	

end


local function onTeleported()
	if WasInJail == true then
	print("Byłeś w więzieniu")
	WasInJail = false
	end
	
end


return {engineHandlers = {onUpdate = onUpdate, onTeleported = onTeleported}}