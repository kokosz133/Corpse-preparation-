local nearby = require('openmw.nearby')
local ui = require('openmw.ui')
local self = require('openmw.self')
local types = require('openmw.types')
local camera = require('openmw.camera')
local input = require('openmw.input')
local core = require('openmw.core')
local storage = require('openmw.storage')
local util = require('openmw.util')
local I = require("openmw.interfaces")
local HarvestedCorpses = storage.playerSection("IsHarvested")
HarvestedCorpses:setLifeTime(storage.LIFE_TIME.Persistent)

local function HarvestCorpse_P(data)

			if types.NPC.objectIsInstance(data.NPC) == true or types.Creature.record(data.NPC).type == 2 then
				if types.Actor.isDead(data.NPC) == true then
						if HarvestedCorpses:get(data.NPC.id) == data.NPC.id then
							ui.showMessage('This corpse was harvested!')
							return
						end
						if types.Player.quests(self)["KSN_SorkvildTeacher"].stage == 100 then
						ui.showMessage('You harvest a corpse!')
						core.sendGlobalEvent("HarvestCorpse", data.NPC)
						HarvestedCorpses:set(data.NPC.id, data.NPC.id)
						I.UI.addMode('Container', {target = data.NPC})
						else
						ui.showMessage('You don't know how to harvest a corpse!')
						end
						
				end
			end


end


return { eventHandlers = {HarvestCorpse_P = HarvestCorpse_P} }
