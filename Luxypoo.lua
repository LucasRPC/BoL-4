if myHero.charName ~= "Lux" then return end

--Requirements
require 'VPrediction'
require 'SourceLib'

--Variable Declarations
local version = 0.3
local mTarget
local qColl
local qLCColl
local VP = VPrediction()
local TS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
local DrawHandler = DrawManager()
local DamageCalculator = DamageLib()
local Config = nil
local isRecalling = false
local jungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
local enemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_HEALTH_ASC)
local SpellData = { 
	[_Q] = {
		name = "LuxLightBinding",
		ready = false,
		range = 1175,
		width = 80,
		speed = 1200,
		delay = 0.5
	},
	
	[_E] = {
		name = "LuxLightStrikeKugel",
		ready = false,
		range = 1000,
		width = 275,
		speed = 1300,
		delay = 0.5,
	},
	
	[_R] = {
		name = "LuxMaliceCannon",
		ready = false,
		range = 3340,
		width = 190,
		speed = 3000,
		delay = 1.75
	}
}

--Script Setup

function OnLoad()
	ScriptSetUp()
	Init()
	PrintChat("<font color=\"#FF6600\">[Luxypoo!]</font> <font color=\"#FFFFFF\">Script loaded. Running version v"..version.."vp.</font>")
end

function ScriptSetUp()
Config = scriptConfig("Luxypoo v"..version.."vp", "Luxypoo v"..version.."vp")

--Set HitChance
Config:addSubMenu("Hit Chance", "hChanceSub")
	Config.hChanceSub:addParam("hitChance", "Set Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)
	Config.hChanceSub:addParam("hcInfo", "1 - Low Hitchance  2 - High Hitchance", SCRIPT_PARAM_INFO, " ")


--Chain CC
Config:addSubMenu("Chain CC", "chainSub")	
	Config.chainSub:addParam("useQchain", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.chainSub:addParam("useEchain", "Use E", SCRIPT_PARAM_ONOFF, true)
	
--Combo options
Config:addSubMenu("Combo options", "ComboSub")
	Config.ComboSub:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
	Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
	
--Harass options
Config:addSubMenu("Harass options", "HarassSub")
	Config.HarassSub:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
	Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

--Draw Target
Config:addSubMenu("Draw Target", "TargetSub")
	Config.TargetSub:addParam("drawTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)

--Jungle
Config:addSubMenu("Jungle Clear", "JungleSub")
	Config.JungleSub:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Config.JungleSub:addParam("useQjclear", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.JungleSub:addParam("useEjclear", "Use E", SCRIPT_PARAM_ONOFF, true)

--LaneClear
Config:addSubMenu("Lane Clear", "LClearSub")
	Config.LClearSub:addParam("lclr", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Config.LClearSub:addParam("useQlclear", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.LClearSub:addParam("useElclear", "Use E", SCRIPT_PARAM_ONOFF, true)

--KS
Config:addSubMenu("Kill Secure", "KS")
	Config.KS:addParam("active", "Kill Secure On/Off", SCRIPT_PARAM_ONOFF, true) 	
	Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
	
-- Simple Target Selector
Config:addSubMenu("Simple Target Selector", "sts")
	TS:AddToMenu(Config.sts)

--Minion Buffer
Config:addParam("mBuff", "Minion Q Buffer", SCRIPT_PARAM_SLICE, 65, 50, 100, 0)
end

function Init()
--Lux Spells
Q = Spell(_Q, SpellData[_Q].range)
E = Spell(_E, SpellData[_E].range)
R = Spell(_R, SpellData[_R].range)

--Skillshots
Q:SetSkillshot(VP, SKILLSHOT_LINEAR, SpellData[_Q].width, SpellData[_Q].delay, SpellData[_Q].speed, false)
E:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellData[_E].width, SpellData[_E].delay, SpellData[_E].speed, false)
R:SetSkillshot(VP, SKILLSHOT_LINEAR, SpellData[_R].width, SpellData[_R].delay, SpellData[_R].speed, false)
Q:TrackCasting(SpellData[_Q].name)
Q:RegisterCastCallback(CDHandler)

Q:SetHitChance(Config.hChanceSub.hitChance or 3 or 4 or 5)	
E:SetHitChance(Config.hChanceSub.hitChance or 3 or 4 or 5)
R:SetHitChance(Config.hChanceSub.hitChance or 4 or 5 or 5)

Loaded = true
end

function OnTick()
	if Loaded then
		jungleMinions:update()
		enemyMinions:update()
		KillSteal()
		CDHandler()
		
		mTarget = TS:GetTarget(SpellData[_Q].range)--Targets
		qColl = CountObjectsOnLineSegment(myHero, Vector(mTarget), (SpellData[_Q].width + Config.mBuff), enemyMinions.objects)
	
		if Config.ComboSub.Combo then
			Combo()
		end
		
		if Config.HarassSub.Harass then
			Harass()
		end

		if Config.JungleSub.jclr then
			JungleClear()
		end		
		
		if Config.LClearSub.lclr then
			LaneClear()
		end	
	end
end

function OnDraw()
	local onDtarget = TS:GetTarget(SpellData[_Q].range)
		if qColl and qColl <= 1 then
			onDqCollcolor = ARGB(100, 35, 250, 11)
		end		
		if qColl and qColl > 1 then
			onDqCollcolor = ARGB(100, 124, 4, 4)
		end
	
	if myHero.dead then return end	
				
	if onDtarget and Config.TargetSub.drawTarget then
		DrawLine3D(myHero.x, myHero.y, myHero.z, onDtarget.x, onDtarget.y, onDtarget.z, 1, onDqCollcolor)
		DrawLineBorder3D(myHero.x, myHero.y, myHero.z, onDtarget.x, onDtarget.y, onDtarget.z, 80, onDqCollcolor, 8)
		if onDtarget.visible and not onDtarget.dead then			
			for j=1, 25 do
				local ycircle = (j*(120/25*2)-120)
				local r = math.sqrt(120^2-ycircle^2)
				ycircle = ycircle/1.3
				DrawCircle(onDtarget.x, onDtarget.y+100+ycircle, onDtarget.z, r, onDqCollcolor)				
			end		 
		end	
	end
end

--Game Functions

function CDHandler()
	SpellData[_Q].ready = (myHero:CanUseSpell(_Q) == READY)
	SpellData[_E].ready = (myHero:CanUseSpell(_E) == READY)
	SpellData[_R].ready = (myHero:CanUseSpell(_R) == READY)
end

function Combo()
	if mTarget and Q:IsReady() and Config.ComboSub.useQ and qColl <= 1 and GetDistance(myHero, mTarget) < (SpellData[_Q].range - 75) then --Q 
		Q:Cast(mTarget)
	end 

	if E:IsReady() and Config.ComboSub.useE and GetDistance(myHero, mTarget) < SpellData[_E].range then 
		E:Cast(mTarget)
	end
		
	for _,enemy in pairs(GetEnemyHeroes()) do
		if enemy and mTarget and enemy.name == mTarget.name and R:IsReady() and IsBinded(mTarget) and Config.ComboSub.useR and (100 + enemy.health) <= getDmg("R", enemy, myHero) and GetDistance(myHero, mTarget) < SpellData[_R].range then 
			R:Cast(mTarget)
		end	
	end
end 

function Harass()
	if mTarget and Q:IsReady() and Config.HarassSub.useQ and qColl <= 1 and GetDistance(myHero, mTarget) < (SpellData[_Q].range - 75) then --Q 
		Q:Cast(mTarget)
	end 
	
	if E:IsReady() and mTarget and Config.HarassSub.useE and GetDistance(myHero, mTarget) < SpellData[_E].range then
		E:Cast(mTarget)
	end
end 

function JungleClear()
	for i, jungleMinion in pairs(jungleMinions.objects) do 
		if jungleMinion ~= nil then		
			if Config.JungleSub.useQjclear and SpellData[_Q].ready and ValidTarget(jungleMinion, SpellData[_Q].range) then
				Q:Cast(jungleMinion)
			end
	
			if Config.JungleSub.useEjclear and SpellData[_E].ready and ValidTarget(jungleMinion, SpellData[_E].range) then
				local jObj = CountObjectsNearPos(Vector(jungleMinion), nil, SpellData[_E].width, jungleMinions.objects)
				local jtObj = CountObjectsNearPos(Vector(jungleMinion), nil, 600, jungleMinions.objects)
				if jObj == jtObj then
					E:Cast(jungleMinion)
				end
			end
		end
	end
end

function LaneClear()


	for i, enemyMinion in pairs(enemyMinions.objects) do
		if enemyMinion ~= nil then
			qLCColl = CountObjectsOnLineSegment(myHero, Vector(enemyMinion), (SpellData[_Q].width + 50), enemyMinions.objects)	
			if Config.LClearSub.useQlclear and SpellData[_Q].ready and ValidTarget(enemyMinion, SpellData[_Q].range) and getDmg("Q", enemyMinion, myHero) > enemyMinion.health and qLCColl >= 2 then
				Q:Cast(enemyMinion)
			end
			
			if Config.LClearSub.useElclear and SpellData[_E].ready and ValidTarget(enemyMinion, SpellData[_E].range) then
				local eObj = CountObjectsNearPos(enemyMinion, nil, SpellData[_E].width, enemyMinions.objects)
				local tObj = CountObjectsNearPos(enemyMinion, nil, 550, enemyMinions.objects)	
				
				if eObj >= tObj*0.55 and eObj > 2 then
					E:Cast(enemyMinion)	
				end
			end
		end
	end
end

function KillSteal()
	if isRecalling or (not Config.KS.active) then return end
	
	for _,enemy in pairs(GetEnemyHeroes()) do
		if Config.KS.useR and SpellData[_R].ready and enemy.health <= getDmg("R", enemy, myHero) and GetDistance(myHero, enemy) < SpellData[_R].range and (not SpellData[_E].ready) and (not SpellData[_Q].ready) and ValidTarget(enemy, SpellData[_R].range) then
			R:Cast(enemy)
		elseif Config.KS.useR and SpellData[_R].ready and enemy.health <= getDmg("R", enemy, myHero) and GetDistance(myHero, enemy) < SpellData[_R].range and GetDistance(myHero, enemy) > (SpellData[_E].range - 300) and ValidTarget(enemy, SpellData[_R].range) then
			R:Cast(enemy)
		elseif Config.KS.useE and SpellData[_E].ready and enemy.health <= getDmg("E", enemy, myHero) and GetDistance(enemy) < SpellData[_E].range and ValidTarget(enemy, SpellData[_E].range) then
			E:Cast(enemy)
		elseif Config.KS.useQ and SpellData[_Q].ready and enemy.health <= getDmg("Q", enemy, myHero) and GetDistance(enemy) < SpellData[_Q].range and ValidTarget(enemy, SpellData[_Q].range) and qColl <= 1 then
			Q:Cast(enemy)
		elseif Config.KS.useQ and Config.KS.useE and SpellData[_Q].ready and SpellData[_E].ready and enemy.health <= (getDmg("Q", enemy, myHero) + getDmg("E", enemy, myHero)) and GetDistance(enemy) < SpellData[_Q].range and ValidTarget(enemy, SpellData[_Q].range) and qColl <= 1 then
			Q:Cast(enemy)
			E:Cast(enemy)
		end
	end
	
end

function IsBinded(target)
	if target ~= nil then
	return HasBuff(target, "LuxLightBindingMis")
	end
end

function OnGainBuff(unit, buff)
	if unit and unit.valid and buff.name == 'LuxLightStrikeKugel' and unit == myHero then 
		CastSpell(_E)
	end
	
	if unit and unit == myHero and buff.name == 'Recall' then
		isRecalling = true
	end
	
	if unit and unit.valid and unit.type == myHero.type and GetDistance(myHero, unit) <= SpellData[_Q].range and (buff.type == BUFF_STUN or buff.type == BUFF_ROOT or buff.type == BUFF_KNOCKUP or buff.type == BUFF_SUPPRESS) then 
		if Q:IsReady() and Config.chainSub.useQchain and qColl <= 1 then
			Q:Cast(unit)
		end
		
		if E:IsReady() and Config.chainSub.useEchain then
			E:Cast(unit)
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit and unit == myHero and buff.name == 'Recall' then
		isRecalling = false
	end
end




