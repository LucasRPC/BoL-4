if myHero.charName ~= "Lux" then return end

require 'SourceLib'
require 'Prodiction'

--Variable Declarations
local Prodiction = ProdictManager.GetInstance()
local version = 0.3
local mTarget
local qColl
local qLCColl
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
local ProdictionQ = Prodiction:AddProdictionObject(_Q, SpellData[_Q].range, SpellData[_Q].speed, SpellData[_Q].delay, SpellData[_R].width)
local ProdictionE = Prodiction:AddProdictionObject(_E, SpellData[_E].range, SpellData[_E].speed, SpellData[_E].delay, SpellData[_E].width)
local ProdictionR = Prodiction:AddProdictionObject(_R, SpellData[_R].range, SpellData[_R].speed, SpellData[_R].delay, SpellData[_R].width)

--Script Setup

function OnLoad()
	ScriptSetUp()
	Init()
	PrintChat("<font color=\"#FF6600\">[Luxypoo!]</font> <font color=\"#FFFFFF\">Script loaded. Running version v"..version.."pro.</font>")
end

function ScriptSetUp()
Config = scriptConfig("Luxypoo v"..version.."pro", "Luxypoo v"..version.."pro")

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
	local QTarget = ProdictionQ:GetPrediction(mTarget)
	local ETarget = ProdictionE:GetPrediction(mTarget)
	local RTarget = ProdictionR:GetPrediction(mTarget)
	if QTarget and mTarget and Q:IsReady() and Config.ComboSub.useQ and qColl <= 1 and GetDistance(myHero, mTarget) < (SpellData[_Q].range - 75) then 
		CastSpell(_Q, QTarget.x, QTarget.z)
	end 

	if mTarget and E:IsReady() and ETarget and GetDistance(myHero, mTarget) < SpellData[_E].range and Config.ComboSub.useE then
		CastSpell(_E, ETarget.x, ETarget.z)
	end
		
	for _,enemy in pairs(GetEnemyHeroes()) do
		if enemy and mTarget and enemy.name == mTarget.name and R:IsReady() and RTarget and IsBinded(mTarget) and Config.ComboSub.useR and (100 + enemy.health) <= getDmg("R", enemy, myHero) and GetDistance(myHero, mTarget) < SpellData[_R].range then 
			CastSpell(_R, RTarget.x, RTarget.z)
		end	
	end
end


function Harass()
	local QTarget = ProdictionQ:GetPrediction(mTarget)
	local ETarget = ProdictionE:GetPrediction(mTarget)

	if QTarget and mTarget and Q:IsReady() and Config.HarassSub.useQ and qColl <= 1 and GetDistance(myHero, mTarget) < (SpellData[_Q].range - 75) then 
		CastSpell(_Q, QTarget.x, QTarget.z)
	end 
		
	if E:IsReady() and ETarget and mTarget and Config.HarassSub.useE and GetDistance(myHero, mTarget) < SpellData[_E].range then 
		CastSpell(_E, ETarget.x, ETarget.z)
	end
end 

function JungleClear()
	for i, jungleMinion in pairs(jungleMinions.objects) do 
		if jungleMinion ~= nil then	
		local QTarget = ProdictionQ:GetPrediction(jungleMinion)
		local ETarget = ProdictionE:GetPrediction(jungleMinion)		
			if QTarget and Config.JungleSub.useQjclear and SpellData[_Q].ready and ValidTarget(jungleMinion, SpellData[_Q].range) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
	
			if ETarget and Config.JungleSub.useEjclear and SpellData[_E].ready and ValidTarget(jungleMinion, SpellData[_E].range) then
				local jObj = CountObjectsNearPos(Vector(jungleMinion), nil, SpellData[_E].width, jungleMinions.objects)
				local jtObj = CountObjectsNearPos(Vector(jungleMinion), nil, 600, jungleMinions.objects)
				if jObj == jtObj then
					CastSpell(_E, ETarget.x, ETarget.z)
				end
			end
		end
	end
end

function LaneClear()


	for i, enemyMinion in pairs(enemyMinions.objects) do
		if enemyMinion ~= nil then
		local QTarget = ProdictionQ:GetPrediction(enemyMinion)
		local ETarget = ProdictionE:GetPrediction(enemyMinion)	
			qLCColl = CountObjectsOnLineSegment(myHero, Vector(enemyMinion), (SpellData[_Q].width + 50), enemyMinions.objects)	
			if QTarget and Config.LClearSub.useQlclear and SpellData[_Q].ready and ValidTarget(enemyMinion, SpellData[_Q].range) and getDmg("Q", enemyMinion, myHero) > enemyMinion.health and qLCColl == 2 then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
			
			if Config.LClearSub.useElclear and SpellData[_E].ready and ValidTarget(enemyMinion, SpellData[_E].range) then
				local eObj = CountObjectsNearPos(enemyMinion, nil, SpellData[_E].width, enemyMinions.objects)
				local tObj = CountObjectsNearPos(enemyMinion, nil, 550, enemyMinions.objects)	
				
				if ETarget and eObj >= tObj*0.55 and eObj > 2 then
					CastSpell(_E, ETarget.x, ETarget.z)	
				end
			end
		end
	end
end

function KillSteal()
	if isRecalling or (not Config.KS.active) then return end
	
	for _,enemy in pairs(GetEnemyHeroes()) do
		local QTarget = ProdictionQ:GetPrediction(enemy)
		local ETarget = ProdictionE:GetPrediction(enemy)
		local RTarget = ProdictionR:GetPrediction(enemy)

		if RTarget and Config.KS.useR and SpellData[_R].ready and enemy.health <= getDmg("R", enemy, myHero) and GetDistance(myHero, enemy) < SpellData[_R].range and (not SpellData[_E].ready) and (not SpellData[_Q].ready) and ValidTarget(enemy, SpellData[_R].range) then
			CastSpell(_R, RTarget.x, RTarget.z)
		elseif RTarget and Config.KS.useR and SpellData[_R].ready and enemy.health <= getDmg("R", enemy, myHero) and GetDistance(myHero, enemy) < SpellData[_R].range and GetDistance(myHero, enemy) > (SpellData[_E].range) and ValidTarget(enemy, SpellData[_R].range) then
			CastSpell(_R, RTarget.x, RTarget.z)
		elseif ETarget and Config.KS.useE and SpellData[_E].ready and enemy.health <= getDmg("E", enemy, myHero) and GetDistance(enemy) < SpellData[_E].range and ValidTarget(enemy, SpellData[_E].range) then
			CastSpell(_E, ETarget.x, ETarget.z)	
		elseif QTarget and Config.KS.useQ and SpellData[_Q].ready and enemy.health <= getDmg("Q", enemy, myHero) and GetDistance(enemy) < SpellData[_Q].range and ValidTarget(enemy, SpellData[_Q].range) and qColl <= 1 then
			CastSpell(_Q, QTarget.x, QTarget.z)
		elseif QTarget and ETarget and Config.KS.useQ and Config.KS.useE and SpellData[_Q].ready and SpellData[_E].ready and enemy.health <= (getDmg("Q", enemy, myHero) + getDmg("E", enemy, myHero)) and GetDistance(enemy) < SpellData[_Q].range and ValidTarget(enemy, SpellData[_Q].range) and qColl <= 1 then
			CastSpell(_Q, QTarget.x, QTarget.z)
			CastSpell(_E, ETarget.x, ETarget.z)	
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
		local QTarget = ProdictionQ:GetPrediction(unit)
		local ETarget = ProdictionE:GetPrediction(unit)
		if QTarget and Q:IsReady() and Config.chainSub.useQchain and qColl <= 1 then
			CastSpell(_Q, QTarget.x, QTarget.z)
		end
		
		if ETarget and E:IsReady() and Config.chainSub.useEchain then
			CastSpell(_E, ETarget.x, ETarget.z)
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit and unit == myHero and buff.name == 'Recall' then
		isRecalling = false
	end
end
