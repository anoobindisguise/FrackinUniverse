require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

function activeFlight(direction)
    animator.playSound("activate",3)
    animator.playSound("recharge")
    animator.setSoundVolume("activate", 0.5,0)
    animator.setSoundVolume("recharge", 0.375,0)
	local movement=mcontroller.velocity()
    world.spawnProjectile("plasmafistrocketpharitu",self.mouthPosition,entity.id(),direction,false,{speed=(25+math.sqrt((movement[1]^2)+(movement[2]^2))),power=(((status.resource("energy")/150)+(status.stat("protection")/250))),damageSourceKind="cosmic"})
end

function aimVector(x,y,run)
	local banana=(run and mcontroller.facingDirection()) or 0
	return {(x+banana)*2,y*2}
end

function update(args)
	self.mouthPosition = vec2.add(mcontroller.position(), {mcontroller.facingDirection(),(args.moves["down"] and -0.7) or 0.15})

	self.firetimer = math.max(0, (self.firetimer or 0) - args.dt)

	local upDown=((args.moves["down"] and -1) or 0) + ((args.moves["up"] and 1) or 0)
	local leftRight=((args.moves["left"] and -1) or 0) + ((args.moves["right"] and 1) or 0)
	if args.moves["special1"] and status.overConsumeResource("energy", 0.001) then
		if self.firetimer == 0 then
			status.overConsumeResource("energy", 2)

			self.firetimer = 0.05
			activeFlight(aimVector(leftRight,upDown,args.moves["run"]))
		end
	else
		animator.stopAllSounds("activate")
	end
end