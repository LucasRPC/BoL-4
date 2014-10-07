class 'Plugin'
if myHero.charName ~= "Lucian" or not VIP_USER then return end


local Target
local QAble, WAble, EAble, RAble = false, false, false, false
local LastCull, CullingAngle = 0, nil
local enemyMinions = nil
local LucianHasPassive = false

local AGCLIST = {
	["Aatrox"] = {gcName = "AatroxQ"},
	["Ahri"] = {gcName = "AhriTumble"},
	["Alistar"] = {gcName = "Headbutt"},
	["Corki"] = {gcName = "CarpetBomb"},
	["Diana"] = {gcName = "DianaTeleport"},
	["Ezreal"] = {gcName = "EzrealArcaneShift"},
	["Fiora"] = {gcName = "FioraQ"},
	["Fizz"] = {gcName = "FizzPiercingStrike"},
	["Gnar"] = {gcName = "GnarE", "gnarbige"},
	["Gragas"] = {gcName = "GragasE"},
	["Graves"] = {gcName = "GravesMove"},
	["Hecarim"] = {gcName = "HecarimUlt"},
	["Irelia"] = {gcName = "IreliaGatotsu"},
	["JarvanIV"] = {gcName = "JarvanIVDragonStrike"},
	["Jax"] = {gcName = "JaxLeapStrike"},
	["Khazix"] = {gcName = "KhazixE"},
	["Leblanc"] = {gcName = "LeblancSlide", "LeblancSlideM"},
	["LeeSin"] = {gcName = "blindmonkqtwodash"},
	["Leona"] = {gcName = "LeonaZenithBlade"},
	["Lucian"] = {gcName = "LucianE"},
	["Maokai"] = {gcName = "MaokaiUnstableGrowth"},
	["MonkeyKing"] = {gcName = "MonkeyKingNimbus"},
	["Nautilus"] = {gcName = "NautilusAnchorDrag"},
	["Nidalee"] = {gcName = "Pounce"},
	["Pantheon"] = {gcName = "PantheonW"},
	["Poppy"] = {gcName = "PoppyHeroicCharge"},
	["Quinn"] = {gcName = "QuinnE", "QuinnValorE"},
	["Renekton"] = {gcName = "RenektonSliceAndDice"},
	["Riven"] = {gcName = "RivenTriCleave"},
	["Sejuani"] = {gcName = "SejuaniArcticAssault"},
	["Shen"] = {gcName = "ShenShadowDash"},
	["Thresh"] = {gcName = "threshqleap"},
	["Tristana"] = {gcName = "RocketJump"},
	["Tryndamere"] = {gcName = "slashCast"},
	["Vi"] = {gcName = "ViQ"},
	["Volibear"] = {gcName = "VolibearQ"},
	["XinZhao"] = {gcName = "XenZhaoSweep"},
	["Yasuo"] = {gcName = "YasuoDashWrapper"},
	["Zac"] = {gcName = "ZacE"},
}
local AGCTABLE = {
	["summonerflash"] = true,
}
function MakeAGCTable()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if AGCLIST[enemy.charName] then
			AGCTABLE[AGCLIST[enemy.charName].gcName] = true
		end			
	end
end

function Plugin:__init()
require "VPrediction"

VP = VPrediction()
MakeAGCTable()
AutoCarry.Crosshair:SetSkillCrosshairRange(1400)
AutoCarry.Data:AddResetSpell("LucianE")
AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
AdvancedCallback:bind('OnLoseBuff', function(unit, buff) OnLoseBuff(unit, buff) end)
AdvancedCallback:bind('OnDash', function(unit, dash) OnDash(unit, dash) end)
end

function Plugin:OnTick()
	Checks()
	enemyMinions = AutoCarry.Minions.EnemyMinions
	Target = AutoCarry.Crosshair:GetTarget()
	
	if AutoCarry.Keys.AutoCarry and Menu.manamanager.minMAC < myManaPct() then
		ArdentBlaze()
		PiercingLight()
	elseif AutoCarry.Keys.MixedMode and Menu.manamanager.minMMM < myManaPct() then
		PiercingLight()
	elseif AutoCarry.Keys.LaneClear and Menu.manamanager.minMLC < myManaPct() then
		if Menu.qSub.focusHeroes then
			if Target and ValidTarget(Target) then
				PiercingLight()
			else
				LaneClearTarget()
			end
		else
			LaneClearTarget()
		end		
	end	
		
	if Menu.eSub.packetE then 
		RelentlessPursuit()
	end
		
	if Menu.rSub.kill then
		TheCulling()
	end	
end

function Plugin:OnDraw()
	if myHero.dead then return end	
		
	if Menu.eSub.drawejump and EAble then 
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 440, 3, ARGB(100, 25, 25, 195))
	end
end

function Plugin:OnProcessSpell(unit, spell)
	if Menu.eSub.AGConoff and EAble and AGCTABLE[spell.name] and unit.team ~= myHero.team and Menu.eSub.listSub[unit.charName] then
		local dist = GetShortestDistanceFromLineSegment(Vector(unit.x, unit.z), Vector(spell.endPos.x, spell.endPos.z), Vector(myHero.x, myHero.z))
		if dist < 250 then
			local ewallcheck = Vector(myHero.x, myHero.y, myHero.z) + Vector(Vector(myHero.x, myHero.y, myHero.z) - Vector(unit.x, unit.y, unit.z)):normalized()*400		
			if not IsWall(D3DXVECTOR3(ewallcheck.x, ewallcheck.y, ewallcheck.z)) then
				if unit then 
					local CastPosition = Vector(myHero) + Vector(Vector(myHero) - Vector(unit)):normalized()*400
					if CastPosition then
						Packet("S_CAST", { spellId = _E, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send()
					end
				else
					local CastPosition = Vector(myHero) + Vector(Vector(myHero) - Vector(spell.endPos)):normalized()*400
					if CastPosition then
						Packet("S_CAST", { spellId = _E, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send()
					end
				end
			end
		end
	end
	
	if unit.isMe and spell.name == "LucianPassiveAttack" then
		LucianHasPassive = false
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == "lucianpassivebuff" then
		LucianHasPassive = true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == "lucianpassivebuff" then
		LucianHasPassive = false
	end
end

function OnDash(unit, dash)
	if unit.isMe then
		LucianHasPassive = true
	end
end

function PiercingLight()
	if not QAble then return end
	if Target and ValidTarget(Target, 640) then
		if not Target.dead and not LucianHasPassive and AutoCarry.Orbwalker:IsAfterAttack() then
			Packet("S_CAST", { spellId = _Q, targetNetworkId = Target.networkID }):send()
		end
	elseif Target and GetDistanceSqr(Target) > 422500 and ValidTarget(Target, 1100) then		
		for i, minion in ipairs(enemyMinions.objects) do
			if minion and GetDistanceSqr(minion) < 360000 then
				local QEndPos = Vector(myHero) + Vector(Vector(minion) - Vector(myHero)):normalized()*1100
				if QEndPos then	
					for i=1, heroManager.iCount do
						currentEnemy = heroManager:GetHero(i)
						local dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(QEndPos.x, QEndPos.z), Vector(Target.x, Target.z))
						if currentEnemy.team ~= myHero.team and not currentEnemy.dead and dist < 25 then
							Packet("S_CAST", { spellId = _Q, targetNetworkId = minion.networkID }):send()
						end
					end
				end
			end
		end
	end
end

function ArdentBlaze()
	if Target and ValidTarget(Target, 1000) then
		if WAble and not Target.dead then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.2, 50, 1000, 1200, myHero)
			if CastPosition and HitChance >= 1 and not LucianHasPassive and AutoCarry.Orbwalker:IsAfterAttack() then
				if not VP:CheckMinionCollision(Target, Target, 0.1, 50, 1000, 1200, myHero, false, true) then
					Packet("S_CAST", { spellId = _W, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send()
				end
			end
		end
	end
end

function RelentlessPursuit()
	if EAble then 
		local ewallcheck = Vector(myHero.x, myHero.y, myHero.z) + Vector(Vector(mousePos.x, mousePos.y, mousePos.z) - Vector(myHero.x, myHero.y, myHero.z)):normalized()*440			
		if ewallcheck and not IsWall(D3DXVECTOR3(ewallcheck.x, ewallcheck.y, ewallcheck.z)) then	
			Packet("S_CAST", { spellId = _E, toX = mousePos.x, toY = mousePos.z, fromX = mousePos.x, fromY = mousePos.z }):send()
		end
	end	
end

function TheCulling()
	if RAble and Target and ValidTarget(Target, 1350) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.2, 50, 1200, 2000, myHero)
		local YoumuuSlot = GetInventorySlotItem(3142)
		if CastPosition and (LastCull+10000) < GetTickCount() then
			CullingAngle = Vector(Vector(myHero.x, 0, myHero.z) - Vector(CastPosition.x, 0, CastPosition.z)):normalized()
			Packet("S_CAST", { spellId = _R, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send()
			if GetInventoryItemIsCastable(3142) then
				DelayAction(function() Packet("S_CAST", { spellId = YoumuuSlot }):send() end, 0.1)
			end
			LastCull = GetTickCount()
		end	
		local movePos = Vector(Target.x, 0, Target.z) + CullingAngle*(GetDistance(Target, mousePos))
		Packet('S_MOVE',{x = movePos.x, y = movePos.z}):send()		 
	end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
end

function LaneClearTarget()
	if QAble then		
		for i=1, 5 do
			if enemyMinions.objects[i] and GetDistanceSqr(enemyMinions.objects[i]) < 360000 then
				local QEndPos = Vector(myHero) + Vector(Vector(enemyMinions.objects[i]) - Vector(myHero)):normalized()*1100
				if QEndPos and LaneClearHit(QEndPos) then	
					Packet("S_CAST", { spellId = _Q, targetNetworkId = enemyMinions.objects[i].networkID }):send()
				end
			end
		end
	end
end

function LaneClearHit(pos)
	local n = 0
	for i=1, #enemyMinions.objects do
		local dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(pos.x, pos.z), Vector(enemyMinions.objects[i].x, enemyMinions.objects[i].z))
		if dist <= 80 then
			n = n + 1
			if n >= Menu.qSub.minMinions then					
				return true
			end
		end
	end
	return false
end

function GetShortestDistanceFromLineSegment(v1, v2, v3)
	local a = math.rad(Vector(v1):angleBetween(Vector(v3), Vector(v2)))		
	local d
	if a < 1.04 then 
		if GetDistanceSqr(v1, v2) > GetDistanceSqr(v1, v3) then
			d = math.abs(math.sin(a)*(GetDistance(v1, v3))/math.cos(a))
		else
			d = GetDistance(v2, v3)
		end
	else	
		d = 716103
	end
	return d
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

Menu = AutoCarry.Plugins:RegisterPlugin(Plugin(), "Lucian")
Menu:addSubMenu("Mana Manager", "manamanager")
	Menu.manamanager:addParam("minMAC", "AutoCarry Mana Manager %", SCRIPT_PARAM_SLICE, 10, 0, 100)	
	Menu.manamanager:addParam("minMMM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
	Menu.manamanager:addParam("minMLC", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
Menu:addSubMenu("Piercing Light", "qSub")
	Menu.qSub:addParam("qautocc", "AutoQ on CC", SCRIPT_PARAM_ONOFF, true)
	Menu.qSub:addParam("minMinions", "Min. Minions - Q LaneClear(0=OFF)", SCRIPT_PARAM_SLICE, 3, 0, 6)
	Menu.qSub:addParam("focusHeroes", "Focus Heroes over Minions(LaneClear)", SCRIPT_PARAM_ONOFF, true)
Menu:addSubMenu("Ardent Blaze", "wSub")
	Menu.wSub:addParam("wautocc", "AutoW on CC", SCRIPT_PARAM_ONOFF, true)
Menu:addSubMenu("Relentless Pursuit", "eSub")
	Menu.eSub:addParam("packetE", "Packet Cast E", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
	Menu.eSub:addParam("drawejump", "Draw E Jump Range", SCRIPT_PARAM_ONOFF, true)
	Menu.eSub:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)
	Menu.eSub:addSubMenu("Use AntiGapClose on:", "listSub")
		for _, enemy in ipairs(GetEnemyHeroes()) do
			Menu.eSub.listSub:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end		
Menu:addSubMenu("The Culling", "rSub")
	Menu.rSub:addParam("kill", "Lock R on Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
