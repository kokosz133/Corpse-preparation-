local types = require('openmw.types')
local world = require('openmw.world')
local I = require("openmw.interfaces")
local core = require('openmw.core')
local UndeadTable = {"ksn_zombie_summon_prop", "ksn_skeleton_weak_prop", "corpsepreparation_bonelord", "_skeleton"}



local function NecromancyCrime()

	if types.Player.getCrimeLevel(world.players[1]) < 1000 then
		I.Crimes.commitCrime(world.players[1], {type = types.Player.OFFENSE_TYPE.Murder})
		
	end
	

end


local function CrimeRemoveUndead()
	for i, undead in ipairs(world.activeActors) do
		for n, actor in ipairs(UndeadTable) do
			if undead.recordId == actor then
				if undead then
				undead:remove()
				end
				types.Player.setCrimeLevel(world.players[1], 0)
				
			end
		end
	end
		
end


return  { eventHandlers = {NecromancyCrime = NecromancyCrime, CrimeRemoveUndead = CrimeRemoveUndead }}