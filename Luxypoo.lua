if myHero.charName ~= "Lux" then return end

require "SourceLib"
require "VPrediction"

--/////////////////////////////////////////////////////////////////////////////AUTOUPDATE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
local sversion = "1.01"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/PewPewPew2/BoL/Danger-Meter/Luxypoo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Luxypoo.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF6600\">[Luxypoo!]</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/PewPewPew2/BoL/Danger-Meter/Luxypoo.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(sversion) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..sversion.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("Script loaded.  You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

--/////////////////////////////////////////////////////////////////////////////VARIABLES\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
local Prodiction, ProdictionQ, ProdictionE, ProdictionR, VP
local QTarget, Qinfo, ETarget, Einfo, RTarget, Rinfo, ksDmg
local lastQCast, lastAA = 0, 0
local orbActive
local mTarget, sxTarget = nil
local TS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
local ultPos 
local onDqCollcolor = ARGB(100, 124, 4, 4)
local hCollision = {}
local Config = nil
local isRecalling = false
local jungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
local enemyMinions = minionManager(MINION_ENEMY, 1500, myHero, MINION_SORT_HEALTH_ASC)
local SpellData = { 
	[_Q] = {
		name = "LuxLightBinding",
		ready = false,
		range = 1150,
		rangeSqr = math.pow(1175, 2),
		width = 80,
		speed = 1175,
		delay = 0.25
	},
	
	[_E] = {
		name = "LuxLightStrikeKugel",
		ready = false,
		range = 1100,
		rangeSqr = math.pow(1000, 2),
		width = 275,
		speed = 1300,
		delay = 0.15,
		lastCast = 0
	},
	
	[_R] = {
		name = "LuxMaliceCannon",
		ready = false,
		range = 3340,
		rangeSqr = math.pow(3340, 2),
		width = 190,
		widthHlf = 95,
		speed = math.huge,
		delay = 0.7
	},
}

--/////////////////////////////////////////////////////////////////////////////SETUP\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function OnLoad()
	VP = VPrediction()
	Menu()
	Loaded = true
end

function Menu()
Config = scriptConfig("Luxypoo v"..sversion.."", "Luxypoo v"..sversion.."")
orbConfig = scriptConfig("Luxpoo Orbwalker", "Luxypoo Orbwalker")

Config:addParam("usepro", "Use Prodiction (Requires Reload)", SCRIPT_PARAM_ONOFF, false)

--Chain CC
Config:addSubMenu("Chain CC", "chainSub")	
	Config.chainSub:addParam("useQchain", "Use Q", SCRIPT_PARAM_ONOFF, true)
	
--Hitchances
Config:addSubMenu("Hit Chances", "hitSub")
if (not Config.usepro) then
	Config.hitSub:addParam("qChance", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
end
if Config.usepro then
	Config.hitSub:addParam("qChance", "Q - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
end
if (not Config.usepro) then
	Config.hitSub:addParam("eChance", "E - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
end
if Config.usepro then
	Config.hitSub:addParam("eChance", "E - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
end
if (not Config.usepro) then
	Config.hitSub:addParam("rChance", "R - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
end
if Config.usepro then
	Config.hitSub:addParam("rChance", "R - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
end
	
-- AutoCarry options
Config:addSubMenu("AutoCarry Options", "ComboSub")
	Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)	
	Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)
	
-- MixedMode options
Config:addSubMenu("MixedMode Options", "HarassSub")
	Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)	
	Config.HarassSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 40, 0, 100)

-- Ultimate Options
Config:addSubMenu("Final Spark Options", "UltSub")
	Config.UltSub:addParam("useautoR", "Cast R if can hit X", SCRIPT_PARAM_ONOFF, true)	
	Config.UltSub:addParam("count", "X = ", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
	Config.UltSub:addParam("forceR", "Force R on Target:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	Config.UltSub:addParam("", "Will wait for bind if Combo is active, if", SCRIPT_PARAM_INFO, "")
	Config.UltSub:addParam("", "used alone will ult when hitchance is met.", SCRIPT_PARAM_INFO, "")			

-- Jungle
Config:addSubMenu("Jungle Clear", "JungleSub")
	Config.JungleSub:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Config.JungleSub:addParam("useQjclear", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.JungleSub:addParam("useEjclear", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.JungleSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)

-- LaneClear/LastHit
Config:addSubMenu("Lane Clear", "LClearSub")
	Config.LClearSub:addParam("useElclear", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.LClearSub:addParam("minM", "Required Mana % - LaneClear", SCRIPT_PARAM_SLICE, 0, 0, 100)

-- KS
Config:addSubMenu("Kill Secure", "KS")
	Config.KS:addParam("active", "Kill Secure On/Off", SCRIPT_PARAM_ONOFF, true) 
	Config.KS:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)	
	Config.KS:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)	

-- Target Selection
Config:addSubMenu("Target Options", "sts")
	Config.sts:addParam("stsRange", "Target Selection Range", SCRIPT_PARAM_SLICE, 3340, 0, 3340, 0)
	Config.sts:addParam("drawTarget", "Draw Target Collision", SCRIPT_PARAM_ONOFF, true)
	TS:AddToMenu(Config.sts)
	
-- Orbwalkers
orbConfig:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SaC", "MMA", "SxOrbWalk" })	
	if orbConfig.orbchoice == 1 then
		require "SOW"
		Orbwalker = SOW(VP)
		Orbwalker:LoadToMenu(orbConfig)
	end
	if orbConfig.orbchoice == 4 then
		require "SxOrbWalk"
		SxOrb = SxOrbWalk()
		SxOrb:LoadToMenu(orbConfig)
	end
	if Config.usepro then
		require "Prodiction"
		Prodiction = ProdictManager.GetInstance()
		ProdictionQ = Prodiction:AddProdictionObject(_Q, SpellData[_Q].range, SpellData[_Q].speed, SpellData[_Q].delay, SpellData[_R].width)
		ProdictionE = Prodiction:AddProdictionObject(_E, SpellData[_E].range, SpellData[_E].speed, SpellData[_E].delay, (SpellData[_E].width * 2))
		ProdictionR = Prodiction:AddProdictionObject(_R, SpellData[_R].range, SpellData[_R].speed, SpellData[_R].delay, SpellData[_R].width)
	end
end

function OnTick()
	if Loaded then
		enemyMinions:update()
		KillSteal()
		Checks()	
		CastCC()
		
		if ActivateE(myHero) and SpellData[_E].ready then
			ReactivateE()
		end
------------------------AUTOCARRY------------------------
		if orbConfig.Mode0 or _G.MMA_Orbwalker or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (SxOrb and SxOrb.SxOrbMenu.Keys.Fight) then
			Combo()
			if Config.UltSub.forceR and (not IsKeyDown(17)) then
				ForceR()
			end
------------------------MIXEDMODE------------------------		
		elseif orbConfig.Mode1 or _G.MMA_HybridMode or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass) 
		and myManaPct() > Config.HarassSub.minM then
			Harass()
------------------------LANECLEAR------------------------		
		elseif orbConfig.Mode2 or _G.MMA_LaneClear or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.LaneClear) or (SxOrb and SxOrb.SxOrbMenu.Keys.LaneClear) then
			LaneClear()
		end
			
		if Config.UltSub.useautoR and SpellData[_R].ready then
			AutoUlt()
		end

		if Config.JungleSub.jclr then
			jungleMinions:update()	
			JungleClear()
		end		
				
		if Config.UltSub.forceR and ((orbConfig.Enabled and not orbConfig.Mode0) or (_G.MMA and not _G.MMA_Orbwalker) or (_G.AutoCarry and not _G.AutoCarry.Keys.AutoCarry) 
		or (SxOrb and not SxOrb.SxOrbMenu.Keys.Fight)) and (not IsKeyDown(17)) then
			ForceRUnbinded()
		end		
	end
end

function Checks()
	SpellData[_Q].ready = (myHero:CanUseSpell(_Q) == READY)
	SpellData[_E].ready = (myHero:CanUseSpell(_E) == READY)
	SpellData[_R].ready = (myHero:CanUseSpell(_R) == READY)

--/////////////////////////////////////////////////////////////////////////////SAC\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
	if orbConfig.orbchoice == 2 and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Skills_Crosshair 
	and _G.AutoCarry.Crosshair.Skills_Crosshair.target then
		if _G.AutoCarry.Crosshair.Skills_Crosshair.range ~= Config.sts.stsRange then
			_G.AutoCarry.Crosshair:SetSkillCrosshairRange(Config.sts.stsRange)
		elseif _G.AutoCarry.Crosshair.Skills_Crosshair.target.type == myHero.type then 		
			mTarget = _G.AutoCarry.Crosshair.Skills_Crosshair.target
		end
--/////////////////////////////////////////////////////////////////////////////MMA\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 3 and _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
		mTarget = _G.MMA_Target	
--/////////////////////////////////////////////////////////////////////////////SxOrbwalk\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 4 and SxOrb then
		sxTarget = SxOrb:GetTarget()
		if SxOrb.OverRideRange ~= Config.sts.stsRange then
			SxOrb:ChangeRange(Config.sts.stsRange)
		elseif sxTarget and sxTarget.type == myHero.type then
			mTarget = sxTarget
		end
--/////////////////////////////////////////////////////////////////////////////SOW\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 1 and Orbwalker then
		mTarget = Orbwalker:GetTarget(true)
	end
	
	if mTarget == nil then
		mTarget = TS:GetTarget(Config.sts.stsRange) 
	end
end	

function ActivateE(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "LuxLightStrikeKugel")
	end
end

function OnDraw()
	if myHero.dead then return end	
				
	if mTarget and (not mTarget.dead) and ValidTarget(mTarget, SpellData[_R].range) and Config.sts.drawTarget then
		DrawLine3D(myHero.x, myHero.y, myHero.z, mTarget.x, mTarget.y, mTarget.z, 1, onDqCollcolor)
		DrawLineBorder3D(myHero.x, myHero.y, myHero.z, mTarget.x, mTarget.y, mTarget.z, 80, onDqCollcolor, 8)	
	end
end

--/////////////////////////////////////////////////////////////////////////////CONTROL\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function JungleClear() 
	for i, jungleMinion in pairs(jungleMinions.objects) do 
		if jungleMinion ~= nil then	
			if Config.usepro then
				QTarget, Qinfo = ProdictionQ:GetPrediction(jungleMinion)
				ETarget, Einfo = ProdictionE:GetPrediction(jungleMinion)
			elseif (not Config.usepro) then
				QTarget, Qinfo = VP:GetLineCastPosition(jungleMinion, SpellData[_Q].delay, SpellData[_Q].width, SpellData[_Q].range, SpellData[_Q].speed, myHero)	
				ETarget, Einfo = VP:GetLineCastPosition(jungleMinion, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
			end	
			
			if QTarget and Config.JungleSub.useQjclear and SpellData[_Q].ready and ValidTarget(jungleMinion, SpellData[_Q].range) and myManaPct() > Config.JungleSub.minM 
			and (not MinPassive(jungleMinion)) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
	
			if ETarget and Config.JungleSub.useEjclear and SpellData[_E].ready and ValidTarget(jungleMinion, SpellData[_E].range) and myManaPct() > Config.JungleSub.minM 
			and (not MinPassive(jungleMinion)) then
				local jObj = CountObjectsNearPos(Vector(jungleMinion), nil, SpellData[_E].width, jungleMinions.objects)
				local jtObj = CountObjectsNearPos(Vector(jungleMinion), nil, 600, jungleMinions.objects)
				if jObj == jtObj then
					CastSpell(_E, ETarget.x, ETarget.z)
				end
			end
		end
	end
end

function ForceR()
	if SpellData[_R].ready and mTarget and IsOnCC(mTarget) then
		CastSpell(_R, mTarget.x, mTarget.z)
  end
end 

function ForceRUnbinded() --ADD HITCHANCE
	if Config.usepro and mTarget then
		RTarget, Rinfo = ProdictionR:GetPrediction(mTarget)
	elseif (not Config.usepro) and mTarget then
		RTarget, Rinfo = VP:GetLineCastPosition(mTarget, SpellData[_R].delay, SpellData[_R].width, SpellData[_R].range, SpellData[_R].speed, myHero)
	end	
	
	if SpellData[_R].ready and mTarget and ValidTarget(mTarget, SpellData[_R].range) and RTarget then --ADD HITCHANCE
		CastSpell(_R, RTarget.x, RTarget.z)
  end
end 

function LaneClear() 
	for i, enemyMinion in pairs(enemyMinions.objects) do
		if enemyMinion ~= nil then
			if Config.usepro then
				ETarget, Einfo = ProdictionE:GetPrediction(enemyMinion)
			elseif (not Config.usepro) then	
				ETarget, Einfo = VP:GetLineCastPosition(enemyMinion, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
			end			
			
			if Config.LClearSub.useElclear and SpellData[_E].ready and ValidTarget(enemyMinion, SpellData[_E].range) and myManaPct() > Config.LClearSub.minM then
				local eObj = CountObjectsNearPos(enemyMinion, nil, SpellData[_E].width, enemyMinions.objects)
				local tObj = CountObjectsNearPos(enemyMinion, nil, 800, enemyMinions.objects)	
				
				if ETarget and eObj >= tObj*0.60 and eObj > 2 then
					CastSpell(_E, ETarget.x, ETarget.z)	
				end
			end
		end
	end
end

function Combo()
	if mTarget and mTarget.type == myHero.type and myManaPct() > Config.ComboSub.minM then
		CastSpellQ(mTarget)
		CastSpellE(mTarget)
	end
end

function Harass()
	if mTarget and mTarget.type == myHero.type and myManaPct() > Config.HarassSub.minM then
		CastSpellE(mTarget)
	end
end

function CastSpellQ(target)	
	if SpellData[_Q].ready then
		if Config.usepro then
			 QTarget, Qinfo = ProdictionQ:GetPrediction(target)
		elseif (not Config.usepro) then
			 QTarget, Qinfo = VP:GetLineCastPosition(target, SpellData[_Q].delay, SpellData[_Q].width, SpellData[_Q].range, SpellData[_Q].speed, myHero)	
		end

		if Config.usepro and QTarget and Qinfo and Qinfo.hitchance >= Config.hitSub.qChance and GetMinionCollision(myHero, QTarget) then
			onDqCollcolor = ARGB(100, 124, 4, 4)
			CastSpell(_Q, QTarget.x, QTarget.z) 
			lastQCast = GetTickCount()
		elseif (not Config.usepro) and Qinfo and Qinfo >= Config.hitSub.qChance and GetMinionCollision(myHero, QTarget) then
			onDqCollcolor = ARGB(100, 124, 4, 4)
			CastSpell(_Q, QTarget.x, QTarget.z) 
			lastQCast = GetTickCount()
		else
			onDqCollcolor = ARGB(100, 35, 250, 11)
		end
	end
end

function CastSpellE(target)

	if SpellData[_E].ready and IsOnCC(target) and ((SpellData[_E].lastCast + 5000) <= GetTickCount() or SpellData[_E].lastCast == 0) then
		CastSpell(_E, target.x, target.z)
	elseif SpellData[_E].ready and (((SpellData[_E].lastCast + 5000) < GetTickCount()) or SpellData[_E].lastCast == 0) and (not SpellData[_Q].ready) 
	and ((lastQCast + 1000) < GetTickCount() or lastQCast == 0) then
		if Config.usepro then
			ETarget, Einfo = ProdictionE:GetPrediction(target)
		elseif (not Config.usepro) then
			ETarget, Einfo = VP:GetLineCastPosition(target, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
		end				
		
		if Config.usepro and ETarget and Einfo.hitchance >= Config.hitSub.eChance then
			CastSpell(_E, ETarget.x, ETarget.z)
		elseif (not Config.usepro) and Einfo >= Config.hitSub.eChance then
			CastSpell(_E, ETarget.x, ETarget.z) 
		end
	elseif SpellData[_E].ready and (((SpellData[_E].lastCast + 5000) < GetTickCount()) or SpellData[_E].lastCast == 0) and 
	(orbConfig.Mode1 or _G.MMA_HybridMode or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass)) and (not HasPassive(target)) then
		if Config.usepro then
			ETarget, Einfo = ProdictionE:GetPrediction(target)
		elseif (not Config.usepro) then
			ETarget, Einfo = VP:GetLineCastPosition(target, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
		end		
		CastSpell(_E, ETarget.x, ETarget.z)
	end
end

--/////////////////////////////////////////////////////////////////////////////AUTOMATIC\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function KillSteal() 
	if IsRecalling(myHero) then
		isRecalling = true
	elseif (not IsRecalling(myHero)) then
		isRecalling = false
	end
	
	if isRecalling or (not Config.KS.active) then return end
		
	for _,enemy in pairs(GetEnemyHeroes()) do
		ksDmg = GetTotalDmg(enemy)
		
		if ValidTarget(enemy, SpellData[_E].range) and ksDmg.total > enemy.health and GetDistanceSqr(myHero, enemy) < SpellData[_E].rangeSqr then	
			if Config.KS.useE and SpellData[_E].ready and ksDmg.E > enemy.health then
				if Config.usepro then
					ETarget, Einfo = ProdictionE:GetPrediction(enemy)
					if Einfo.hitchance >= Config.hitSub.eChance then
						CastSpell(_E, ETarget.x, ETarget.z)
					end
				elseif (not Config.usepro)	then
					ETarget, Einfo = VP:GetLineCastPosition(enemy, SpellData[_E].delay, SpellData[_E].width, SpellData[_E].range, SpellData[_E].speed, myHero)
					if Einfo >= Config.hitSub.eChance then
						CastSpell(_E, ETarget.x, ETarget.z) 
					end			
				end							
			elseif Config.KS.useR and ksDmg.R > enemy.health and ksDmg.E < enemy.health then
				if Config.usepro and Rinfo.hitchance >= Config.hitSub.rChance then
					RTarget, Rinfo = ProdictionR:GetPrediction(enemy)
					if Rinfo.hitchance >= Config.hitSub.rChance then
						CastSpell(_R, RTarget.x, RTarget.z)
					end
				elseif (not Config.usepro) then
					RTarget, Rinfo = VP:GetLineCastPosition(enemy, SpellData[_R].delay, SpellData[_R].width, SpellData[_R].range, SpellData[_R].speed, myHero)
					if Rinfo >= Config.hitSub.rChance then
						CastSpell(_R, RTarget.x, RTarget.z) 
					end
				end				
			end	
		elseif Config.KS.useR and ValidTarget(enemy, SpellData[_R].range) and ksDmg.R > enemy.health and GetDistanceSqr(enemy) > SpellData[_E].rangeSqr then
			if Config.usepro then
				RTarget, Rinfo = ProdictionR:GetPrediction(enemy)
				if Rinfo.hitchance >= Config.hitSub.rChance then
					CastSpell(_R, RTarget.x, RTarget.z)
				end 
			elseif (not Config.usepro) then
				RTarget, Rinfo = VP:GetLineCastPosition(enemy, SpellData[_R].delay, SpellData[_R].width, SpellData[_R].range, SpellData[_R].speed, myHero)
				if Rinfo >= Config.hitSub.rChance then
					CastSpell(_R, RTarget.x, RTarget.z) 
				end 
			end
		end
	end
end

function OnCreateObj(object)
	if object.name:find("LuxLightstrike_tar_green") then
		orbActive = object
	elseif object.name:find("LuxBlitz_nova") then
		orbActive = nil
	end
end		
		
function OnDeleteObj(object)
	if object.name:find("LuxBlitz_nova") then
		orbActive = nil
	end
end

function ReactivateE()
	--if mTarget and orbActive and ((not HasPassive(mTarget)) or ((lastAA + (GetDistance(myHero, mTarget) / 900) + 525) < GetTickCount())) then	
	--	CastSpell(_E)
	--elseif mTarget and HasPassive(mTarget) and orbActive and GetDistanceSqr(myHero, orbActive) > SpellData[_E].rangeSqr then
	--	CastSpell(_E)
	--elseif (not mTarget) and orbActive then
	--	CastSpell(_E)
	--end	
	
	if mTarget and IsOnCC(mTarget) and orbActive and ((not HasPassive(mTarget)) or ((lastAA + (GetDistance(myHero, mTarget) / 900) + 525) < GetTickCount())) then
		CastSpell(_E)
	elseif mTarget and orbActive and GetDistance(mTarget, orbActive) < 275 then 
		CastSpell(_E)
	end
	
end

function AutoUlt()
	if IsRecalling(myHero) then
		isRecalling = true
	elseif (not IsRecalling(myHero)) then
		isRecalling = false
	end
	
	if isRecalling or (not Config.UltSub.useautoR) then return end

	if mTarget then
	ultPos = GenerateLineSegmentFromCastPosition(myHero, mTarget, SpellData[_R].range)
	local ultCount = GetHeroCollision(myHero, ultPos)
		if ultCount then
			CastSpell(_R, mTarget.x, mTarget.z)
			--print("autoult - "..#hCollision.."")
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "LuxLightStrikeKugel" then
		SpellData[_E].lastCast = GetTickCount()
		lastAA = (GetTickCount() + 5000)
	end
	
	if unit.isMe and orbActive and (spell.name == "LuxBasicAttack" or spell.name == "LuxBasicAttack2") then
		lastAA = GetTickCount()
	end
end

--[[--CHAINCC--
Chain CC support for: AmumuQ&R, Elise, J4, Jax, Nautilus, Pantheon, Warwick, Udyr, Vi, Ahri, Anivia, Lissandra, Sion, Syndra, Swain, Viktor, Vel'Koz, Veigar, TwistedFate, Xerath, Yasuo, Blitzcrank,
 BraumP&R, Karma, LeonaQ&R, Morganna, Nami, Taric, Thresh, Zyra, Alistar, Brand, Aatrox, Cho'Gath, Irelia, Maokai, Shen, Ryze, SejuaniR Riven, Renekton, Janna, Gragas, Rammus]]

local CCBUFFS = {
	["aatroxqknockup"] = true,
	["ahriseducedoom"] = true,
	["powerfistslow"] = true,
	["caitlynyordletrapdebuff"] = true,
	["braumstundebuff"] = true,
	["rupturetarget"] = true,
	["EliseHumanE"] = true,
	["Flee"] = true,
	["HowlingGaleSpell"] = true,
	["jarvanivdragonstrikeph2"] = true,
	["karmaspiritbindroot"] = true,	
	["LuxLightBindingMis"] = true,
	["lissandrawfrozen"] = true,
	["maokaiunstablegrowthroot"] = true,
	["DarkBindingMissile"] = true,
	["namiqdebuff"] = true,
	["nautilusanchordragroot"] = true,
	["RunePrison"] = true,
	["Taunt"] = true,
	["Stun"] = true,
	["swainshadowgrasproot"] = true,
	["threshqfakeknockup"] = true,
	["velkozestun"] = true,
	["virdunkstun"] = true,
	["viktorgravitonfieldstun"] = true,
	["supression"] = true,
	["yasuoq3mis"] = true,
	["zyragraspingrootshold"] = true,
	["CurseoftheSadMummy"] = true,
	["braumpulselineknockup"] = true,
	["lissandraenemy2"] = true,
	["sejuaniglacialprison"] = true,
	["SonaR"] = true,
	["zyrabramblezoneknockup"] = true,
}

function CastCC()
	if Config.chainSub.useQchain and mTarget and SpellData[_Q].ready and ValidTarget(mTarget, SpellData[_Q].range) and GetMinionCollision(myHero, mTarget) and IsOnCC(mTarget) then
		CastSpell(_Q, mTarget.x, mTarget.z)
	end
end

function IsOnCC(target)
	assert(type(target) == 'userdata', "IsOnCC: Wrong type. Expected userdata got: "..tostring(type(target)))
	for i = 1, target.buffCount do
		tBuff = target:getBuff(i)
		if BuffIsValid(tBuff) and CCBUFFS[tBuff.name] then
			return true
		end	
	end
	return false
end

--/////////////////////////////////////////////////////////////////////////////COLLISION\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function GenerateLineSegmentFromCastPosition(CastPosition, FromPosition, SkillShotRange) --From LineSkillShotPosition.lua by dienofail
    local MaxEndPosition = CastPosition + (-1 * (Vector(CastPosition.x - FromPosition.x, 0, CastPosition.z - FromPosition.z):normalized()*SkillShotRange))
    return MaxEndPosition
end	

function GetHeroCollision(pStart, pEnd) --From Collision 1.1.1 by Klokje
        hCollision = {}
		if mode == nil then mode = HERO_ENEMY end
        local heros = {}
 
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if hero.team ~= myHero.team and not hero.dead then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetDistance(pStart, pEnd)
		local prediction = VP
		
        if distance > SpellData[_R].range then
            distance = SpellData[_R].range
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x * SpellData[_R].widthHlf)
        local startLeftY = pStart.y + (y * SpellData[_R].widthHlf)
        local startLeftZ = pStart.z + (z * SpellData[_R].widthHlf)
        local endLeftX = pStart.x + (x * SpellData[_R].widthHlf) + (t * distance)
        local endLeftY = pStart.y + (y * SpellData[_R].widthHlf) + (i * distance)
        local endLeftZ = pStart.z + (z * SpellData[_R].widthHlf) + (u * distance)
       
        local startRightX = pStart.x - (x * SpellData[_R].widthHlf)
        local startRightY = pStart.y - (y * SpellData[_R].widthHlf)
        local startRightZ = pStart.z - (z * SpellData[_R].widthHlf)
        local endRightX = pStart.x - (x * SpellData[_R].widthHlf) + (t * distance)
        local endRightY = pStart.y - (y * SpellData[_R].widthHlf) + (i * distance)
        local endRightZ = pStart.z - (z * SpellData[_R].widthHlf)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
        for index, hero in pairs(heros) do
            if hero ~= nil and hero.valid and not hero.dead then
                if GetDistance(pStart, hero) < distance then
					local pos, t, vec  = prediction:GetLineCastPosition(hero, SpellData[_R].delay, SpellData[_R].width, SpellData[_R].range, SpellData[_R].speed, myHero)				
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toScreen, toPoint
                    if pos ~= nil then
                        toScreen = WorldToScreen(D3DXVECTOR3(pos.x, hero.y, pos.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    end
 
                    if poly:contains(toPoint) then
                        table.insert(hCollision, hero)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(hero)*2+10) or distance2 < (getHitBoxRadius(hero) *2+10)) then
                            table.insert(hCollision, hero)
                        end
                    end
                end
            end
        end
        if #hCollision >= Config.UltSub.count then return true, hCollision else return false, hCollision end
end

function GetMinionCollision(pStart, pEnd) --From Collision 1.1.1 by Klokje
	enemyMinions:update()
	mCollision = {} 
		
	local distance =  GetDistance(pStart, pEnd)
	local prediction = VP
	if distance > SpellData[_Q].range then
		distance = SpellData[_Q].range
	end
 
	local V = Vector(pEnd) - Vector(pStart)
	local k = V:normalized()
    local P = V:perpendicular2():normalized()
 
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
 
    local startLeftX = pStart.x + (x *SpellData[_Q].width)
    local startLeftY = pStart.y + (y *SpellData[_Q].width)
    local startLeftZ = pStart.z + (z *SpellData[_Q].width)
    local endLeftX = pStart.x + (x * SpellData[_Q].width) + (t * distance)
    local endLeftY = pStart.y + (y * SpellData[_Q].width) + (i * distance)
    local endLeftZ = pStart.z + (z * SpellData[_Q].width) + (u * distance)
     
    local startRightX = pStart.x - (x * SpellData[_Q].width)
    local startRightY = pStart.y - (y * SpellData[_Q].width)
    local startRightZ = pStart.z - (z * SpellData[_Q].width)
    local endRightX = pStart.x - (x * SpellData[_Q].width) + (t * distance)
    local endRightY = pStart.y - (y * SpellData[_Q].width) + (i * distance)
    local endRightZ = pStart.z - (z * SpellData[_Q].width)+ (u * distance)
 
    local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
    local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
    local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
    local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
      
    local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
    for index, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and minion.valid and not minion.dead then
			if GetDistance(pStart, minion) < distance then
				local pos, t, vec = prediction:GetLineCastPosition(minion, SpellData[_Q].delay, SpellData[_Q].width, SpellData[_Q].range, SpellData[_Q].speed, myHero)	
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                else
					toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
 
 
                if poly:contains(toPoint) then
					table.insert(mCollision, minion)
                else
                    if pos ~= nil then
						distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                        distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                    else
                        distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                        distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    end
                    if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
				end
			end
		end
	end
	if #mCollision <= 1 then return true, mCollision else return false, mCollision end
end

function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)/2
end

--/////////////////////////////////////////////////////////////////////////////FUNCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function IsRecalling(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "Recall")
	end
end

function HasPassive(target)	
	assert(type(target) == 'userdata', "IsOnCC: Wrong type. Expected userdata got: "..tostring(type(target)))
	for i = 1, target.buffCount do
		tBuff = target:getBuff(i)
		if tBuff.valid and BuffIsValid(tBuff) and tBuff.name == "luxilluminatingfraulein" then
			return true
		end	
	end
	return false
end

function GetTotalDmg(enemy)
	if enemy ~= nil then
		local getDamage = {}
		getDamage.E = getDmg("E", enemy, myHero) * 0.97
		getDamage.R = ((SpellData[_R].ready and getDmg("R", enemy, myHero)) or 0) * 0.97
		
		getDamage.total = (getDamage.E + getDamage.R) * 0.97
		return getDamage
	end
end

function MinPassive(unit)
	if unit ~= nil then
		return HasBuff(unit, "luxilluminatingfraulein")
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end
function PassiveDamage() return (10+(8*myHero.level)+(0.2*myHero.ap)) end
