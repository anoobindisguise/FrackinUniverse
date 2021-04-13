require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"
local foodThreshold=10

function init()
	self.rechargeDirectives = "?fade=CC22CCFF=0.1"
	self.rechargeEffectTime = 0.1
	self.rechargeEffectTimer = 0
	self.flashCooldownTimer = 0
	self.halted = 0
end

function checkFood()
	return (((status.statusProperty("fuFoodTrackerHandler",0)>-1) and status.isResource("food")) and status.resource("food")) or foodThreshold
end

function activeFlight(direction)
	status.removeEphemeralEffect("wellfed")
	local movement=mcontroller.velocity()
	world.spawnProjectile("minerclaw", mcontroller.position(), entity.id(), direction, false,{speed=(8+math.sqrt((movement[1]^2)+(movement[2]^2))),power = (checkFood() /17),actionOnReap = {{action='explosion',foregroundRadius=totalVal,backgroundRadius=(totalVal/2),explosiveDamageAmount= (totalVal/2),harvestLevel = 99,delaySteps=2}}})
end

function aimVector(x,y,run)
	local banana=(run and mcontroller.facingDirection()) or 0
	return {(x+banana)*2,y*2}
end

function update(args)
	local primaryItem = world.entityHandItem(entity.id(), "primary")
	local altItem = world.entityHandItem(entity.id(), "alt")
	self.firetimer = math.max(0, (self.firetimer or 0) - args.dt)

	if self.flashCooldownTimer > 0 then
		self.flashCooldownTimer = math.max(0, self.flashCooldownTimer - args.dt)
		if self.flashCooldownTimer <= 2 then
			if self.halted == 0 then
				self.halted = 1
			end
		end

		if self.flashCooldownTimer == 0 then
			self.rechargeEffectTimer = self.rechargeEffectTime
			tech.setParentDirectives(self.rechargeDirectives)
			animator.playSound("refire")
		end
	end

	if self.rechargeEffectTimer > 0 then
		self.rechargeEffectTimer = math.max(0, self.rechargeEffectTimer - args.dt)
		if self.rechargeEffectTimer == 0 then
			tech.setParentDirectives()
		end
	end

	if args.moves["special1"] and self.firetimer == 0 and not (primaryItem and root.itemHasTag(primaryItem, "weapon")) and not (altItem and root.itemHasTag(altItem, "weapon")) then
		local upDown=((args.moves["down"] and -1) or 0) + ((args.moves["up"] and 1) or 0)
		local leftRight=((args.moves["left"] and -1) or 0) + ((args.moves["right"] and 1) or 0)
		if checkFood() > foodThreshold then
			status.addEphemeralEffects{{effect = "foodcostclaw", duration = 0.01}}
		else
			status.overConsumeResource("energy", 1)
		end
		self.firetimer = 0.3
		activeFlight(aimVector(leftRight,upDown,args.moves["run"]))
		self.dashCooldownTimer = 0.3
		self.flashCooldownTimer = 0.3
		self.halted = 0
	end
end