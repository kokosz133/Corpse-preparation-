local types = require('openmw.types')
local core = require('openmw.core')
local world = require('openmw.world')
local I = require("openmw.interfaces")
local PlayerInventory = world.players[1]
local ActorToReanimate = nil
local WasAnimationPlayed = false
local function OnUpdate()

	if ActorToReanimate and WasAnimationPlayed == false then
		ActorToReanimate:sendEvent("Reanimate")
		WasAnimationPlayed = true
		ActorToReanimate:sendEvent('StartAIPackage', {type='Follow', target=world.players[1]})
		local effect = types.Actor.activeEffects(ActorToReanimate)
		effect:getEffect("paralyze")
		effect:remove("paralyze")
		ActorToReanimate = nil
		
	end
	

	for i, actor in ipairs(world.activeActors) do 	 
			if actor.recordId == "ksn_zombie_summon_prop" or actor.recordId == "ksn_skeleton_weak_prop" or actor.recordId == "corpsepreparation_bonelord" or actor.recordId == "_skeleton"  then
					local effect = types.Actor.activeSpells(actor):isSpellActive("ksn_reanimate")
					if effect == true then
							
								for i, Spellid in pairs(types.Actor.activeSpells(actor)) do 																	if Spellid.id == "ksn_reanimate" then
										types.Actor.activeSpells(actor):remove(Spellid.activeSpellId)
										ReanimEffect = world.createObject('sprigganup', 1)
										ReanimEffect:teleport(actor.cell.name, actor.position)
										ActorToReanimate = actor
										core.sendGlobalEvent("NecromancyCrime")
										WasAnimationPlayed = false
										return
									
								
									end 
								end
							

							
							

					end
				
			end





	end
end


return { engineHandlers = {onUpdate = OnUpdate} }

