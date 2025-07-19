local nearby = require('openmw.nearby')
local self = require('openmw.self')
local types = require('openmw.types')
local anim = require('openmw.animation')
local core = require('openmw.core')
local storage = require('openmw.storage')
local util = require('openmw.util')
local I = require("openmw.interfaces")



local function ReanimateEffect()
if self.recordId == "ksn_zombie_summon_prop" or self.recordId == "ksn_skeleton_weak_prop" then
		local effect = types.Actor.activeSpells(self):isSpellActive("ksn_reanimate")
		if effect == true then
							
		for i, Spellid in pairs(types.Actor.activeSpells(self)) do 	

				if Spellid.id == "ksn_reanimate" then
						types.Actor.activeSpells(actor):remove(Spellid.activeSpellId)
						--ReanimEffect = world.createObject('sprigganup', 1) need event
						--ReanimEffect:teleport(actor.cell.name, actor.position)need event
						self:sendEvent("Reanimate")
						local effect = types.Actor.activeEffects(ActorToReanimate)
						effect:getEffect("paralyze")
						effect:remove("paralyze")
						return
									
								
				end 
		end
							

							
							

		end
				
end



end

local function OnDeathEffects()
	 print('Alas, ye hardly knew me!')
end

I.AnimationController.addTextKeyHandler('', function(groupname, key)
    if types.Actor.isDead(self) then
	self:sendEvent("SoulTrapEnd", self)
    end
end)

local function SoulTrapEnd(Player)
if types.Actor.objectIsInstance(Player) then
	local effect = types.Actor.activeEffects(Player):getEffect("soultrap")
	if effect.magnitude > 0 then
	print(Player.recordId)
	core.sendGlobalEvent("SetBlackSoul", Player)
	end
	end

end


return {
eventHandlers = { Died = OnDeathEffects, SoulTrapEnd = SoulTrapEnd }

}