local types = require('openmw.types')
local self = require('openmw.self')
local anim = require('openmw.animation')
local I = require('openmw.interfaces')

local function PlayAnimation(Animation)
	anim.clearAnimationQueue(self, false)
	anim.playQueued(self, Animation)
end

local function Reanimate()
	anim.clearAnimationQueue(self, false)
	anim.playQueued(self, 'knockout', {startkey = 'loop stop', stopkey = 'loop start', loops = 0})
end

I.AnimationController.addTextKeyHandler('knockout', function(groupname, key)
	if key == "stop" then
	print("STOP!!!")
	anim.clearAnimationQueue(self, true)
	end   
end)



return {
    eventHandlers = { PlayAnimation = PlayAnimation, Reanimate = Reanimate },
}