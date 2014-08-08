if myHero.charName ~= "Lux" then return end

require 'SourceLib'
require 'Prodiction'

--Variable Declarations
local passiveUsed = false
local Prodiction = ProdictManager.GetInstance()
local version = 0.5
local mTarget
local orbActive
local qColl
local TS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
local Config = nil
local isRecalling = false
local jungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
local enemyMinions = minionManager(MINION_ENEMY, 1500, myHero, MINION_SORT_HEALTH_ASC)
local SpellData = { 
	[_Q] = {
		name = "LuxLightBinding",
		ready = false,
		range = 1175,
		rangeSqr = math.pow(1175, 2),
		width = 80,
		speed = 1200,
		delay = 0.5
	},
	
	[_E] = {
		name = "LuxLightStrikeKugel",
		ready = false,
		range = 1000,
		rangeSqr = math.pow(1000, 2),
		width = 275,
		speed = 1300,
		delay = 0.5,
	},
	
	[_R] = {
		name = "LuxMaliceCannon",
		ready = false,
		range = 3340,
		rangeSqr = math.pow(3340, 2),
		width = 190,
		speed = math.huge,
		delay = 1.0
	},
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
	Config.chainSub:addParam("useEchain", "Use E", SCRIPT_PARAM_ONOFF, false)
	
--Combo options
Config:addSubMenu("Combo options", "ComboSub")
	Config.ComboSub:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
	Config.ComboSub:addParam("coPass", "Check for Passive before Cast", SCRIPT_PARAM_ONOFF, true) 
	Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("coQChance", "Combo Q Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })	
	Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("coEChance", "Combo E Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "Normal", "High", "Very High" })
	Config.ComboSub:addParam("forceR", "Force R on next CC", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
--[[	Config.ComboSub:addParam("useautoR", "Cast R if can hit X", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("count", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
]]	
--Harass options
Config:addSubMenu("Harass options", "HarassSub")
	Config.HarassSub:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
	Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.HarassSub:addParam("hrssChance", "Harass E Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	

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
	Config.LClearSub:addParam("useElclear", "Use E", SCRIPT_PARAM_ONOFF, true)

--KS
Config:addSubMenu("Kill Secure", "KS")
	Config.KS:addParam("active", "Kill Secure On/Off", SCRIPT_PARAM_ONOFF, true) 	
	Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksQChance", "KS Q Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "Normal", "High", "Very High" })	
	Config.KS:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksEChance", "KS E Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "Normal", "High", "Very High" })
	Config.KS:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksRChance", "KS R Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	
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
		mTarget = TS:GetTarget(SpellData[_R].range)
		qColl = CountObjectsOnLineSegment(myHero, Vector(mTarget), (SpellData[_Q].width + Config.mBuff), enemyMinions.objects)
		
		if ActivateE(myHero) or orbActive then
			ReactivateE()
		end
	
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
		
		if Config.ComboSub.forceR then
			ForceR()
		end
	end
end

function OnDraw()
	local onDtarget = mTarget
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
	local QTarget, Qinfo = ProdictionQ:GetPrediction(mTarget)
	local ETarget, Einfo = ProdictionE:GetPrediction(mTarget)
	
	if SpellData[_Q].ready and QTarget and Qinfo.hitchance >= Config.ComboSub.coQChance and qColl <= 1 and Config.ComboSub.useQ then
		if Config.ComboSub.coPass then
			if not HasPassive(mTarget) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif passiveUsed then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end			
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_Q, QTarget.x, QTarget.z)
		else
			CastSpell(_Q, QTarget.x, QTarget.z)
		end
	elseif SpellData[_E].ready and IsBinded(mTarget) and Config.ComboSub.useE then
		if Config.ComboSub.coPass then
			if not HasPassive(mTarget) then
				CastSpell(_E, mTarget.x, mTarget.z)
			elseif passiveUsed then
				CastSpell(_E, mTarget.x, mTarget.z)
			end			
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_E, mTarget.x, mTarget.z)
		else
			CastSpell(_E, mTarget.x, mTarget.z)
		end
	elseif SpellData[_E].ready and (not SpellData[_Q].ready) and ETarget and Einfo.hitchance >= Config.ComboSub.coEChance and Config.ComboSub.useE then
		if Config.ComboSub.coPass then
			if not HasPassive(mTarget) then
				CastSpell(_E, ETarget.x, ETarget.z)
			elseif passiveUsed then
				CastSpell(_E, ETarget.x, ETarget.z)
			end			
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_E, ETarget.x, ETarget.z)
		else
			CastSpell(_E, ETarget.x, ETarget.z)
		end
	end
end

function Harass()
	local ETarget, Einfo = ProdictionE:GetPrediction(mTarget)
	
	if SpellData[_E].ready and ETarget and Einfo.hitchance >= Config.HarassSub.hrssChance and Config.HarassSub.useE then
		if Config.ComboSub.coPass then
			if not HasPassive(mTarget) then
				CastSpell(_E, ETarget.x, ETarget.z)
			elseif passiveUsed then
				CastSpell(_E, ETarget.x, ETarget.z)
			end			
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_E, ETarget.x, ETarget.z)
		else
			CastSpell(_E, ETarget.x, ETarget.z)
		end
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
		local ETarget = ProdictionE:GetPrediction(enemyMinion)			
			if Config.LClearSub.useElclear and SpellData[_E].ready and ValidTarget(enemyMinion, SpellData[_E].range) then
				local eObj = CountObjectsNearPos(enemyMinion, nil, SpellData[_E].width, enemyMinions.objects)
				local tObj = CountObjectsNearPos(enemyMinion, nil, 800, enemyMinions.objects)	
				
				if ETarget and eObj >= tObj*0.60 and eObj > 2 then
					CastSpell(_E, ETarget.x, ETarget.z)	
				end
			end
		end
	end
end

function ReactivateE() 
	if mTarget then
		if Config.ComboSub.coPass then
			for _,Target in pairs(GetEnemyHeroes()) do
				if Target.name == mTarget.name and not HasPassive(mTarget) then
					CastSpell(_E)
				elseif passiveUsed then
					CastSpell(_E)
				end
			end
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_E)
		else
			CastSpell(_E)
		end
	elseif passiveUsed then
		CastSpell(_E)		
	else
		CastSpell(_E)
	end	
end

function OnGainBuff(unit, buff)
	if unit and unit == myHero and buff.name == 'Recall' then
		isRecalling = true
	end
	
	if unit and unit == mTarget and buff.name == 'luxilluminatingfraulein' then
		passiveUsed = false
	end
	
	if unit and unit.valid and unit.type == myHero.type and unit.team~= myHero.team and GetDistanceSqr(myHero, unit) <= (SpellData[_R].rangeSqr) and (buff.type == BUFF_STUN or buff.type == BUFF_ROOT or buff.type == BUFF_KNOCKUP or buff.type == BUFF_SUPPRESS) then 
		local QTarget = ProdictionQ:GetPrediction(unit)
		local ETarget = ProdictionE:GetPrediction(unit)
		local RTarget = ProdictionR:GetPrediction(unit)
		
		if Config.ComboSub.forceR and SpellData[_R].ready and unit and mTarget and mTarget.name == unit.name then
			CastSpell(_R, mTarget.x, mTarget.z)
		end
		
		if QTarget and SpellData[_Q].ready and Config.chainSub.useQchain and qColl <= 1 then
			if Config.ComboSub.coPass then
				if not HasPassive(mTarget) then
					CastSpell(_Q, QTarget.x, QTarget.z)
				end
			else
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
		end
		
		if ETarget and SpellData[_E].ready and Config.chainSub.useEchain then
			if Config.ComboSub.coPass then
				if not HasPassive(mTarget) then
					CastSpell(_E, ETarget.x, ETarget.z)
				end
			else
				CastSpell(_E, ETarget.x, ETarget.z)
			end
		end
	end
end

function OnLoseBuff(unit, buff) 
	if unit and unit == myHero and buff.name == 'Recall' then
		isRecalling = false
	end

	if unit and mTarget and unit.name == mTarget.name and buff.name == 'luxilluminatingfraulein' then
		passiveUsed = true
	end
end

function IsBinded(target) 
	if target ~= nil then
		return HasBuff(target, "LuxLightBindingMis")
	end
end

function HasPassive(target)
	if target ~= nil then
		return HasBuff(target, "luxilluminatingfraulein")
	end
end

function ActivateE(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "LuxLightStrikeKugel")
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

function GetTotalDmg(enemy)
	if enemy ~= nil then
		local getDamage = {}
		getDamage.Q = getDmg("Q", enemy, myHero) * 0.97
		getDamage.E = getDmg("E", enemy, myHero) * 0.97
		getDamage.R = ((SpellData[_R].ready and getDmg("R", enemy, myHero)) or 0) * 0.97
		
		getDamage.total = (getDamage.Q + getDamage.E + getDamage.R) * 0.97
		return getDamage
	end
end

function KillSteal() 
	if isRecalling or (not Config.KS.active) then return end

	for _,enemy in pairs(GetEnemyHeroes()) do
		local QTarget, Qinfo = ProdictionQ:GetPrediction(enemy)
		local ETarget, Einfo = ProdictionE:GetPrediction(enemy)
		local RTarget, Rinfo = ProdictionR:GetPrediction(enemy)
		local ksDmg = GetTotalDmg(enemy)
		
		if ValidTarget(enemy, SpellData[_Q].range) then	
			if ksDmg.Q > enemy.health then	
				if SpellData[_Q].ready and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z) 
					return
				end	
			elseif IsBinded(mTarget) and ksDmg.E > enemy.health then
				if SpellData[_E].ready and Config.KS.useE then
					CastSpell(_E, mTarget.x, mTarget.z)
					return
				end					
			elseif (not SpellData[_Q].ready) and ksDmg.E > enemy.health then
				if SpellData[_E].ready and ETarget and Einfo.hitchance >= Config.KS.ksEChance and Config.KS.useE then
					CastSpell(_E, ETarget.x, ETarget.z)
					return
				end			
			elseif (ksDmg.Q + ksDmg.E) > enemy.health then
				if SpellData[_E].ready and SpellData[_Q].ready and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end
			elseif IsBinded(mTarget) and ksDmg.R > enemy.health then
				if SpellData[_R].ready and Config.KS.useR then
					CastSpell(_R, mTarget.x, mTarget.z)
					return
				end					
			elseif (not SpellData[_Q].ready) and ksDmg.R > enemy.health then
				if SpellData[_R].ready and RTarget and Rinfo.hitchance >= Config.KS.ksRChance and Config.KS.useR then
					CastSpell(_R, RTarget.x, RTarget.z)
					return
				end				
			elseif (ksDmg.Q + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_Q].ready and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end
			elseif IsBinded(mTarget) and (ksDmg.E + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_E].ready and Config.KS.useR and Config.KS.useE then
						CastSpell(_E, mTarget.x, mTarget.z)
						CastSpell(_R, mTarget.x, mTarget.z)
					return
				end	
			elseif (ksDmg.E + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_E].ready and Einfo.hitchance >= Config.KS.ksEChance and Rinfo.hitchance >= Config.KS.ksRChance and ETarget and RTarget and Config.KS.useR and Config.KS.useE then
						CastSpell(_E, ETarget.x, ETarget.z)
						CastSpell(_R, RTarget.x, RTarget.z)
					return
				end	
			elseif ksDmg.total > enemy.health then
				if SpellData[_Q].ready and SpellData[_E].ready and SpellData[_R].ready and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
						CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end	
			end	
		elseif ValidTarget(enemy, SpellData[_R].range) and ((GetDistanceSqr(enemy) > SpellData[_E].rangeSqr) or ( not SpellData[_Q].ready and not SpellData[_E].ready)) then
			if ksDmg.R > enemy.health then
				if SpellData[_R].ready and RTarget and Rinfo.hitchance >= (Config.KS.ksRChance - 1) and Config.KS.useR then
						CastSpell(_R, RTarget.x, RTarget.z)
					return
				end
			end
		end
	end
end

function ForceR()
	if SpellData[_R].ready and IsBinded(mTarget) then
		CastSpell(_R, mTarget.x, mTarget.z)
  end
end 
	





		
		
		
		
		
		
		
		
		
		
		
		
		
		
