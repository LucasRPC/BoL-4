--[[                                                               ------------------------Script Core------------------------]]
if myHero.charName ~= "Caitlyn" then return end

require "VPrediction"

local QAble, EAble, RAble = false, false
local rDmg
local rRange = nil
local Prodiction
local ProdictionQ
local VP = nil

--[[		Auto Update		Pretty well ripped from Fantastik Sivir - Fantastik]] 
local sversion = "0.22"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Caitlynpoo.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF6600\">[Caitlynpoo!]</font> <font color=\"#FFFFFF\">"..msg..".</font>") end
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
Config:addParam("onoff", "AutoTrap", SCRIPT_PARAM_ONOFF, true)
Config:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)
Config:addParam("agptrap", "Use trap with AGP", SCRIPT_PARAM_ONOFF, false)
Config:addParam("net", "E to Mouse", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
Config:addParam("kill", "R Killshot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
Config:addParam("usepro", "Use Prodiction (Requires Reload)", SCRIPT_PARAM_ONOFF, false)
Config:addParam("minM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
if (not Config.usepro) then
	Config:addParam("vphit", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
end
if Config.usepro then
	Config:addParam("prohit", "Q - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
end
Config:addSubMenu("Orbwalk Options", "sow")
Config.sow:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SaC", "MMA", "SxOrbWalk" })	
	if Config.sow.orbchoice == 1 then
		require "SOW"
		Orbwalker = SOW(VP)
		Orbwalker:LoadToMenu(Config.sow, STS)
	end
	if Config.sow.orbchoice == 4 then
		require "SxOrbWalk"
		SxOrb = SxOrbWalk()
		SxOrb:LoadToMenu(Config.sow)
		SxOrb:RegisterAfterAttackCallback(PeacemakerReset)
	end
	if Config.usepro then
		require "Prodiction"
		Prodiction = ProdictManager.GetInstance()
		ProdictionQ = Prodiction:AddProdictionObject(_Q, 1300, 2200, 0.250, 90)
	end
end

function OnLoad()
	VP = VPrediction()
	Menu()	
end

function OnTick()
	Checks()
	
	if Config.sow.Mode0 or _G.MMA_Orbwalker or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (SxOrb and SxOrb.SxOrbMenu.Keys.Fight) then
		if (not Config.usepro) then
			Peacemaker()
		elseif Config.usepro then
			PeacemakerPRO()
		end
	elseif Config.sow.Mode1 or _G.MMA_HybridMode or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass) and myManaPct() > Config.minM then
		if (not Config.usepro) then
			Peacemaker()
		elseif Config.usepro then
			PeacemakerPRO()
		end
	end	
		
	if Config.onoff then 
		CastW()
	end
	
	if Config.AGConoff then 
		AGCCastE()
	end
	
	if RAble then
		AceintheHole()
	end	
	
	if Config.net then
		NetToMouse()
	end
	
	if Config.orbchoice == 2 then
		HeadShot()
	end
end

--[[                                                               ------------------------Game Functions------------------------]]
function NetToMouse() --From SAC Plugin - Caitlyn - jbman
         if EAble and Config.net and (not IsKeyDown(17)) then
         MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
         HeroPos = Vector(myHero.x, myHero.y, myHero.z)
         DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
          myHero:MoveTo(mousePos.x,mousePos.z)
          CastSpell(_E,DashPos.x,DashPos.z)
         end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
	
    if Config.sow.orbchoice == 2 and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair.target and _G.AutoCarry.Crosshair.Attack_Crosshair.target.type == myHero.type then 		
		mTarget = _G.AutoCarry.Crosshair.Attack_Crosshair.target
	elseif Config.sow.orbchoice == 3 and _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
		mTarget = _G.MMA_Target	
	elseif Config.sow.orbchoice == 4 and SxOrb then
		mTarget = SxOrb:GetTarget()
	elseif Config.sow.orbchoice == 1 and Orbwalker then
		mTarget = Orbwalker:GetTarget(true)
	end
end

function CheckRLevel() --From SAC Plugin - Caitlyn - jbman
        if myHero:GetSpellData(_R).level == 1 then rRange = 2000
        elseif myHero:GetSpellData(_R).level == 2 then rRange = 2500
        elseif myHero:GetSpellData(_R).level == 3 then rRange = 3000
        end
end

function AceintheHole()--From SAC Plugin - Caitlyn - jbman
    CheckRLevel()
	for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if RAble then rDmg = getDmg("R",Enemy,myHero) else rDmg = 0 end
        if ValidTarget(Enemy, rRange, true) and (Enemy.health + 60) < rDmg then
        PrintFloatText(myHero, 0, "Press R For Killshot") end
        if ValidTarget(Enemy, rRange, true) and Config.kill and (Enemy.health + 60) < rDmg then
        CastSpell(_R, Enemy) end
    end
end

function Peacemaker()
	if mTarget then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.632, 90, 1300, 2225, myHero)
		if QAble and HitChance >= Config.vphit and GetDistanceSqr(CastPosition) < 1690000 then
			if Config.sow.orbchoice == 2 and _G.AutoCarry.Orbwalker:IsAfterAttack() then			
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif Config.sow.orbchoice == 3 and (not _G.MMA_AttackAvailable) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif  Config.sow.orbchoice == 1 and Config.sow.Enabled then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif  Config.sow.orbchoice == 4 and mTarget.type == myHero.type and SxOrb:CanMove() then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function PeacemakerPRO()
	if mTarget then
        local QTarget, Qinfo = ProdictionQ:GetPrediction(mTarget)
        if QAble and Qinfo.hitchance >= Config.prohit and GetDistanceSqr(QTarget) < 1690000 then 
			if Config.sow.orbchoice == 2 and _G.AutoCarry.Orbwalker:IsAfterAttack() then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif Config.sow.orbchoice == 3 and (not _G.MMA_AttackAvailable) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif Config.sow.orbchoice == 1 and Config.sow.Enabled then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif  Config.sow.orbchoice == 4 and mTarget.type == myHero.type and SxOrb:CanMove() then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
    	end
	end
end

function HeadShot() --SAC MODE ONLY(not working atm)
	if HasPassive(myHero) and _G.AutoCarry.Plugins then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(PassiveDmg())
	elseif _G.AutoCarry and _G.AutoCarry.Plugins and (not HasPassive(myHero)) then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(NoPassive())
	end
end

function HasPassive(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "caitlynheadshot")
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end
function PassiveDmg() return ((_G.AutoCarry.MyHero:GetTotalAttackDamageAgainstTarget(_G.AutoCarry.Minions.EnemyMinions)) * 1.7) end
function NoPassive() return 0 end

--[[                                                               ------------------------Not So Simple AutoTrap------------------------ HELP FROM BILBAO- THANKS
AutoTrap CC support for: AmumuQ&R, Elise, J4, Jax, Nautilus, Pantheon, Warwick, Udyr, Vi, Ahri, Anivia, Lissandra, Sion, Syndra, Swain, Viktor, Vel'Koz, Veigar, TwistedFate, Xerath, Yasuo, Blitzcrank,
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

function CastW()
	if mTarget and ValidTarget(mTarget, 800) and IsOnCC(mTarget) then
		CastSpell(_W, mTarget.x, mTarget.z)
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

--[[                                                               ------------------------Not So Simple AGC------------------------
AntiGapClose support for: Aatrox, Alistar, Ahri, Corki, Fiora, Graves, Leblanc, Gragas, J4, Fizz, LeeSin, Malphite, Diana, Hecarim, Riven, Shen, Volibear, Quinn, Zac, Sejuani, Renekton, Vi, 
Wukong, Ezreal, Leona, Khazix, Lucian, Nautilus, Tryndamere, Nidalee, XinZhao, Yasuo, Maokai, Poppy, Jax, Pantheon, Thresh, Irelia, Tristana]]

local AGCNAMES = {
	["Ezreal"] = true,
	["Aatrox"] = true,
	["Alistar"] = true,
	["Yasuo"] = true,
	["Malphite"] = true,
	["Tristana"] = true,
	["Diana"] = true,
	["Hecarim"] = true,
	["Leona"] = true,
	["Khazix"] = true,
	["Lucian"] = true,
	["Nautilus"] = true,	
	["Tryndamere"] = true,
	["Nidalee"] = true,
	["XinZhao"] = true,
	["Maokai"] = true,
	["Poppy"] = true,
	["Jax"] = true,
	["Pantheon"] = true,
	["Thresh"] = true,
	["Irelia"] = true,
	["MonkeyKing"] = true,
	["Vi"] = true,
	["Sejuani"] = true,
	["Quinn"] = true,
	["LeeSin"] = true,
	["JarvanIV"] = true,
	["Renekton"] = true,
	["Gragas"] = true,
	["Ahri"] = true,
	["Graves"] = true,
	["Corki"] = true,
	["LeBlanc"] = true,
	["Fizz"] = true,
	["Fiora"] = true,
	["Riven"] = true,
	["Shen"] = true,
}
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
	["Headbutt"] = true,
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

function OnProcessSpell(unit, spell)
	if Config.AGConoff and AGCNAMES[unit.charName] and AGCSPELLS[spell.name] and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
end
	
function AGCCastE()
	if mTarget and ValidTarget(mTarget, 500) and IsGapClosing(mTarget) then
		CastSpell(_E, mTarget.x, mTarget.z)
		if Config.AGCtrap then
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





