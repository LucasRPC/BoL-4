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
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX OnLoad/AutoUpdate XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
if myHero.charName ~= "Caitlyn" then return end

require "VPrediction"
require "MapPosition"

local QAble, WAble, EAble, RAble = false, false, false
local RRange = nil
local AADPS, QAADPS1, QAADPS2 = 0, 0, 0
local QCollision = 1
local MSGTrapCount, MSGLastSentTrap, MSGLastSentColl = 0, 0, 0
local Prodiction
local LastPing = 0
local QendPos = nil
local ProdictionQ
local VP = nil
local enemyMinions = minionManager(MINION_ENEMY, 1300, myHero)
local TIMERTYPE_ENDPOS = 1
local TIMERTYPE_STARTPOS = 2
local TIMERTYPE_CASTER = 3
local timedDrawings = {}
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
local TELESPELLS = {
	["PantheonRFall"] = true,
	["LeblancSlide"] = true,
	["LeblancSlideM"] = true,
	["Crowstorm"] = true,
}

local sversion = "0.37"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local MESSAGE_HOST = "pastebin.com"
local UPDATE_PATH = "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Caitlynpoo.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#0099FF\">[Caitlynpoo!]</font> <font color=\"#FF6600\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/PewPewPew2/BoL/Danger-Meter/Caitlynpoo.version")
	local ServerData2 = GetWebResult(MESSAGE_HOST, "/raw.php?i=0e5aSswT")
	if ServerData and ServerData2 then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		ServerGreeting = type(tostring(ServerData2)) == "string" and tostring(ServerData2) or nil
		if ServerVersion then
			if tonumber(sversion) < ServerVersion then
				AutoupdaterMsg("New version available v"..ServerVersion.."")
				AutoupdaterMsg("Updating, please don't press F9")
				AutoupdaterMsg(""..ServerGreeting.."")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..sversion.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("Latest version loaded v"..ServerVersion.."")
				AutoupdaterMsg(""..ServerGreeting.."")
			end
		end
	else
		AutoupdaterMsg("Error receiving server info.")
	end
end

function Menu()
Config = scriptConfig("Caitlynpoo", "Caitlynpoo")
orbConfig = scriptConfig("Caitlynpoo Orbwalker", "Caitlynpoo Orbwalker")

Config:addSubMenu("Piltover Peacemaker", "qSub")
	Config.qSub:addSubMenu("Mana Manager", "manamanager")
		Config.qSub.manamanager:addParam("minMac", "AutoCarry Mana Manager %", SCRIPT_PARAM_SLICE, 15, 0, 100)	
		Config.qSub.manamanager:addParam("minM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Config.qSub.manamanager:addParam("minMlc", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
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
		Prodiction = ProdictManager.GetInstance()
		ProdictionQ = Prodiction:AddProdictionObject(_Q, 1300, 2200, 0.250, 80)
	end
end

function OnLoad()
	VP = VPrediction()
	wallposition = MapPosition()
	Menu()
	MakeCCTable()
	MakeAGCTable()
end

function OnTick()
	Checks()
	enemyMinions:update()
	
	if GetOrbwalkMode() < 3 then
		Peacemaker()
	elseif GetOrbwalkMode() == 3 then
		LaneClearTarget()
	end	
		
	if Config.wSub.onoff then 
		CastW()
	end
		
	if RAble then
		AceintheHole()
	end	
	
	if Config.eSub.netSub.net then
		NetToMouse()
	end
	
	if Config.wSub.casttrap then
		TrapNearEnemy()
	end
		
	if InFountain() then
		SmartQ()
	end 
	
	if Config.wSub.printCount or Config.qSub.printColl then
		InfoMessage()
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  Game Functions   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function NetToMouse() 
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

function OnDraw()
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
		for i, tDraw in pairs(timedDrawings) do
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

function CheckRLevel()
        if myHero:GetSpellData(_R).level == 1 then RRange = 2000
        elseif myHero:GetSpellData(_R).level == 2 then RRange = 2500
        elseif myHero:GetSpellData(_R).level == 3 then RRange = 3000
        end
end

function AceintheHole()
    CheckRLevel()
	
	if Config.rSub.damagetillr and mTarget and ValidTarget(mTarget, RRange) then
		local RDamage1 = getDmg("R",mTarget,myHero)
		if (1.08 * mTarget.health) > RDamage1 then
			local rfloattext = tostring(math.floor((1.08 * mTarget.health) - RDamage1))
			PrintFloatText(mTarget, 0, ""..rfloattext.."")
		end
	end
	
	for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
 		if RAble and ValidTarget(Enemy, RRange, true) then 
			local RDamage = getDmg("R",Enemy,myHero)	
			if (Enemy.health * 1.08) < RDamage then
				PrintFloatText(myHero, 0, "Press R For Killshot")
				local pingbuffer = (Config.rSub.timebetweenpings*1000)
				if Config.rSub.pingkillable and (LastPing+pingbuffer) < GetTickCount() then
					PingSignal(PING_NORMAL, Enemy.x, Enemy.y, Enemy.z,2)
					LastPing = GetTickCount()
					if ValidTarget(Enemy, RRange, true) and Config.rSub.kill and (Enemy.health * 1.08) < RDamage then
						CastSpell(_R, Enemy) 
					end	
				elseif ValidTarget(Enemy, RRange, true) and Config.rSub.kill and (Enemy.health * 1.08) < RDamage then
					CastSpell(_R, Enemy) 
				end		
			end
		end
	end
end

function Peacemaker()
	if mTarget and ValidTarget(mTarget, 1300) then
		local QendPos = myHero + (Vector(mTarget.x - myHero.x, 0, mTarget.z - myHero.z):normalized()*1300)
		local CastPos, Hit = GetSelectedPrediction(mTarget)
		if QAble and Hit >= Config.qSub.hit and not mTarget.dead and (GetAfterAA() or (GetDistanceSqr(mTarget) > 455625)) then
			if Config.qSub.smartQ == 1 then
				if QCollision <= 1 then
					CastSpell(_Q, CastPos.x, CastPos.z)
				elseif GetHeroCollision(QendPos) then
					CastSpell(_Q, CastPos.x, CastPos.z)
				end
			elseif Config.qSub.smartQ ==  2 and Config.qSub.dumbQ then
				CastSpell(_Q, CastPos.x, CastPos.z)
			end
		end
	end
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

function GetSelectedPrediction(unit)
	if not Config.qSub.usepro then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, 0.632, 80, 1300, 2225, myHero)
		return CastPosition, HitChance, Position
	else
		local QTarget, Qinfo = ProdictionQ:GetPrediction(unit)
		return QTarget, Qinfo.hitchance , nil
	end
end

function LaneClearTarget()
	if QAble then		
		for i=1, 5 do
			local QEndPos = Vector(myHero) + Vector(Vector(enemyMinions.objects[i]) - Vector(myHero)):normalized()*1300
			if QEndPos then	
				LaneClearHit(QEndPos)
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
			if n >= Config.qSub.minMinions then					
				CastSpell(_Q, enemyMinions.objects[i].x, enemyMinions.objects[i].z)
			end
		end
	end
end

function GetOrbwalkMode()
	if (orbConfig.Mode0 or orbConfig.orbwalk or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.AutoCarry) or (SxOrb and SxOrb.SxOrbMenu.Keys.Fight)) and myManaPct() > Config.qSub.manamanager.minMac then
		return 1
	elseif (orbConfig.Mode1 or orbConfig.hybrid or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.MixedMode) or (SxOrb and SxOrb.SxOrbMenu.Keys.Harass)) and myManaPct() > Config.qSub.manamanager.minM then
		return 2
	elseif Config.qSub.minMinions ~= 0 and (orbConfig.Mode2 or orbConfig.laneclear or (_G.AutoCarry and _G.AutoCarry.Keys and _G.AutoCarry.Keys.LaneClear) or (SxOrb and SxOrb.SxOrbMenu.Keys.LaneClear)) 
	and myManaPct() > Config.qSub.manamanager.minMlc then
		return 3
	else
		return 4
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      AutoTrap     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function CastW()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		if WAble and ValidTarget(Enemy, 800, true) and IsOnCC(Enemy) then
			CastSpell(_W, Enemy.x, Enemy.z)
			if Config.qSub.Qonoff and myManaPct() > Config.qSub.manamanager.minMac then
				CastSpell(_Q, Enemy.x, Enemy.z)
			end
		end
	end
end

function OnCreateObj(object)
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

function OnDeleteObj(object)
	if object.charName:find("CaitlynTrap") and object.team == myHero.team then
		for i, timedDr in pairs(timedDrawings) do
			if GetDistance(timedDr.pos, object) < 65 then 
            table.remove(timedDrawings, i)
            break
			end
		end
	end
end

function addTimedDrawPos(posX, posY, posZ, duration, delay)
    local tmpID = math.random(1,10000) -- add a new timer in the timed drawings table (with position)
    table.insert(timedDrawings, {id = tmpID, startTime = os.clock() + (delay or 0), endTime = os.clock() + (delay or 0) + duration, pos = Vector(posX, posY, posZ)})
    DelayAction(function() removeTimedDraw(tmpID) end, duration)
end

function removeTimedDraw(timerID)
    for i, timedDr in pairs(timedDrawings) do -- remove a timer from the timed drawings table
        if timedDr.id == timerID then
            table.remove(timedDrawings, i)
            break
        end
    end
end

function timerType(spellName)
    if spellName == "CaitlynYordleTrap" then -- check if a spell timer is supported, returning target type, duration and delay
        return TIMERTYPE_ENDPOS, 240	
	end
end

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

function TrapNearEnemy()
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

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        AGC        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function OnProcessSpell(unit, spell)
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
	
	if Config.wSub.onoff and TELESPELLS[spell.name] and unit.team ~= myHero.team and GetDistanceSqr(myHero, spell.endPos) <= 640000 then
		CastSpell(_W, spell.endPos.x, spell.endPos.z)
	end

	if unit and unit.isMe and spell.name == "CaitlynYordleTrap" then 
		local tType, duration, delay = timerType(spell.name)           
		if tType == TIMERTYPE_ENDPOS then
			addTimedDrawPos(spell.endPos.x, spell.endPos.y, spell.endPos.z, duration, delay)
		end
		MSGTrapCount = MSGTrapCount + 1
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

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    SmartQ v0.4    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function SmartQ()
	local ccha = myHero.critChance
	local admg = myHero.totalDamage		
	local aspd = (myHero.attackSpeed * 0.625)
	local cdmg
	local plvl = (20 + ((myHero:GetSpellData(_Q).level or 0) * 40))
	local pcdt = PeacemakerCD()
	local hlvl = HeadshotLVL()
	if GetInventoryHaveItem(3031) then
		cdmg = 2.5
	else
		cdmg = 2
	end
	
	local critDmg = ((ccha*admg*(aspd/(hlvl-(hlvl-1)))*cdmg)+((aspd/hlvl)*ccha*admg*cdmg*1.5))
	local nocritDmg = (((aspd/(hlvl-(hlvl-1)))*(1-ccha)*admg)+((aspd/hlvl)*admg*1.5))
	AADPS = (critDmg+nocritDmg+myHero.level)

	local QDmgOn1 = (((plvl+(1.3*admg))*1)/pcdt)
	local QDmgOn2 = (((plvl+(1.3*admg))*1.9)/pcdt)
		
	local qaspd = (aspd*((pcdt-1)/pcdt))
	local qcritDmg = ((ccha*admg*(qaspd/(hlvl-(hlvl-1)))*cdmg)+((qaspd/hlvl)*ccha*admg*cdmg*1.5))
	local qnocritDmg = (((qaspd/(hlvl-(hlvl-1)))*(1-ccha)*admg)+((qaspd/hlvl)*admg*1.5))
	local qaaDmg = (qcritDmg+qnocritDmg)
	
	QAADPS1 = (qaaDmg+QDmgOn1)
	QAADPS2 = (qaaDmg+QDmgOn2)
	
	if AADPS <= QAADPS1 then
		QCollision = 1
	elseif AADPS > QAADPS2 then
		QCollision = 2
	end
end

function HeadshotLVL()
	if myHero.level >= 13 then return 5 
	elseif myHero.level >= 7 then return 6
	elseif myHero.level >= 1 then return 7
	end
end

function PeacemakerCD()
	local cdr = (1+myHero.cdr)
	if myHero.level >= 9 then return ((6*cdr)+1) 
	elseif myHero.level >= 7 then return ((7*cdr)+1) 
	elseif myHero.level >= 5 then return ((8*cdr)+1) 
	elseif myHero.level >= 3 then return ((9*cdr)+1) 
	elseif myHero.level >= 1 then return ((10*cdr)+1) 
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

function GetHeroCollision(pos)
	local n = 1
	local dist
	for i,currentEnemy in ipairs(GetEnemyHeroes()) do
		if currentEnemy.team ~= myHero.team and (not currentEnemy.dead) and currentEnemy.charName ~=  mTarget.charName and GetDistanceSqr(currentEnemy) < 1690000 then
			dist = GetShortestDistanceFromLineSegment(Vector(myHero.x, myHero.z), Vector(pos.x, pos.z), Vector(currentEnemy.x, currentEnemy.z))
			if dist <= 120 then
				n = n + 1
				if n >= QCollision then	
					return true
				else
					return false
				end
			end
		end
	end
end

function InfoMessage()
	if Config.wSub.printCount and ((MSGLastSentTrap+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[AutoTrap]</font> <font color=\"#FF6600\">Traps Set - "..MSGTrapCount..".</font>")
		MSGLastSentTrap = GetTickCount()
	end
	if Config.qSub.printColl and ((MSGLastSentColl+1500) < GetTickCount()) then
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Collision with X heroes Required for SmartQ, X="..QCollision..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">AA DPS - "..AADPS..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Q on 1 Target DPS - "..QAADPS1..".</font>")
		print("<font color=\"#0099FF\">[SmartQ v0.4]</font> <font color=\"#FF6600\">Q on 2 Target DPS - "..QAADPS2..".</font>")
		MSGLastSentColl = GetTickCount()
	end
end
	
