class 'Plugin'
if myHero.charName ~= "Caitlyn" or not VIP_USER then return end

local RRange = nil
local LastPing = 0
TIMERTYPE_ENDPOS = 1
timedDrawings = {}
local TELESPELLS = {
	["PantheonRFall"] = true,
	["LeblancSlide"] = true,
	["LeblancSlideM"] = true,
	["Crowstorm"] = true,
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
local AGCTABLE = {
	["SummonerFlash"] = true,
}
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
function MakeAGCTable()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if AGCLIST[enemy.charName] then
			AGCTABLE[AGCLIST[enemy.charName].gcName] = true
		end			
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

function Plugin:__init()
require "VPrediction"

VP = VPrediction()
MakeAGCTable()
MakeCCTable()
AutoCarry.Crosshair:SetSkillCrosshairRange(1400)
AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
end

function Plugin:OnTick()
	Checks()
	enemyMinions = AutoCarry.Minions.EnemyMinions
	Target = AutoCarry.Crosshair:GetTarget()
	
	if AutoCarry.Keys.AutoCarry and Menu.qSub.toggleQ and Menu.manamanager.minMAC < myManaPct() then
		Peacemaker()
	elseif AutoCarry.Keys.MixedMode and Menu.qSub.toggleQ and Menu.manamanager.minMMM < myManaPct() then
		Peacemaker()
	elseif AutoCarry.Keys.LaneClear and Menu.qSub.toggleQ and Menu.manamanager.minMLC < myManaPct() then
		LaneClearTarget()
	end	
	
	if Menu.wSub.autoccW then CastW() end
	if RAble then AceintheHole() end	
	if Menu.eSub.netSub.net then NetToMouse() end	
	if Menu.wSub.casttrap then TrapNearEnemy() end
end

function Plugin:OnDraw()
	if Menu.rSub.rminimap and RAble then
		DrawCircleMinimap(myHero.x, myHero.y, myHero.z, RRange, 1, ARGB(255, 255, 255, 255), 100)
	end
	
	if Menu.wSub.drawtrap then
		for i, tDraw in pairs(timedDrawings) do
			if tDraw.startTime < os.clock() then
				DrawText3D(tostring(math.ceil(tDraw.endTime - os.clock(),1)), tDraw.pos.x, tDraw.pos.y, (30+tDraw.pos.z), 24, ARGB(255, 255, 0, 0), true)
				DrawCircle3D(tDraw.pos.x, tDraw.pos.y, tDraw.pos.z, 72, 1, ARGB(255, 255, 0, 0))
			end
		end
	end
	if Menu.eSub.netSub.drawejump and EAble then 
		DrawCircle3D(myHero.x, myHero.y, myHero.z, 495, 3, ARGB(100, 25, 25, 195))
	end
end

function Plugin:OnCreateObj(object)
	if Menu.wSub.autoccW and object.name:find("LifeAura") then
		for i=1, heroManager.iCount do
			currentEnemy = heroManager:GetHero(i)
			if currentEnemy.team ~= myHero.team and GetDistanceSqr(currentEnemy) <= 640000 and currentEnemy.bInvulnerable then
				Packet("S_CAST", { spellId = _W, toX = currentEnemy.x, toY = currentEnemy.z, fromX = currentEnemy.x, fromY = currentEnemy.z }):send()
            end
        end
    end
	
	if Menu.wSub.autoccW and object.name:find("global_ss_teleport_target_red") and GetDistanceSqr(object) < 640000 then
		Packet("S_CAST", { spellId = _W, toX = object.x, toY = object.z, fromX = object.x, fromY = object.z }):send()
	end	

	if Menu.wSub.autoccW and object.name:find("GateMarker_red") and GetDistanceSqr(object) < 640000 then
		Packet("S_CAST", { spellId = _W, toX = object.x, toY = object.z, fromX = object.x, fromY = object.z }):send()
	end
end
		
function Plugin:OnDeleteObj(object)
	if object.charName:find("CaitlynTrap") and object.team == myHero.team then
		for i, timedDr in pairs(timedDrawings) do
			if GetDistance(timedDr.pos, object) < 65 then 
            table.remove(timedDrawings, i)
            break
			end
		end
	end
end

function Plugin:OnProcessSpell(unit, spell)
	if Menu.eSub.AGConoff and AGCTABLE[spell.name] and unit.team ~= myHero.team and Menu.eSub.listSub[unit.charName] then
		local dist = GetShortestDistanceFromLineSegment(Vector(unit.x, unit.z), Vector(spell.endPos.x, spell.endPos.z), Vector(myHero.x, myHero.z))
		if dist < 250 then
			local WallCheck = myHero + ((Vector(myHero.x - unit.x, myHero.y - unit.y, myHero.z - unit.z):normalized()*400))	
			if not IsWall(D3DXVECTOR3(WallCheck.x, WallCheck.y, WallCheck.z)) then
				if unit then 
					Packet("S_CAST", { spellId = _E, toX = unit.x, toY = unit.z, fromX = unit.x, fromY = unit.z }):send()
					if Menu.wSub.AGCtrap then
						DelayAction(function() Packet("S_CAST", { spellId = _W, toX = spell.endPos.x, toY = spell.endPos.z, fromX = spell.endPos.x, fromY = spell.endPos.z }):send() end, 0.2)
					end	
				else
					Packet("S_CAST", { spellId = _E, toX = spell.endPos.x, toY = spell.endPos.z, fromX = spell.endPos.x, fromY = spell.endPos.z }):send()
					if Menu.wSub.AGCtrap then
						DelayAction(function() Packet("S_CAST", { spellId = _W, toX = spell.endPos.x, toY = spell.endPos.z, fromX = spell.endPos.x, fromY = spell.endPos.z }):send() end, 0.2)
					end	
				end
			end		
		end
	end
	
	if Menu.wSub.autoccW and TELESPELLS[spell.name] and unit.team ~= myHero.team and GetDistanceSqr(myHero, spell.endPos) <= 640000 then
		Packet("S_CAST", { spellId = _W, toX = spell.endPos.x, toY = spell.endPos.z, fromX = spell.endPos.x, fromY = spell.endPos.z }):send()
	end

	if unit and unit.isMe and spell.name == "CaitlynYordleTrap" then 
		local tType, duration, delay = timerType(spell.name)           
		if tType == TIMERTYPE_ENDPOS then
			addTimedDrawPos(spell.endPos.x, spell.endPos.y, spell.endPos.z, duration, delay)
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.team ~= myHero.team and ValidTarget(unit, 800) and CCBUFFS[buff.name] then
			Packet("S_CAST", { spellId = _W, toX = unit.x, toY = unit.z, fromX = unit.x, fromY = unit.z }):send()
		if Menu.qSub.autoccQ and myManaPct() > Menu.manamanager.minMAC then
			DelayAction(function() Packet("S_CAST", { spellId = _Q, toX = unit.x, toY = unit.z, fromX = unit.x, fromY = unit.z }):send() end, 0.2)
		end
	end
end

function Peacemaker()
	if Target and ValidTarget(Target, 1300) then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.632, 80, 1300, 2225, myHero)
		if QAble and HitChance >= Menu.qSub.hit and not Target.dead and (AutoCarry.Orbwalker:IsAfterAttack() or (GetDistanceSqr(Target) > 490000 and AutoCarry.Keys.AutoCarry))then
			Packet("S_CAST", { spellId = _Q, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send()
		end
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
			if n >= Menu.qSub.minMinions then					
				Packet("S_CAST", { spellId = _Q, toX = enemyMinions.objects[i].x, toY = enemyMinions.objects[i].z, fromX = enemyMinions.objects[i].x, fromY = enemyMinions.objects[i].z }):send()
			end
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
				Packet("S_CAST", { spellId = _W, toX = targetPos.x, toY = targetPos.z, fromX = targetPos.x, fromY = targetPos.z }):send()
			end
		end
	end
end

function CastW()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		if WAble and ValidTarget(Enemy, 800, true) and IsOnCC(Enemy) then
			Packet("S_CAST", { spellId = _W, toX = Enemy.x, toY = Enemy.z, fromX = Enemy.x, fromY = Enemy.z }):send()
			if Menu.qSub.autoccQ and myManaPct() > Menu.manamanager.minMAC then
				DelayAction(function() Packet("S_CAST", { spellId = _Q, toX = Enemy.x, toY = Enemy.z, fromX = Enemy.x, fromY = Enemy.z }):send() end, 0.2)
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

function NetToMouse() 
	if EAble and (not IsKeyDown(17))then
		local MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
		local HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
		local WallCheck = HeroPos + (-1 * (Vector(HeroPos.x - MPos.x, 0, HeroPos.z - MPos.z):normalized()*495))
		
		if mTarget and ValidTarget(mTarget, 1300) and Menu.eSub.netSub.animcancel then
			Packet("S_CAST", { spellId = _Q, toX = Target.x, toY = Target.z, fromX = Target.x, fromY = Target.z }):send()
		end
		if not IsWall(D3DXVECTOR3(WallCheck.x, WallCheck.y, WallCheck.z)) then
			Packet("S_CAST", { spellId = _E, toX = DashPos.x, toY = DashPos.z, fromX = DashPos.x, fromY = DashPos.z }):send()
		end
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
	
	if Menu.rSub.damagetillr and Target and ValidTarget(Target, RRange) then
		local RDamage1 = getDmg("R",Target,myHero)
		if (1.08 * Target.health) > RDamage1 then
			local rfloattext = tostring(math.floor((1.08 * Target.health) - RDamage1))
			PrintFloatText(Target, 0, ""..rfloattext.."")
		end
	end
	
	for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
 		if RAble and ValidTarget(Enemy, RRange, true) then 
			local RDamage = getDmg("R",Enemy,myHero)	
			if (Enemy.health * 1.08) < RDamage then
				PrintFloatText(myHero, 0, "Press R For Killshot")
				if Menu.rSub.pingkillable then
					if (LastPing+4500) < GetTickCount() then
						for i = 0.1, 0.7, 0.2 do
						DelayAction(function() Packet("R_PING", {x = Enemy.x, y = Enemy.z, type = PING_DANGER}):receive() end, i)
						LastPing = GetTickCount()
						end
					end					
					
					if ValidTarget(Enemy, RRange, true) and Menu.rSub.kill and (Enemy.health * 1.08) < RDamage then
						Packet("S_CAST", { spellId = _R, targetNetworkId = Enemy.networkID }):send()
					end	
				elseif ValidTarget(Enemy, RRange, true) and Menu.rSub.kill and (Enemy.health * 1.08) < RDamage then
					Packet("S_CAST", { spellId = _R, targetNetworkId = Enemy.networkID }):send()
				end		
			end
		end
	end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

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

function addTimedDrawPos(posX, posY, posZ, duration, delay)
    local tmpID = math.random(1,10000) -- add a new timer in the timed drawings table (with position)
    table.insert(timedDrawings, {id = tmpID, startTime = os.clock() + (delay or 0), endTime = os.clock() + (delay or 0) + duration, pos = Vector(posX, posY, posZ)})
    DelayAction(function() removeTimedDraw(tmpID) end, duration)
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


Menu = AutoCarry.Plugins:RegisterPlugin(Plugin(), "Caitlyn")
Menu:addSubMenu("Mana Manager", "manamanager")
	Menu.manamanager:addParam("minMAC", "AutoCarry Mana Manager %", SCRIPT_PARAM_SLICE, 15, 0, 100)	
	Menu.manamanager:addParam("minMMM", "Mixed Mode Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
	Menu.manamanager:addParam("minMLC", "LaneClear Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)

Menu:addSubMenu("Piltover Peacemaker", "qSub")
	Menu.qSub:addParam("autoccQ", "AutoPeacemaker on CC", SCRIPT_PARAM_ONOFF, true)
	Menu.qSub:addParam("minMinions", "Min. Minions - Q LaneClear(0=OFF)", SCRIPT_PARAM_SLICE, 6, 0, 10)
	Menu.qSub:addParam("toggleQ", "Toggle Q Hotkey", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("X"))
	Menu.qSub:permaShow("toggleQ")
	Menu.qSub:addParam("hit", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })

Menu:addSubMenu("Yordle Snap Trap", "wSub")
	Menu.wSub:addParam("autoccW", "AutoTrap on CC", SCRIPT_PARAM_ONOFF, true)
	Menu.wSub:addParam("AGCtrap", "AntiGapClose with W", SCRIPT_PARAM_ONOFF, true)
	Menu.wSub:addParam("casttrap", "Cast Trap on Closest Enemy Path", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu.wSub:addParam("drawtrap", "Draw Trap Range and Timer", SCRIPT_PARAM_ONOFF, true)

Menu:addSubMenu("90 Caliber Net", "eSub")
	Menu.eSub:addSubMenu("Net to Mouse", "netSub")	
		Menu.eSub.netSub:addParam("net", "Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
		Menu.eSub.netSub:addParam("animcancel", "Use Q in E Animation", SCRIPT_PARAM_ONOFF, false)
		Menu.eSub.netSub:addParam("drawejump", "Draw E Jump Range", SCRIPT_PARAM_ONOFF, true)
	Menu.eSub:addSubMenu("Use AntiGapClose on:", "listSub")
		for _, enemy in ipairs(GetEnemyHeroes()) do
			Menu.eSub.listSub:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end	
	Menu.eSub:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)

Menu:addSubMenu("Ace in the Hole", "rSub")
	Menu.rSub:addParam("kill", "R Killshot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	Menu.rSub:addParam("damagetillr", "Draw Damage left till Killshot", SCRIPT_PARAM_ONOFF, true)
	Menu.rSub:addParam("rminimap", "Draw Range on MiniMap", SCRIPT_PARAM_ONOFF, true)
	Menu.rSub:addParam("pingkillable", "Ping Killable Heroes", SCRIPT_PARAM_ONOFF, true)










