if myHero.charName ~= "Talon" then return end

require "SxOrbwalk"

local mTarget = nil
local QAble, WAble, EAble, RAble = false, false, false, false
local Orbwalk = nil

function OnLoad()                     
	Orbwalk = SxOrbWalk()
	
	Config = scriptConfig("Talon", "Talon")

	Config:addParam("Combo", "Combo Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("Harass", "Harass Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
								
	Orbwalk:LoadToMenu(Config)
end
     
     

function OnTick()
	Checks()
	if Config.Combo then Combo() end
	if Config.Harass then Harass() end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
	
	local sxTarget = Orbwalk:GetTarget()
	if sxTarget and sxTarget.type == myHero.type then
		mTarget = sxTarget
	elseif not mTarget then 
		local best, damage = nil, 99
		for i, enemy in pairs(GetEnemyHeroes()) do   -- From SxOrbWalk, just extends skill range
			if enemy.team ~= myHero.team and ValidTarget(enemy, 1300) then
				local qdamage = getDmg("Q", enemy, myHero)
				local d = enemy.health / qdamage
				if (best == nil) or d < damage then
					best = enemy
					damage = d
				end				
			end
		end	
		if best then
			mTarget = best
		end
	end
end

function ComboCheck()
	if QAble and WAble and EAble and RAble then
		return true
	else 
		return false
	end
end

function Combo()
	if mTarget and ValidTarget(mTarget, 700) and ComboCheck() then 
		CastSpell(_E, mTarget)
	end
	if HasAmp(mTarget) and ValidTarget(mTarget, 400) then
		CastSpell(_W, mTarget)
		CastSpell(_R)
	end
	if not EAble and not WAble and not RAble and Orbwalk:CanMove() and (not Orbwalk:CanAttack()) and ValidTarget(mTarget, 275) then
		CastSpell(_Q)
		Orbwalk:ResetAA()
	end	
end
    
function Harass()
	if mTarget and ValidTarget(mTarget, 700) and EAble and QAble and WAble then 
		CastSpell(_E, mTarget)
	end
	if mTarget and HasAmp(mTarget) and ValidTarget(mTarget, 400) then
		CastSpell(_W, mTarget)
	end
	if not EAble and not WAble and ValidTarget(mTarget, 275) then
		Orbwalk:RegisterAfterAttackCallback(function() CastSpell(_Q) end)
		Orbwalk:ResetAA()
	end	
end
	
function HasAmp(target)
	assert(type(target) == 'userdata', "HasAmp: Wrong type. Expected userdata got: "..tostring(type(target)))
	for i = 1, target.buffCount do
		tBuff = target:getBuff(i)
		if BuffIsValid(tBuff) and tBuff.name == "talondamageamp" then
			return true
		end	
	end
	return false
end
  
