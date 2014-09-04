--[[CREDITS:
	All the Lib/Orbwalk Creators:
		honda7
		klokje
		Sida
		Manciuszz
		Superx321
	Other Caitlyn Scripters: (I've learned a lot from them)
		MixsStar
		Toy
		How I met Katarina
		dbman
	Others: 
		Bilbao -  cause everything he writes on the forum seems so damn helpful
		redprince - for the trap timers
		Sida again - For being awesome.
]]
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     AutoUpdate    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
local SupportedChars = {
	["Caitlyn"] = true,
	["Lucian"] = true,
}

if not SupportedChars[myHero.charName] then return end

local sversion = "0.38"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local MESSAGE_HOST = "pastebin.com"
local UPDATE_PATH = "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Caitlynpoo.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local DOWNLOADING_LIBS = false
local LibsChecked = false

function UpdateLibs()
local VpURL = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua"
local SowURL = "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua"
local MapURL = "https://raw.githubusercontent.com/c3iL/BoL-1/master/MapPosition.lua"
local GeoURL = "https://raw.githubusercontent.com/wquantum1/BoL/master/old2dgeo.lua"
local SxURL = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua"

	if not FileExist(LIB_PATH.."VPrediction.lua") then
		DownloadURL(VpURL, "VPrediction.lua", "VPrediction")
	elseif not FileExist(LIB_PATH.."SOW.lua") then
		DownloadURL(SowURL, "SOW.lua", "SimpleOrbwalker")
	elseif not FileExist(LIB_PATH.."MapPosition.lua") then
		DownloadURL(MapURL, "MapPosition.lua", "MapPosition")
	elseif not FileExist(LIB_PATH.."old2dgeo.lua") then
		DownloadURL(GeoURL, "old2dgeo.lua", "old2dgeo")
	elseif not FileExist(LIB_PATH.."SxOrbWalk.lua") then
		DownloadURL(SxURL, "SxOrbWalk.lua", "SxOrbWalk")
	elseif DOWNLOADING_LIBS then
		AutoupdaterMsg("LibDownloader downloads complete. Please reload [F9]")
	else
		DOWNLOADING_LIBS = false
	end	
end

function DownloadURL(url, savename, show)
AutoupdaterMsg("Initiating "..show.." download..")
	DOWNLOADING_LIBS = true
	DownloadFile(url, LIB_PATH..savename, function()
							if FileExist(LIB_PATH..savename) then								
								AutoupdaterMsg("Downloading "..show.." Complete")							
							end
						end
				)
	DelayAction(function() UpdateLibs() end, 4)
end

function AutomaticUpdate(data1, data2)
	if data1 and data2 then
		local ServerVersion = type(tonumber(data1)) == "number" and tonumber(data1) or nil
		local ServerGreeting = type(tostring(data2)) == "string" and tostring(data2) or nil
		if ServerVersion then
			if tonumber(sversion) < ServerVersion then
				AutoupdaterMsg("New version available v"..ServerVersion..". "..ServerGreeting..".")
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..sversion.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("Latest version loaded v"..ServerVersion..". "..ServerGreeting.."")
			end
		end
	else
		AutoupdaterMsg("Error receiving server info.")
	end
end

function AutoupdaterMsg(msg) print("<font color=\"#0099FF\">[PewPewPoo Bundle]</font> <font color=\"#FF6600\">"..msg..".</font>") end

if AUTOUPDATE then
	AutoupdaterMsg("LibDownloader initializing..")
	UpdateLibs()
	if not DOWNLOADING_LIBS then
		AutoupdaterMsg("LibDownloader complete")
		LibsChecked = true
		local ServerData = GetWebResult(UPDATE_HOST, "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.version")
		local ServerData2 = GetWebResult(MESSAGE_HOST, "/raw.php?i=0e5aSswT")
		DelayAction(function() AutomaticUpdate(ServerData, ServerData2) end, 1)
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    Globals Var.   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
require "VPrediction"
require "MapPosition"	

local currentChar
local QAble, WAble, EAble, RAble = false, false, false, false
local VP = nil
local enemyMinions = minionManager(MINION_ENEMY, 1100, myHero)

for i, _ in pairs(SupportedChars) do
	local createClass = i:gsub("%s+", "") --Trims whitespace
	class(createClass)
	if i == myHero.charName then
		currentChar = _G[createClass]
	end
end

local CCBUFFS = {
	["caitlynyordletrapdebuff"] = true,
	["Flee"] = true,
	["Stun"] = true,
	["supression"] = true,
	["Taunt"] = true,
	["zhonyasringshield"] = true,
}
local CCLIST = {
	["Aatrox"] = {ccName = "aatroxqknockup"},
	["Ahri"] = {ccName = "ahriseducedoom"},
	["Amumu"] = {ccName = "CurseoftheSadMummy"},
	["Blitzcrank"] = {ccName = "powerfistslow"},
	["Braum"] = {ccName = "braumstundebuff", "braumpulselineknockup"},
	["Chogath"] = {ccName = "rupturetarget"},
	["Elise"] = {ccName = "EliseHumanE"},
	["Janna"] = {ccName = "HowlingGaleSpell"},
	["JarvanIV"] = {ccName = "jarvanivdragonstrikeph2"},
	["Karma"] = {ccName = "karmaspiritbindroot"},
	["Lux"] = {ccName = "LuxLightBindingMis"},
	["Lissandra"] = {ccName = "lissandrawfrozen", "lissandraenemy2"},
	["Malphite"] = {ccName = "unstoppableforceestun"},
	["Maokai"] = {ccName = "maokaiunstablegrowthroot"},
	["MonkeyKing"] = {ccName = "monkeykingspinknockup"},
	["Morgana"] = {ccName = "DarkBindingMissile"},
	["Nami"] = {ccName = "namiqdebuff"},
	["Nautilus"] = {ccName = "nautilusanchordragroot"},
	["Ryze"] = {ccName = "RunePrison"},
	["Sejuani"] = {ccName = "sejuaniglacialprison"},
	["Sona"] = {ccName = "SonaR"},
	["Swain"] = {ccName = "swainshadowgrasproot"},
	["Thresh"] = {ccName = "threshqfakeknockup"},
	["Veigar"] = {ccName = "VeigarStun"},	
	["Velkoz"] = {ccName = "velkozestun"},
	["Vi"] = {ccName = "virdunkstun"},
	["Viktor"] = {ccName = "viktorgravitonfieldstun"},
	["Yasuo"] = {ccName = "yasuoq3mis"},
	["Zyra"] = {ccName = "zyragraspingrootshold", "zyrabramblezoneknockup"},
}
local SELFCCLIST = {
	["FiddleSticks"] = {ccName = "fearmonger_marker"},
	["Katarina"] = {ccName = "katarinarsound"},
	["Lissandra"] = {ccName = "lissandrarself"},
	["Malzahar"] = {ccName = "AlZaharNetherGrasp"},
	["MasterYi"] = {ccName = "Meditate"},
	["MissFortune"] = {ccName = "missfortunebulletsound"},
	["Nunu"] = {ccName = "AbsoluteZero"},
	["Pantheon"] = {ccName = "pantheonesound"},
	["Velkoz"] = {ccName = "VelkozR"},
	["Warwick"] = {ccName = "infiniteduresssound"},
	["Zilean"] = {ccName = "chronorevive"},
}
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
local AGCSPELLS = {
	["SummonerFlash"] = true,
}

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Globals Func.   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function OnLoad()
if not LibsChecked then return end

	VP = VPrediction()
	wallposition = MapPosition()
	currentChar:Init()
	currentChar:Menu()
	MakeCCTable()
	MakeAGCTable()	
end

function OnTick()
	if not LibsChecked then return end
	
	currentChar:OnTick()
end

function OnDraw() 
	if not LibsChecked then return end
	
	currentChar:OnDraw()
end

function OnProcessSpell(unit, spell)
	if not LibsChecked then return end
	
	currentChar:OnProcessSpell(unit, spell)	
end

function OnCreateObj(object)
	if not LibsChecked then return end
	
	currentChar:OnCreateObj(object)
end

function OnDeleteObj(object)
	if not LibsChecked then return end
	
	currentChar:OnDeleteObj(object)
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)	
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
	
--///////////////////////////////////////////////////////////////////SAC\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\	
	if orbConfig.orbchoice == 4 and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Skills_Crosshair 
	and _G.AutoCarry.Crosshair.Skills_Crosshair.target and _G.AutoCarry.Crosshair.Skills_Crosshair.target.type == myHero.type then 		
			mTarget = _G.AutoCarry.Crosshair.Skills_Crosshair.target
--///////////////////////////////////////////////////////////////////MMA\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 3 and _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
		mTarget = _G.MMA_Target	
--///////////////////////////////////////////////////////////////////SxO\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 2 and SxOrb then
		sxTarget = SxOrb:GetTarget()
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
--///////////////////////////////////////////////////////////////////SOW\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	elseif orbConfig.orbchoice == 1 and Orbwalker then
		local selectedTarget = GetTarget()
		if orbConfig.focustarget and selectedTarget and ValidTarget(selectedTarget, myHero.range) and selectedTarget.type == myHero.type then
			mTarget = selectedTarget
		else
		mTarget = Orbwalker:GetTarget(true)
			if not mTarget then 
				local best, damage = nil, 99
				for i, enemy in pairs(GetEnemyHeroes()) do
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
	end
end

function GetOrbwalkMode()
	if (orbConfig.Mode0 or orbConfig.orbwalk or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (SxOrb and SxOrb.SxOrbMenu.Keys.Fight)) and myManaPct() > Config.manamanager.minMac then
		return 1
	elseif (orbConfig.Mode1 or orbConfig.hybrid or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass)) and myManaPct() > Config.manamanager.minM then
		return 2
	elseif Config.qSub.minMinions ~= 0 and (orbConfig.Mode2 or orbConfig.laneclear or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.LaneClear) or (SxOrb and SxOrb.SxOrbMenu.Keys.LaneClear)) 
	and myManaPct() > Config.manamanager.minMlc then
		return 3
	else
		return 4
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

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

function MakeCCTable()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if SELFCCLIST[enemy.charName] then
			CCBUFFS[SELFCCLIST[enemy.charName].ccName] = true
		end			
	end
	for _, ally in ipairs(GetAllyHeroes()) do
		if CCLIST[ally.charName] then
			CCBUFFS[CCLIST[ally.charName].ccName] = true
		end
	end
end

function MakeAGCTable()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if AGCLIST[enemy.charName] then
			AGCSPELLS[AGCLIST[enemy.charName].gcName] = true
		end			
	end
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

function GetAfterAA()
	if orbConfig.orbchoice == 4 and _G.AutoCarry.Orbwalker:IsAfterAttack() then			
		return true
	elseif orbConfig.orbchoice == 3 and _G.MMA_NextAttackAvailability > 0.1 and _G.MMA_NextAttackAvailability < 0.2 then
		return true
	elseif orbConfig.orbchoice == 2 and mTarget.type == myHero.type and SxOrb:CanMove() and (not SxOrb:CanAttack()) then
		return true
	elseif orbConfig.orbchoice == 1 and orbConfig.Enabled and Orbwalker:CanMove() and (not Orbwalker:CanAttack()) then
		return true
	else 
		return false
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      Caitlyn      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function Caitlyn:Init()
	self.RRange = nil
	self.QCollision = 1
	self.AADPS, self.QAADPS1, self.QAADPS2 = 0, 0, 0
	self.MSGTrapCount, self.MSGLastSentTrap, self.MSGLastSentColl = 0, 0, 0
	self.Prodiction, self.ProdictionQ = nil, nil
	self.LastPing = 0
	self.TIMERTYPE_ENDPOS = 1
	self.timedDrawings = {}
	self.TELESPELLS = {
	["PantheonRFall"] = true,
	["LeblancSlide"] = true,
	["LeblancSlideM"] = true,
	["Crowstorm"] = true,
}	
end

function Caitlyn:Menu()
Config = scriptConfig("Caitlynpoo", "Caitlynpoo")
orbConfig = scriptConfig("Caitlynpoo Orbwalker", "Caitlynpoo Orbwalker")

Config:addSubMenu("Mana Manager", "manamanager")
	Config.manamanager:addParam("minMac", "AutoCarry Mana Manager %", SCRIPT_PARAM_SLICE, 15, 0, 100)	
	Config.manamanager:addParam("minM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
	Config.manamanager:addParam("minMlc", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)

Config:addSubMenu("Piltover Peacemaker", "qSub")
	Config.qSub:addParam("Qonoff", "AutoPeacemaker on CC", SCRIPT_PARAM_ONOFF, true)
	Config.qSub:addParam("minMinions", "Min. Minions - Q LaneClear(0=OFF)", SCRIPT_PARAM_SLICE, 6, 0, 10)
	Config.qSub:addParam("smartQ", "Q Cast Options", SCRIPT_PARAM_LIST, 1, { "SmartQ v0.4", "Toggle" })
	Config.qSub:addParam("dumbQ", "Toggle Q Hotkey", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
	Config.qSub:addParam("usepro", "Use Prodiction (Requires Reload)", SCRIPT_PARAM_ONOFF, false)
	if (not Config.qSub.usepro) then
		Config.qSub:addParam("hit", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
	end
	if Config.qSub.usepro then
		Config.qSub:addParam("hit", "Q - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	end
	Config.qSub:addParam("printColl", "SmartQ v0.4 [INFO]", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))

Config:addSubMenu("Yordle Snap Trap", "wSub")
	Config.wSub:addParam("onoff", "AutoTrap on CC", SCRIPT_PARAM_ONOFF, true)
	Config.wSub:addParam("AGCtrap", "AntiGapClose with W if E on CD", SCRIPT_PARAM_ONOFF, true)
	Config.wSub:addParam("casttrap", "Cast Trap on Closest Enemy Path", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Config.wSub:addParam("drawtrap", "Draw Trap Range and Timer", SCRIPT_PARAM_ONOFF, true)
	Config.wSub:addParam("printCount", "Count Traps Set [INFO]", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))

Config:addSubMenu("90 Caliber Net", "eSub")
	Config.eSub:addSubMenu("Net to Mouse", "netSub")	
		Config.eSub.netSub:addParam("net", "Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
		Config.eSub.netSub:addParam("animcancel", "Use Q in E Animation", SCRIPT_PARAM_ONOFF, false)
		Config.eSub.netSub:addParam("drawejump", "Draw E Jump Range", SCRIPT_PARAM_ONOFF, true)
	Config.eSub:addSubMenu("Use AntiGapClose on:", "listSub")
		for _, enemy in ipairs(GetEnemyHeroes()) do
			Config.eSub.listSub:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end	
	Config.eSub:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Ace in the Hole", "rSub")
	Config.rSub:addParam("kill", "R Killshot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	Config.rSub:addParam("damagetillr", "Draw Damage left till Killshot", SCRIPT_PARAM_ONOFF, true)
	Config.rSub:addParam("rminimap", "Draw Range on MiniMap", SCRIPT_PARAM_ONOFF, true)
	Config.rSub:addParam("pingkillable", "Ping Killable Heroes", SCRIPT_PARAM_ONOFF, true)
	Config.rSub:addParam("timebetweenpings", "Minimum time between pings", SCRIPT_PARAM_SLICE, 2, 1, 5)
	

orbConfig:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SxOrbWalk", "MMA", "SAC" })	
	if orbConfig.orbchoice == 1 then
		require "SOW"
		Orbwalker = SOW(VP)
		Orbwalker:LoadToMenu(orbConfig)
		orbConfig:addParam("drawrange", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("focustarget", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
		
	end
	if orbConfig.orbchoice == 2 then
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
		require "SxOrbWalk"
		SxOrb = SxOrbWalk()
		SxOrb:LoadToMenu(orbConfig)
	end
	if orbConfig.orbchoice == 3 then
		orbConfig:addParam("orbwalk", "OrbWalker", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		orbConfig:addParam("hybrid", "HybridMode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		orbConfig:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	end
	if Config.qSub.usepro then
		require "Prodiction"
		self.Prodiction = ProdictManager.GetInstance()
		self.ProdictionQ = self.Prodiction:AddProdictionObject(_Q, 1300, 2200, 0.250, 80)
	end
end

function Caitlyn:OnTick()
	Checks()
	enemyMinions:update()
	
	if GetOrbwalkMode() < 3 then
		Caitlyn:Peacemaker()
	elseif GetOrbwalkMode() == 3 then
		Caitlyn:LaneClearTarget()
	end	
		
	if Config.wSub.onoff then 
		Caitlyn:CastW()
	end
		
	if RAble then
		Caitlyn:AceintheHole()
	end	
	
	if Config.eSub.netSub.net then
		Caitlyn:NetToMouse()
	end
	
	if Config.wSub.casttrap then
		Caitlyn:TrapNearEnemy()
	end
		
	if Caitlyn:InFountain() then
		Caitlyn:SmartQ()
	end 
	
	if Config.wSub.printCount or Config.qSub.printColl then
		Caitlyn:InfoMessage()
	end
end

function Caitlyn:NetToMouse() 
	if EAble and (not IsKeyDown(17))then
		local MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
		local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
		local ewallcheck = HeroPos + (-1 * (Vector(HeroPos.x - MPos.x, 0, HeroPos.z - MPos.z):normalized()*495))
		local mappoint = Point(ewallcheck.x, ewallcheck.z)		
		
		if mTarget and ValidTarget(mTarget, 1300) and Config.eSub.netSub.animcancel then
			CastSpell(_Q, mTarget.x, mTarget.z)
		end
		if not wallposition:inWall(mappoint) then
			CastSpell(_E, DashPos.x, DashPos.z)
		end
	end
end

function Caitlyn:OnDraw()
	if myHero.dead then return end	

	if orbConfig.orbchoice == 1 and orbConfig.drawrange and Orbwalker then
		Orbwalker:DrawAARange(3, ARGB(100, 35, 250, 11))
	end
	
	if (orbConfig.orbchoice == 1 or orbConfig.orbchoice == 2) and orbConfig.drawtarget and mTarget and ValidTarget(mTarget) then
		DrawCircle3D(mTarget.x, mTarget.y, mTarget.z, ((GetDistance(mTarget, mTarget.minBBox)/2) + 30), 3, ARGB(100, 185, 4, 4))
	end
	
	if Config.rSub.rminimap and RAble then
		DrawCircleMinimap(myHero.x, myHero.y, myHero.z, RRange, 1, ARGB(255, 255, 255, 255), 100)
	end
	
	if Config.wSub.drawtrap then
		for i, tDraw in pairs(self.timedDrawings) do
			if tDraw.startTime < os.clock() then
				DrawText3D(tostring(math.ceil(tDraw.endTime - os.clock(),1)), tDraw.pos.x, tDraw.pos.y, (30+tDraw.pos.z), 24, ARGB(255, 255, 0, 0), true)
				DrawCircle3D(tDraw.pos.x, tDraw.pos.y, tDraw.pos.z, 72, 1, ARGB(255, 255, 0, 0))
			end
		end
	end
	if Config.eSub.netSub.drawejump and EAble then 
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 495, 3, ARGB(100, 25, 25, 195))
	end
end

function Caitlyn:CheckRLevel()
        if myHero:GetSpellData(_R).level == 1 then self.RRange = 2000
        elseif myHero:GetSpellData(_R).level == 2 then self.RRange = 2500
        elseif myHero:GetSpellData(_R).level == 3 then self.RRange = 3000
        end
end

function Caitlyn:AceintheHole()
    Caitlyn:CheckRLevel()
	
	if Config.rSub.damagetillr and mTarget and ValidTarget(mTarget, self.RRange) then
		local RDamage1 = getDmg("R",mTarget,myHero)
		if (1.08 * mTarget.health) > RDamage1 then
			local rfloattext = tostring(math.floor((1.08 * mTarget.health) - RDamage1))
			PrintFloatText(mTarget, 0, ""..rfloattext.."")
		end
	end
	
	for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
 		if RAble and ValidTarget(Enemy, self.RRange, true) then 
			local RDamage = getDmg("R",Enemy,myHero)	
			if (Enemy.health * 1.08) < RDamage then
				PrintFloatText(myHero, 0, "Press R For Killshot")
				local pingbuffer = (Config.rSub.timebetweenpings*1000)
				if Config.rSub.pingkillable and (self.LastPing+pingbuffer) < GetTickCount() then
					PingSignal(PING_NORMAL, Enemy.x, Enemy.y, Enemy.z,2)
					self.LastPing = GetTickCount()
					if ValidTarget(Enemy, self.RRange, true) and Config.rSub.kill and (Enemy.health * 1.08) < RDamage then
						CastSpell(_R, Enemy) 
					end	
				elseif ValidTarget(Enemy, self.RRange, true) and Config.rSub.kill and (Enemy.health * 1.08) < RDamage then
					CastSpell(_R, Enemy) 
				end		
			end
		end
	end
end

function Caitlyn:Peacemaker()
	if mTarget and ValidTarget(mTarget, 1300) then
		local QendPos = myHero + (Vector(mTarget.x - myHero.x, 0, mTarget.z - myHero.z):normalized()*1300)
		local CastPos, Hit = Caitlyn:GetSelectedPrediction(mTarget)
		if QAble and Hit >= Config.qSub.hit and not mTarget.dead and (GetAfterAA() or (GetDistanceSqr(mTarget) > 490000 and GetOrbwalkMode() == 1))then
			if Config.qSub.smartQ == 1 then
				if self.QCollision <= 1 then
					CastSpell(_Q, CastPos.x, CastPos.z)
				elseif Caitlyn:GetHeroCollision(QendPos) then
					CastSpell(_Q, CastPos.x, CastPos.z)
				end
			elseif Config.qSub.smartQ ==  2 and Config.qSub.dumbQ then
				CastSpell(_Q, CastPos.x, CastPos.z)
			end
		end
	end
end

function Caitlyn:GetSelectedPrediction(unit)
	if not Config.qSub.usepro then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, 0.632, 80, 1300, 2225, myHero)
		return CastPosition, HitChance, Position
	else
		local QTarget, Qinfo = self.ProdictionQ:GetPrediction(unit)
		return QTarget, Qinfo.hitchance , nil
	end
end

function Caitlyn:LaneClearTarget()
	if QAble then		
		for i=1, 5 do
			local QEndPos = Vector(myHero) + Vector(Vector(enemyMinions.objects[i]) - Vector(myHero)):normalized()*1300
			if QEndPos then	
				Caitlyn:LaneClearHit(QEndPos)
			end
		end
	end
end

function Caitlyn:LaneClearHit(pos)
	local n = 0
	for i=1, #enemyMinions.objects do
		local dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(pos.x, pos.z), Vector(enemyMinions.objects[i].x, enemyMinions.objects[i].z))
		if dist <= 80 then
			n = n + 1
			if n >= Config.qSub.minMinions then					
				CastSpell(_Q, enemyMinions.objects[i].x, enemyMinions.objects[i].z)
			end
		end
	end
end

function Caitlyn:CastW()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		if WAble and ValidTarget(Enemy, 800, true) and IsOnCC(Enemy) then
			CastSpell(_W, Enemy.x, Enemy.z)
			if Config.qSub.Qonoff and myManaPct() > Config.manamanager.minMac then
				CastSpell(_Q, Enemy.x, Enemy.z)
			end
		end
	end
end

function Caitlyn:OnCreateObj(object)
	if Config.wSub.onoff and object.name:find("LifeAura") then
		for i=1, heroManager.iCount do
			currentEnemy = heroManager:GetHero(i)
			if currentEnemy.team ~= myHero.team and GetDistanceSqr(currentEnemy) <= 640000 and currentEnemy.bInvulnerable then
				CastSpell(_W, currentEnemy.x, currentEnemy.z)
            end
        end
    end
	
	if Config.wSub.onoff and object.name:find("global_ss_teleport_target_red") and GetDistanceSqr(object) < 640000 then
		CastSpell(_W, object.x, object.z)
	end	

	if Config.wSub.onoff and object.name:find("GateMarker_red") and GetDistanceSqr(object) < 640000 then
		CastSpell(_W, object.x, object.z)
	end
end
		
function Caitlyn:OnDeleteObj(object)
	if object.charName:find("CaitlynTrap") and object.team == myHero.team then
		for i, timedDr in pairs(self.timedDrawings) do
			if GetDistance(timedDr.pos, object) < 65 then 
            table.remove(self.timedDrawings, i)
            break
			end
		end
	end
end

function Caitlyn:addTimedDrawPos(posX, posY, posZ, duration, delay)
    local tmpID = math.random(1,10000) -- add a new timer in the timed drawings table (with position)
    table.insert(self.timedDrawings, {id = tmpID, startTime = os.clock() + (delay or 0), endTime = os.clock() + (delay or 0) + duration, pos = Vector(posX, posY, posZ)})
    DelayAction(function() Caitlyn:removeTimedDraw(tmpID) end, duration)
end

function Caitlyn:removeTimedDraw(timerID)
    for i, timedDr in pairs(self.timedDrawings) do -- remove a timer from the timed drawings table
        if timedDr.id == timerID then
            table.remove(self.timedDrawings, i)
            break
        end
    end
end

function Caitlyn:timerType(spellName)
    if spellName == "CaitlynYordleTrap" then -- check if a spell timer is supported, returning target type, duration and delay
        return self.TIMERTYPE_ENDPOS, 240	
	end
end

function Caitlyn:TrapNearEnemy()
	if WAble then		
		local distance = 2500000
		local closestEnemy = nil
		for i=1, heroManager.iCount do
			currentEnemy = heroManager:GetHero(i)
			if currentEnemy.team ~= myHero.team and not currentEnemy.dead and GetDistance(currentEnemy) <= 500 then
				if GetDistance(currentEnemy) <= distance then
					distance = GetDistance(currentEnemy)
					closestEnemy = currentEnemy
				end
			end
		end		
		
		if closestEnemy then
			local targetPos = VP:CalculateTargetPosition(closestEnemy, 1.25, 600, math.huge, myHero, "circular")	
			if targetPos then 
				CastSpell(_W, targetPos.x, targetPos.z)
			end
		end
	end
end

function Caitlyn:OnProcessSpell(unit, spell)
	if Config.eSub.AGConoff and AGCSPELLS[spell.name] and unit.team ~= myHero.team and Config.eSub.listSub[unit.charName] then
		local dist = GetShortestDistanceFromLineSegment(Vector(unit.x, unit.z), Vector(spell.endPos.x, spell.endPos.z), Vector(myHero.x, myHero.z))
		if dist < 250 then
			local ewallcheck = myHero + ((Vector(myHero.x - unit.x, 0, myHero.z - unit.z):normalized()*400))
			local mappoint = Point(ewallcheck.x, ewallcheck.z)	
			if not wallposition:inWall(mappoint) then
				if unit then 
					CastSpell(_E, unit.x, unit.z)
				else
					CastSpell(_E, spell.endPos.x, spell.endPos.z)
				end
			end
		end
		
		if (not EAble) and Config.wSub.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if Config.wSub.onoff and self.TELESPELLS[spell.name] and unit.team ~= myHero.team and GetDistanceSqr(myHero, spell.endPos) <= 640000 then
		CastSpell(_W, spell.endPos.x, spell.endPos.z)
	end

	if unit and unit.isMe and spell.name == "CaitlynYordleTrap" then 
		local tType, duration, delay = Caitlyn:timerType(spell.name)           
		if tType == self.TIMERTYPE_ENDPOS then
			Caitlyn:addTimedDrawPos(spell.endPos.x, spell.endPos.y, spell.endPos.z, duration, delay)
		end
		self.MSGTrapCount = self.MSGTrapCount + 1
	end
end

function Caitlyn:SmartQ()
	local ccha = myHero.critChance
	local admg = myHero.totalDamage		
	local aspd = (myHero.attackSpeed * 0.625)
	local cdmg
	local plvl = (20 + ((myHero:GetSpellData(_Q).level or 0) * 40))
	local pcdt = Caitlyn:PeacemakerCD()
	local hlvl = Caitlyn:HeadshotLVL()
	if Caitlyn:GetInventoryHaveItem(3031) then
		cdmg = 2.5
	else
		cdmg = 2
	end
	
	local critDmg = ((ccha*admg*(aspd/(hlvl-(hlvl-1)))*cdmg)+((aspd/hlvl)*ccha*admg*cdmg*1.5))
	local nocritDmg = (((aspd/(hlvl-(hlvl-1)))*(1-ccha)*admg)+((aspd/hlvl)*admg*1.5))
	self.AADPS = (critDmg+nocritDmg+myHero.level)

	local QDmgOn1 = (((plvl+(1.3*admg))*1)/pcdt)
	local QDmgOn2 = (((plvl+(1.3*admg))*1.9)/pcdt)
		
	local qaspd = (aspd*((pcdt-1)/pcdt))
	local qcritDmg = ((ccha*admg*(qaspd/(hlvl-(hlvl-1)))*cdmg)+((qaspd/hlvl)*ccha*admg*cdmg*1.5))
	local qnocritDmg = (((qaspd/(hlvl-(hlvl-1)))*(1-ccha)*admg)+((qaspd/hlvl)*admg*1.5))
	local qaaDmg = (qcritDmg+qnocritDmg)
	
	self.QAADPS1 = (qaaDmg+QDmgOn1)
	self.QAADPS2 = (qaaDmg+QDmgOn2)
	
	if self.AADPS <= self.QAADPS1 then
		self.QCollision = 1
	elseif self.AADPS > self.QAADPS2 then
		self.QCollision = 2
	end
end

function Caitlyn:HeadshotLVL()
	if myHero.level >= 13 then return 5 
	elseif myHero.level >= 7 then return 6
	elseif myHero.level >= 1 then return 7
	end
end

function Caitlyn:PeacemakerCD()
	local cdr = (1+myHero.cdr)
	if myHero.level >= 9 then return ((6*cdr)+1) 
	elseif myHero.level >= 7 then return ((7*cdr)+1) 
	elseif myHero.level >= 5 then return ((8*cdr)+1) 
	elseif myHero.level >= 3 then return ((9*cdr)+1) 
	elseif myHero.level >= 1 then return ((10*cdr)+1) 
	end
end

function Caitlyn:InFountain()
    return NearFountain()
end

function Caitlyn:GetInventoryHaveItem(itemID, target)
    assert(type(itemID) == "number", "GetInventoryHaveItem: wrong argument types ( expected)")
    local target = target or player
    return (GetInventorySlotItem(itemID, target) ~= nil)
end

function Caitlyn:GetHeroCollision(pos)
	local n = 1
	local dist
	for i,currentEnemy in ipairs(GetEnemyHeroes()) do
		if currentEnemy.team ~= myHero.team and (not currentEnemy.dead) and currentEnemy.charName ~=  mTarget.charName and GetDistanceSqr(currentEnemy) < 1690000 then
			dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(pos.x, pos.z), Vector(currentEnemy.x, currentEnemy.z))
			if dist <= 120 then
				n = n + 1
				if n >= self.QCollision then	
					return true
				else
					return false
				end
			end
		end
	end
end

function Caitlyn:InfoMessage()
	if Config.wSub.printCount and ((self.MSGLastSentTrap+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[AutoTrap]</font> <font color=\"#FF6600\">Traps Set - "..self.MSGTrapCount..".</font>")
		self.MSGLastSentTrap = GetTickCount()
	end
	if Config.qSub.printColl and ((self.MSGLastSentColl+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Collision with X heroes Required for SmartQ, X="..self.QCollision..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">AA DPS - "..self.AADPS..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Q on 1 Target DPS - "..self.QAADPS1..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Q on 2 Target DPS - "..self.QAADPS2..".</font>")
		self.MSGLastSentColl = GetTickCount()
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      Lucian       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function Lucian:Init()
	self.LastCull, self.CullingAngle = 0, nil
end

function Lucian:Menu()
Config = scriptConfig("Lucianpoo", "Lucianpoo")
orbConfig = scriptConfig("Lucianpoo Orbwalker", "Lucianpoo Orbwalker")

Config:addSubMenu("Mana Manager", "manamanager")
	Config.manamanager:addParam("minMac", "AutoCarry Mana Manager %", SCRIPT_PARAM_SLICE, 15, 0, 100)	
	Config.manamanager:addParam("minM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
	Config.manamanager:addParam("minMlc", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)

Config:addSubMenu("Piercing Light", "qSub")
	Config.qSub:addParam("qautocc", "AutoQ on CC", SCRIPT_PARAM_ONOFF, true)
	Config.qSub:addParam("minMinions", "Min. Minions - Q LaneClear(0=OFF)", SCRIPT_PARAM_SLICE, 3, 0, 6)

Config:addSubMenu("Ardent Blaze", "wSub")
	Config.wSub:addParam("wautocc", "AutoW on CC", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Relentless Pursuit", "eSub")
	Config.eSub:addParam("drawejump", "Draw E Jump Range", SCRIPT_PARAM_ONOFF, true)
	Config.eSub:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)
	Config.eSub:addSubMenu("Use AntiGapClose on:", "listSub")
		for _, enemy in ipairs(GetEnemyHeroes()) do
			Config.eSub.listSub:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end	
	

Config:addSubMenu("The Culling", "rSub")
	Config.rSub:addParam("kill", "Lock R on Target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))

orbConfig:addParam("orbchoice", "Select Orbwalker (Requires Reload)", SCRIPT_PARAM_LIST, 1, { "SOW", "SxOrbWalk", "MMA", "SAC" })	
	if orbConfig.orbchoice == 1 then
		require "SOW"
		Orbwalker = SOW(VP)
		Orbwalker:LoadToMenu(orbConfig)
		orbConfig:addParam("drawrange", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
		orbConfig:addParam("focustarget", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
		
	end
	if orbConfig.orbchoice == 2 then
		orbConfig:addParam("drawtarget", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
		require "SxOrbWalk"
		SxOrb = SxOrbWalk()
		SxOrb:LoadToMenu(orbConfig)
	end
	if orbConfig.orbchoice == 3 then
		orbConfig:addParam("orbwalk", "OrbWalker", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		orbConfig:addParam("hybrid", "HybridMode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		orbConfig:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	end
end

function Lucian:OnTick()
	Checks()
	enemyMinions:update()
	Lucian:CastAutoCC()
	
	
	if GetOrbwalkMode() < 2 then
		Lucian:ArdentBlaze()
		Lucian:PiercingLight()
	elseif GetOrbwalkMode() < 3 then
		Lucian:PiercingLight()
	elseif GetOrbwalkMode() < 4 then
		Lucian:LaneClearTarget()
	end	
		
	if Config.rSub.kill then
		Lucian:TheCulling()
	end	
end

function Lucian:OnDraw()
	if myHero.dead then return end	

	if orbConfig.orbchoice == 1 and orbConfig.drawrange and Orbwalker then
		Orbwalker:DrawAARange(3, ARGB(100, 35, 250, 11))
	end
	
	if (orbConfig.orbchoice == 1 or orbConfig.orbchoice == 2) and orbConfig.drawtarget and mTarget and ValidTarget(mTarget) then
		DrawCircle3D(mTarget.x, mTarget.y, mTarget.z, ((GetDistance(mTarget, mTarget.minBBox)/2) + 30), 3, ARGB(100, 185, 4, 4))
	end
		
	if Config.eSub.drawejump and EAble then 
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 495, 3, ARGB(100, 25, 25, 195))
	end
end

function Lucian:PiercingLight()
	if mTarget and ValidTarget(mTarget, 640) then
		if QAble and not mTarget.dead and (Lucian:HasPassive() or GetAfterAA()) then
			CastSpell(_Q, mTarget)
		end
	elseif mTarget and GetDistanceSqr(mTarget) > 422500 and ValidTarget(mTarget, 1100) then		
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.1, 50, 1100, math.huge, myHero, true) 
		for i, minion in ipairs(enemyMinions.objects) do
			if minion and GetDistanceSqr(minion) < 360000 then
				local QEndPos = Vector(myHero) + Vector(Vector(minion) - Vector(myHero)):normalized()*1100
				if QEndPos then	
					for i=1, heroManager.iCount do
						currentEnemy = heroManager:GetHero(i)
						local dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(QEndPos.x, QEndPos.z), Vector(Position.x, Position.z))
						if currentEnemy.team ~= myHero.team and not currentEnemy.dead and dist < 25 then
							CastSpell(_Q, minion)
						end
					end
				end
			end
		end
	end
end

function Lucian:ArdentBlaze()
	if mTarget and ValidTarget(mTarget, 1000) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.2, 50, 1000, 1200, myHero)
		if WAble and HitChance >= 1 and not mTarget.dead then
			if (Lucian:HasPassive() or GetAfterAA()) then
				if not VP:CheckMinionCollision(mTarget, CastPosition, 0.1, 50, 1000, 1200, myHero, false, true) then
					CastSpell(_W, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end
  
function Lucian:HasPassive()
	for i = 1, myHero.buffCount do
		tBuff = myHero:getBuff(i)
		if BuffIsValid(tBuff) and tBuff.name == "lucianpassivebuff" then
			return false
		end	
	end
	return true
end

function Lucian:OnProcessSpell(unit, spell)
	if Config.eSub.AGConoff and AGCSPELLS[spell.name] and unit.team ~= myHero.team and Config.eSub.listSub[unit.charName] then
		local dist = GetShortestDistanceFromLineSegment(Vector(unit.x, unit.z), Vector(spell.endPos.x, spell.endPos.z), Vector(myHero.x, myHero.z))
		if dist < 250 then
			local ewallcheck = Vector(myHero.x, 0, myHero.z) + Vector(Vector(myHero.x, 0, myHero.z) - Vector(unit.x, 0, unit.z)):normalized()*400
			local mappoint = Point(ewallcheck.x, ewallcheck.z)			
			if not wallposition:inWall(mappoint) then
				if unit then 
					local castpos = Vector(myHero) + Vector(Vector(myHero) - Vector(unit)):normalized()*400
					if castpos then
						CastSpell(_E, castpos.x, castpos.z)
					end
				else
					local castpos = Vector(myHero) + Vector(Vector(myHero) - Vector(spell.endPos)):normalized()*400
					if castpos then
						CastSpell(_E, castpos.x, castpos.z)
					end
				end
			end
		end
	end
end

function Lucian:CastAutoCC()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		if Config.qSub.qautocc and QAble and ValidTarget(Enemy, 600) and IsOnCC(Enemy) and Lucian:HasPassive() and myManaPct() > Config.manamanager.minMac  then
			CastSpell(_Q, Enemy)
		end
		
		if Config.wSub.wautocc and WAble and ValidTarget(Enemy, 1000) and IsOnCC(Enemy) and Lucian:HasPassive() and myManaPct() > Config.manamanager.minMac then
			CastSpell(_W, Enemy.x, Enemy.z)
		end	
	end
end

function Lucian:LaneClearTarget()
	if QAble then		
		for i=1, 5 do
			if enemyMinions.objects[i] and GetDistanceSqr(enemyMinions.objects[i]) < 360000 then
				local QEndPos = Vector(myHero) + Vector(Vector(enemyMinions.objects[i]) - Vector(myHero)):normalized()*1100
				if QEndPos and Lucian:LaneClearHit(QEndPos) then	
					CastSpell(_Q, enemyMinions.objects[i])
				end
			end
		end
	end
end

function Lucian:LaneClearHit(pos)
	local n = 0
	for i=1, #enemyMinions.objects do
		local dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(pos.x, pos.z), Vector(enemyMinions.objects[i].x, enemyMinions.objects[i].z))
		if dist <= 80 then
			n = n + 1
			if n >= Config.qSub.minMinions then					
				return true
			--else
				--return false
			end
		end
	end
	return false
end

function Lucian:TheCulling()	
	if RAble and mTarget and ValidTarget(mTarget, 1350) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.2, 50, 1200, 2000, myHero)
		if CastPosition and HitChance >= 1 and (self.LastCull+10000) < GetTickCount() then
			CastSpell(_R, CastPosition.x, CastPosition.z)
			self.LastCull = GetTickCount()
			self.CullingAngle = Vector(Vector(myHero.x, 0, myHero.z) - Vector(CastPosition.x, 0, CastPosition.z)):normalized()
		end	
		 
		for i=1, 1 do
			local movePos = Vector(mTarget.x, 0, mTarget.z) + self.CullingAngle*(GetDistance(mTarget, mousePos))
			myHero:MoveTo(movePos.x, movePos.z)
		end
	end
end

function Lucian:OnCreateObj(object)
end

 function Lucian:OnDeleteObj(object)
 end

