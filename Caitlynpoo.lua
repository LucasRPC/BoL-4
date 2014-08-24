
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX OnLoad/AutoUpdate XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
if myHero.charName ~= "Caitlyn" then return end

require "VPrediction"

local QAble, WAble, EAble, RAble = false, false, false
local rDmg
local mode1active, mode2active, mode3active = false, false, false
local qCollision = 1
local rRange = nil
local trapCount = 0
local Prodiction
local aaDmg, qTotal1, qTotal2, qTotal3 = 0, 0, 0, 0
local msgTrap, msgColl = 0, 0 
local ProdictionQ
local VP = nil
local enemyMinions = minionManager(MINION_ENEMY, 1300, myHero)

local sversion = "0.31"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Caitlynpoo.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#0099FF\">[Caitlynpoo!]</font> <font color=\"#FF6600\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.version")
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

function Menu()
Config = scriptConfig("Caitlynpoo", "Caitlynpoo")
orbConfig = scriptConfig("Caitlynpoo Orbwalker", "Caitlynpoo Orbwalker")

Config:addSubMenu("Piltover Peacemaker", "qSub")
	Config.qSub:addParam("Qonoff", "AutoPeacemaker on CC", SCRIPT_PARAM_ONOFF, true)
	Config.qSub:addParam("minMinions", "Min. Minions - Q LaneClear(0=OFF)", SCRIPT_PARAM_SLICE, 6, 0, 10)
	Config.qSub:addParam("minM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
	Config.qSub:addParam("minMlc", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 25, 0, 100)
	Config.qSub:addParam("smartQ", "Q Cast Options", SCRIPT_PARAM_LIST, 1, { "SmartQ v0.2", "Toggle" })
	Config.qSub:addParam("dumbQ", "Toggle Q Hotkey", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
	Config.qSub:addParam("usepro", "Use Prodiction (Requires Reload)", SCRIPT_PARAM_ONOFF, false)
	if (not Config.qSub.usepro) then
		Config.qSub:addParam("vphit", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
	end
	if Config.qSub.usepro then
		Config.qSub:addParam("prohit", "Q - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	end
	Config.qSub:addParam("printColl", "SmartQ v0.2 [INFO]", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
Config:addSubMenu("Yordle Snap Trap", "wSub")
	Config.wSub:addParam("onoff", "AutoTrap on CC", SCRIPT_PARAM_ONOFF, true)
	Config.wSub:addParam("AGCtrap", "AntiGapClose with W if E on CD", SCRIPT_PARAM_ONOFF, true)
	Config.wSub:addParam("printCount", "Count Traps Set [INFO]", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))
Config:addSubMenu("90 Caliber Net", "eSub")
	Config.eSub:addParam("net", "E to Mouse", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
	Config.eSub:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)
Config:addSubMenu("Ace in the Hole", "rSub")
	Config.rSub:addParam("kill", "R Killshot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))

orbConfig:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SaC", "MMA", "SxOrbWalk" })	
	if orbConfig.orbchoice == 1 then
		require "SOW"
		Orbwalker = SOW(VP)
		Orbwalker:LoadToMenu(orbConfig)
		orbConfig:addParam("drawrange", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("focustarget", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
		
	end
	if orbConfig.orbchoice == 3 then
		orbConfig:addParam("orbwalk", "OrbWalker", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		orbConfig:addParam("hybrid", "HybridMode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		orbConfig:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	end
	if orbConfig.orbchoice == 4 then
		require "SxOrbWalk"
		SxOrb = SxOrbWalk()
		SxOrb:LoadToMenu(orbConfig)
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
	end
	if Config.qSub.usepro then
		require "Prodiction"
		Prodiction = ProdictManager.GetInstance()
		ProdictionQ = Prodiction:AddProdictionObject(_Q, 1300, 2200, 0.250, 80)
	end
end

function OnLoad()
	VP = VPrediction()
	Menu()	
end

function OnTick()
	Checks()
	
	if (orbConfig.orbchoice == 1 and orbConfig.Mode0) or (orbConfig.orbchoice == 3 and orbConfig.orbwalk) or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (SxOrb and SxOrb.SxOrbMenu.Keys.Fight) then
		if (not Config.qSub.usepro) then
			Peacemaker()
			mode1active = true
			mode2active = false
			mode3active = false
		elseif Config.qSub.usepro then
			PeacemakerPRO() 
			mode1active = true
			mode2active = false
			mode3active = false
		end
	elseif orbConfig.Mode1 or orbConfig.hybrid or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass) and myManaPct() > Config.qSub.minM then
		if (not Config.qSub.usepro) then
			Peacemaker()
			mode1active = false
			mode2active = true
			mode3active = false
		elseif Config.qSub.usepro then
			PeacemakerPRO()
			mode1active = false
			mode2active = true
			mode3active = false
		end
	elseif Config.qSub.minMinions ~= 0 and (orbConfig.Mode2 or orbConfig.laneclear or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.LaneClear) or (SxOrb and SxOrb.SxOrbMenu.Keys.LaneClear)) 
	and myManaPct() > Config.qSub.minMlc then
		enemyMinions:update()
		LaneClear()
		mode1active = false
		mode2active = false
		mode3active = true
	end	
		
	if Config.wSub.onoff then 
		CastW()
	end
	
	if Config.eSub.AGConoff then 
		AGCCastE()
	end
	
	if RAble then
		AceintheHole()
	end	
	
	if Config.eSub.net then
		NetToMouse()
	end
		
	if InFountain() then
		SmartQ()
	end 
	
	if Config.wSub.printCount and ((msgTrap+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[AutoTrap]</font> <font color=\"#FF6600\">Traps Set - "..trapCount..".</font>")
		msgTrap = GetTickCount()
	end
	if Config.qSub.printColl and ((msgColl+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[SmartQ v0.2]</font> <font color=\"#FF6600\">Collision with X heroes Required for SmartQ, X="..qCollision..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.2]</font> <font color=\"#FF6600\">AA DPS - "..aaDmg..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.2]</font> <font color=\"#FF6600\">Q on 1 Target DPS - "..qTotal1..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.2]</font> <font color=\"#FF6600\">Q on 2 Target DPS - "..qTotal2..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.2]</font> <font color=\"#FF6600\">Q on 3 Target DPS - "..qTotal3..".</font>")
		msgColl = GetTickCount()
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  Game Functions   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function NetToMouse() 
	if EAble and (not IsKeyDown(17)) then
		MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
		myHero:MoveTo(mousePos.x,mousePos.z)
		CastSpell(_E,DashPos.x,DashPos.z)
	end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)	
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
	
--///////////////////////////////////////////////////////////////////SAC\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
	if orbConfig.orbchoice == 2 and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Skills_Crosshair 
	and _G.AutoCarry.Crosshair.Skills_Crosshair.target and _G.AutoCarry.Crosshair.Skills_Crosshair.target.type == myHero.type then 		
			mTarget = _G.AutoCarry.Crosshair.Skills_Crosshair.target
--///////////////////////////////////////////////////////////////////MMA\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 3 and _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
		mTarget = _G.MMA_Target	
--///////////////////////////////////////////////////////////////////SxO\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 4 and SxOrb then
		sxTarget = SxOrb:GetTarget()
		if sxTarget and sxTarget.type == myHero.type then
			mTarget = sxTarget
		end
--///////////////////////////////////////////////////////////////////SOW\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 1 and Orbwalker then
		local selectedTarget = GetTarget()
		if orbConfig.focustarget and selectedTarget and ValidTarget(selectedTarget, myHero.range) and selectedTarget.type == myHero.type then
			mTarget = selectedTarget
		else
		mTarget = Orbwalker:GetTarget(true)
		end
	end
end

function OnDraw()
	if myHero.dead then return end	

	if orbConfig.orbchoice == 1 and orbConfig.drawrange and Orbwalker then
		Orbwalker:DrawAARange(3, ARGB(100, 35, 250, 11))
	end
	
	if orbConfig.orbchoice == 1 and orbConfig.drawtarget and Orbwalker and mTarget then
		DrawCircle3D(mTarget.x, mTarget.y, mTarget.z, 185, 3, ARGB(100, 185, 4, 4))
	end
end

function CheckRLevel()
        if myHero:GetSpellData(_R).level == 1 then rRange = 2000
        elseif myHero:GetSpellData(_R).level == 2 then rRange = 2500
        elseif myHero:GetSpellData(_R).level == 3 then rRange = 3000
        end
end

function AceintheHole()
    CheckRLevel()
	for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if RAble then rDmg = getDmg("R",Enemy,myHero) else rDmg = 0 end
        if ValidTarget(Enemy, rRange, true) and (Enemy.health + 60) < rDmg then
        PrintFloatText(myHero, 0, "Press R For Killshot") end
        if ValidTarget(Enemy, rRange, true) and Config.rSub.kill and (Enemy.health + 60) < rDmg then
        CastSpell(_R, Enemy) end
    end
end

function Peacemaker()
	if mTarget then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.632, 80, 1300, 2225, myHero)
		local qDmgchck = (myHero.totalDamage * 0.85)
		local QendPos = GenerateLineSegmentFromCastPosition(myHero, mTarget, 1300)
		if QAble and HitChance >= Config.qSub.vphit and GetDistanceSqr(CastPosition) < 1690000 and qDmgchck < mTarget.health 
		and ((mode1active and Config.qSub.smartQ == 1 and GetHeroCollision(myHero, QendPos) and SmarterQ(mTarget)) or (Config.qSub.smartQ ==  2 and Config.qSub.dumbQ) or mode2active) then
			if orbConfig.orbchoice == 2 and _G.AutoCarry.Orbwalker:IsAfterAttack() then			
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif orbConfig.orbchoice == 3 and _G.MMA_NextAttackAvailability > 0.1 and _G.MMA_NextAttackAvailability < 0.2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif orbConfig.orbchoice == 1 and orbConfig.Enabled and Orbwalker:CanMove() and (not Orbwalker:CanAttack()) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif orbConfig.orbchoice == 4 and mTarget.type == myHero.type and SxOrb:CanMove() and (not SxOrb:CanAttack()) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function PeacemakerPRO()
	if mTarget then
        local QTarget, Qinfo = ProdictionQ:GetPrediction(mTarget)
		local qDmgchck = (myHero.totalDamage * 0.85)
        if QAble and Qinfo.hitchance >= Config.qSub.prohit and GetDistanceSqr(QTarget) < 1690000 and qDmgchck < mTarget.health 
		and ((mode1active and Config.qSub.smartQ == 1 and GetHeroCollision(myHero, QendPos) and SmarterQ(mTarget)) or (Config.qSub.smartQ ==  2 and Config.qSub.dumbQ) or mode2active) then 
			if orbConfig.orbchoice == 2 and _G.AutoCarry.Orbwalker:IsAfterAttack() then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif orbConfig.orbchoice == 3 and _G.MMA_NextAttackAvailability > 0.1 and _G.MMA_NextAttackAvailability < 0.2 then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif orbConfig.orbchoice == 1 and orbConfig.Enabled and Orbwalker:CanMove() and (not Orbwalker:CanAttack()) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif  orbConfig.orbchoice == 4 and mTarget.type == myHero.type and SxOrb:CanMove() and (not SxOrb:CanAttack()) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
    	end
	end
end

--[[function HeadShot() --SAC MODE ONLY(not working atm)
	if HasPassive(myHero) and _G.AutoCarry.Plugins then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(PassiveDmg())
	elseif _G.AutoCarry and _G.AutoCarry.Plugins and (not HasPassive(myHero)) then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(NoPassive())
	end
end]]

function HasPassive(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "caitlynheadshot")
	end
end

function LaneClear()
	for i, enemyMinion in pairs(enemyMinions.objects) do
		if enemyMinion ~= nil then
			local QendPos = GenerateLineSegmentFromCastPosition(myHero, enemyMinion, 1300)
			if QAble and GetMinionCollision(myHero, QendPos) then
				if orbConfig.orbchoice == 2 and _G.AutoCarry.Orbwalker:IsAfterAttack() then
					CastSpell(_Q, enemyMinion.x, enemyMinion.z)
				elseif orbConfig.orbchoice == 3 and _G.MMA_AbleToMove then
					CastSpell(_Q, enemyMinion.x, enemyMinion.z)
				elseif orbConfig.orbchoice == 1 and orbConfig.Enabled and Orbwalker:CanMove() then
					CastSpell(_Q, enemyMinion.x, enemyMinion.z)
				elseif orbConfig.orbchoice == 4 and SxOrb:CanMove() then
					CastSpell(_Q, enemyMinion.x, enemyMinion.z)
				end
			end	
		end
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end
--[[function PassiveDmg() return ((_G.AutoCarry.MyHero:GetTotalAttackDamageAgainstTarget(_G.AutoCarry.Minions.EnemyMinions)) * 1.7) end
function NoPassive() return 0 end]]

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      AutoTrap     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
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
	["infiniteduresssound"] = true,
	["chronorevive"] = true,
	["katarinarsound"] = true,
	["AbsoluteZero"] = true,
	["Meditate"] = true,
	["pantheonesound"] = true,
	["zhonyasringshield"] = true,
	["fearmonger_marker"] = true,
	["AlZaharNetherGrasp"] = true,
	["missfortunebulletsound"] = true,	
	["VelkozR"] = true,	
	["monkeykingspinknockup"] = true,
	["unstoppableforceestun"] = true,
	["lissandrarself"] = true,
}

function CastW()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		if WAble and ValidTarget(Enemy, 800, true) and IsOnCC(Enemy) then
			CastSpell(_W, Enemy.x, Enemy.z)
			if Config.qSub.Qonoff then
				CastSpell(_Q, Enemy.x, Enemy.z)
			end
		end
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

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        AGC        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
local AGCSPELLS = {
	["EzrealArcaneShift"] = true,
	["AhriTumble"] = true,
	["RivenTriCleave"] = true,
	["AatroxQ"] = true,
	["GravesMove"] = true,
	["FioraQ"] = true,
	["CarpetBomb"] = true,
	["ShenShadowDash"] = true,
	["QuinnValorE"] = true,
	["QuinnE"] = true,
	["FizzPiercingStrike"] = true,
	["BlindMonkQTwo"] = true,
	["GragasE"] = true,
	["SejuaniArcticAssault"] = true,
	["RenektonSliceAndDice"] = true,
	["LeblancSlide"] = true,
	["LeblancSlideM"] = true,
	["JarvanIVDragonStrike"] = true,
	["MonkeyKingNimbus"] = true,
	["YasuoDashWrapper"] = true,
	["UFSlash"] = true,
	["DianaTeleport"] = true,
	["RocketJump"] = true,
	["HecarimUlt"] = true,
	["LeonaZenithBlade"] = true,
	["KhazixE"] = true,
	["LucianE"] = true,
	["NautilusAnchorDrag"] = true,	
	["slashCast"] = true,
	["Pounce"] = true,
	["XenZhaoSweep"] = true,
	["MaokaiUnstableGrowth"] = true,
	["PoppyHeroicCharge"] = true,
	["JaxLeapStrike"] = true,
	["PantheonW"] = true,
	["threshqleap"] = true,
	["ViQ"] = true,
	["IreliaGatotsu"] = true,
	["SummonerFlash"] = true,
	["Headbutt"] = true,
}
local AGCBUFFS = {
	["aatroxqdescent"] = true,
	["AhriTumble"] = true,
	["valkyriesound"] = true,
	["fiorqcd"] = true,
	["gravesmovesteroid"] = true,
	["LeblancSlide"] = true,
	["GragasE"] = true,
	["jarvanivdragonstrikeph"] = true,
	["blindmonkqtwodash"] = true,
	["RivenTriCleave"] = true,	
	["ShenShadowDash"] = true,
	["VolibearQ"] = true,
	["QuinnE"] = true,
	["ZacE"] = true,
	["SejuaniArcticAssault"] = true,
	["renektonsliceanddicedelay"] = true,
	["viqdash"] = true,
	["monkeykingnimbuskick"] = true,
}
local TELESPELLS = {
	["SummonerTeleport"] = true,
	["gate"] = true,
	["PantheonRFall"] = true,
	["LeblancSlide"] = true,
	["LeblancSlideM"] = true,
}

function OnProcessSpell(unit, spell)
	if Config.eSub.AGConoff and AGCSPELLS[spell.name] and unit.team ~= myHero.team and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if (not EAble) and Config.wSub.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if TELESPELLS[spell.name] and unit.team ~= myHero.team and GetDistanceSqr(myHero, spell.endPos) <= 640000 then
		CastSpell(_W, spell.endPos.x, spell.endPos.z)
	end
	
	if unit and unit.isMe and spell.name == "CaitlynYordleTrap" then 
		trapCount = trapCount + 1
	end
end
	
function AGCCastE()
	if mTarget and ValidTarget(mTarget, 500) and IsGapClosing(mTarget) then
		CastSpell(_E, mTarget.x, mTarget.z)
		if (not EAble) and Config.wSub.AGCtrap then
			CastSpell(_W, mTarget.x, mTarget.z)
		end
	end
end

function IsGapClosing(target)
	assert(type(target) == 'userdata', "IsGapClosing: Wrong type. Expected userdata got: "..tostring(type(target)))
	for i = 1, target.buffCount do
		tBuff = target:getBuff(i)
		if BuffIsValid(tBuff) and AGCBUFFS[tBuff.name] then
			return true
		end	
	end
	return false
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    SmartQ v0.2    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function SmartQ()
	local ccha = myHero.critChance
	local admg = myHero.totalDamage		
	local aspd = (myHero.attackSpeed * 0.625)
	local cdmg
	local plvl = PeacemakerLVL()
	local pcdt = PeacemakerCD()
	local hlvl = HeadshotLVL()
	if GetInventoryHaveItem(3031) then
		cdmg = 2.5
	else
		cdmg = 2
	end
	
	local critDmg = ((ccha*admg*aspd*cdmg)+((aspd/hlvl)*ccha*admg*cdmg*0.5))
	local nocritDmg = ((aspd*(1-ccha)*admg)+((aspd/hlvl)*admg*0.5))
	aaDmg = (critDmg+nocritDmg+myHero.level)					--Total AA DPS + level bonus

	local aaqDmg1 = (((plvl+(1.3*admg))*1)/pcdt)
	local aaqDmg2 = (((plvl+(1.3*admg))*1.9)/pcdt)
	local aaqDmg3 = (((plvl+(1.3*admg))*2.7)/pcdt)		
		
	local qaspd = (aspd*(5/6))
	local qcritDmg = ((ccha*admg*qaspd*cdmg)+((qaspd/hlvl)*ccha*admg*cdmg*0.5))
	local qnocritDmg = ((qaspd*(1-ccha)*admg)+((qaspd/hlvl)*admg*0.5))
	local qaaDmg = (qcritDmg+qnocritDmg)		--Total AA+Q DPS
	
	qTotal1 = (qaaDmg+aaqDmg1)
	qTotal2 = (qaaDmg+aaqDmg2)
	qTotal3 = (qaaDmg+aaqDmg3)
	
	if aaDmg <= qTotal1 then
		qCollision = 1
	elseif aaDmg < qTotal2 then
		qCollision = 2
	elseif aaDmg < qTotal3 then
		qCollision = 3
	end
end

function HeadshotLVL()
	if myHero.level >= 13 then return 5 
	elseif myHero.level >= 7 then return 6
	elseif myHero.level >= 1 then return 7
	end
end

function PeacemakerLVL()
	if myHero.level >= 9 then return 180 
	elseif myHero.level >= 7 then return 140
	elseif myHero.level >= 5 then return 100
	elseif myHero.level >= 3 then return 60
	elseif myHero.level >= 1 then return 20
	end
end

function PeacemakerCD()
	if myHero.level >= 9 then return 6 
	elseif myHero.level >= 7 then return 7
	elseif myHero.level >= 5 then return 8
	elseif myHero.level >= 3 then return 9
	elseif myHero.level >= 1 then return 10
	end
end

function InFountain()
    return NearFountain()
end

function GetInventoryHaveItem(itemID, target)
    assert(type(itemID) == "number", "GetInventoryHaveItem: wrong argument types ( expected)")
    local target = target or player
    return (GetInventorySlotItem(itemID, target) ~= nil)
end

function GetHeroCollision(pStart, pEnd) --From Collision 1.1.1 by Klokje
        hCollision = {}
        local heros = {}
 
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if hero.team ~= myHero.team and not hero.dead then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetDistance(pStart, pEnd)
		local prediction = VP
		
        if distance > 1300 then
            distance = 1300
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x * 40)
        local startLeftY = pStart.y + (y * 40)
        local startLeftZ = pStart.z + (z * 40)
        local endLeftX = pStart.x + (x * 40) + (t * distance)
        local endLeftY = pStart.y + (y * 40) + (i * distance)
        local endLeftZ = pStart.z + (z * 40) + (u * distance)
       
        local startRightX = pStart.x - (x * 40)
        local startRightY = pStart.y - (y * 40)
        local startRightZ = pStart.z - (z * 40)
        local endRightX = pStart.x - (x * 40) + (t * distance)
        local endRightY = pStart.y - (y * 40) + (i * distance)
        local endRightZ = pStart.z - (z * 40)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
        for index, hero in pairs(heros) do
            if hero ~= nil and hero.valid and not hero.dead then
                if GetDistance(pStart, hero) < distance then
					local pos, t, vec  = prediction:GetLineCastPosition(hero, 0.632, 80, 1300, 2225, myHero)				
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
        if #hCollision >= qCollision then return true, hCollision else return false, hCollision end
end

function GetMinionCollision(pStart, pEnd) --From Collision 1.1.1 by Klokje
	mCollision = {} 
		
	local distance =  GetDistance(pStart, pEnd)
	if distance > 1300 then
		distance = 1300
	end
 
	local V = Vector(pEnd) - Vector(pStart)
	local k = V:normalized()
    local P = V:perpendicular2():normalized()
 
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
 
    local startLeftX = pStart.x + (x *40)
    local startLeftY = pStart.y + (y *40)
    local startLeftZ = pStart.z + (z *40)
    local endLeftX = pStart.x + (x * 40) + (t * distance)
    local endLeftY = pStart.y + (y * 40) + (i * distance)
    local endLeftZ = pStart.z + (z * 40) + (u * distance)
     
    local startRightX = pStart.x - (x * 40)
    local startRightY = pStart.y - (y * 40)
    local startRightZ = pStart.z - (z * 40)
    local endRightX = pStart.x - (x * 40) + (t * distance)
    local endRightY = pStart.y - (y * 40) + (i * distance)
    local endRightZ = pStart.z - (z * 40)+ (u * distance)
 
    local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
    local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
    local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
    local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
      
    local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
    for index, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and minion.valid and not minion.dead then
			if GetDistance(pStart, minion) < distance then
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
				local toPoint = Point(toScreen.x, toScreen.y)
 
                if poly:contains(toPoint) then
					table.insert(mCollision, minion)
                else
                    local distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                    local distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
				end
			end
		end
	end
	if #mCollision >= Config.qSub.minMinions then return true, mCollision else return false, mCollision end
end

function GenerateLineSegmentFromCastPosition(CastPosition, FromPosition, SkillShotRange)
    local MaxEndPosition = CastPosition + (-1 * (Vector(CastPosition.x - FromPosition.x, 0, CastPosition.z - FromPosition.z):normalized()*SkillShotRange))
    return MaxEndPosition
end

function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)/2
end

function SmarterQ(target)
	if target == nil then return end
	local range = 650
	local movespeed = target.ms
	local wayPoint = VP:CalculateTargetPosition(target, 0.95, 1300, math.huge, myHero, "line")
	local gap = GetDistance(myHero, target)
	local gap2 = GetDistance(myHero, wayPoint)
	
	if gap2 > range then
		local isRetreating = true
		local escapeTime = ((range - gap)/movespeed)
		if isRetreating and escapeTime > 0.850 then
			--print("can't escape, time = "..escapeTime.."")
			return true
		elseif isRetreating and escapeTime < 0.850  and escapeTime > -0.07 then
			--print("will escape, time = "..escapeTime.."")
			return false		
		elseif isRetreating and escapeTime < -0.07 and movespeed >= myHero.ms then
			--print("out of range cannot catch")
			return true
		end
	elseif gap2 < range then
		--print("expected to remain in range")
		return true
	else 
		return false
	end
end
