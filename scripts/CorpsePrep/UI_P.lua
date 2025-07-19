local types = require('openmw.types')
local I = require("openmw.interfaces")
local core = require('openmw.core')
local async = require('openmw.async')
local NecromancyCrime = false


--async:callback(showFn)
--async:callback(hideFn)
--I.UI.registerWindow("Dialogue", showFn, hideFn)

local function showFn()

	if types.Player.getCrimeLevel(self) >= 1000 then
		NecromancyCrime = true		
	end

end


local function hideFn()

	if types.Player.getCrimeLevel(self) == 0 then
		NecromancyCrime = false
		core.sendGlobalEvent("CrimeRemoveUndead")
				
	end

end
