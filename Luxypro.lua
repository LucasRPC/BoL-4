if myHero.charName ~= "Lux" then return end

require 'SourceLib'
require 'Prodiction'

--Variable Declarations
local passiveUsed = false
local Prodiction = ProdictManager.GetInstance()
local version = 0.6
local mTarget
local orbActive
local collTime 
local qCollstart = 0
local ultPos 
local hCollision = {}
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
local ProdictionQ = Prodiction:AddProdictionObject(_Q, SpellData[_Q].range, SpellData[_Q].speed, SpellData[_Q].delay, SpellData[_R].width)
local ProdictionE = Prodiction:AddProdictionObject(_E, SpellData[_E].range, SpellData[_E].speed, SpellData[_E].delay, (SpellData[_E].width * 2))
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
	Config.ComboSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)
	
--Harass options
Config:addSubMenu("Harass options", "HarassSub")
	Config.HarassSub:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
	Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.HarassSub:addParam("hrssChance", "Harass E Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	Config.HarassSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 40, 0, 100)

--Ultimate Options
Config:addSubMenu("Final Spark Options", "UltSub")
	Config.UltSub:addParam("useautoR", "Cast R if can hit X", SCRIPT_PARAM_ONOFF, true)	
	Config.UltSub:addParam("count", "X = ", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
	Config.UltSub:addParam("forceR", "Force R on Target:", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	Config.UltSub:addParam("", "Will wait for bind if Combo is active, if", SCRIPT_PARAM_INFO, "")
	Config.UltSub:addParam("", "used alone will ult when hitchance is met.", SCRIPT_PARAM_INFO, "")	
	Config.UltSub:addParam("ultChance", "Force R Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })	

--Draw Target
Config:addSubMenu("Draw Target", "TargetSub")
	Config.TargetSub:addParam("drawTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)

--Jungle
Config:addSubMenu("Jungle Clear", "JungleSub")
	Config.JungleSub:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Config.JungleSub:addParam("useQjclear", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.JungleSub:addParam("useEjclear", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.JungleSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)

--LaneClear
Config:addSubMenu("Lane Clear", "LClearSub")
	Config.LClearSub:addParam("lclr", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Config.LClearSub:addParam("useElclear", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.LClearSub:addParam("minM", "Required Mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)

--KS
Config:addSubMenu("Kill Secure", "KS")
	Config.KS:addParam("active", "Kill Secure On/Off", SCRIPT_PARAM_ONOFF, true) 	
	Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksQChance", "KS Q Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "Normal", "High", "Very High" })	
	Config.KS:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksEChance", "KS E Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "Normal", "High", "Very High" })
	Config.KS:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("ksRChance", "KS R Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
	
-- Target Selection
Config:addSubMenu("Target Selection", "sts")
	TS:AddToMenu(Config.sts)
	Config.sts:addParam("useOWTS", "Use SaC or MMA TS", SCRIPT_PARAM_ONOFF, false)
	
--Minion Buffer
Config:addParam("mBuff", "Minion Q Buffer", SCRIPT_PARAM_SLICE, 85, 50, 100, 0)
end

function Init()
--Lux Spells
Q = Spell(_Q, SpellData[_Q].range)
E = Spell(_E, SpellData[_E].range)
R = Spell(_R, SpellData[_R].range)

qCollduration = (Config.mBuff * 20)	
Loaded = true
end

function OnTick()
	if Loaded then
		enemyMinions:update()
		KillSteal()
		CDHandler()	
		GetCustomTarget()			

		
		if ActivateE(myHero) or orbActive then
			ReactivateE()
		end
	
		if Config.ComboSub.Combo then
			Combo()
			if Config.UltSub.forceR then
				ForceR()
			end
		end
		
		if Config.UltSub.useautoR and SpellData[_R].ready then
			AutoUlt()
		end
		
		if Config.HarassSub.Harass then
			Harass()
		end

		if Config.JungleSub.jclr then
			jungleMinions:update()	
			JungleClear()
		end		
		
		if Config.LClearSub.lclr then
			LaneClear()
		end
	
		if Config.UltSub.forceR and (not Config.ComboSub.Combo) then
			ForceRUnbinded()
		end
		
		if (not Config.ComboSub.Combo) and mTarget then
			qColl = CountObjectsOnLineSegment(myHero, Vector(mTarget.x, mTarget.z), (SpellData[_Q].width + Config.mBuff), enemyMinions.objects)
		end		
	end
end

function OnDraw()
		if qColl and qColl <= 1 then
			onDqCollcolor = ARGB(100, 35, 250, 11)
		end		
		if qColl and qColl > 1 then
			onDqCollcolor = ARGB(100, 124, 4, 4)
		end
	
	if myHero.dead then return end	
				
	if mTarget and (not mTarget.dead) and ValidTarget(mTarget, SpellData[_R].range) and Config.TargetSub.drawTarget then
		DrawLine3D(myHero.x, myHero.y, myHero.z, mTarget.x, mTarget.y, mTarget.z, 1, onDqCollcolor)
		DrawLineBorder3D(myHero.x, myHero.y, myHero.z, mTarget.x, mTarget.y, mTarget.z, 80, onDqCollcolor, 8)
		if mTarget.visible and not mTarget.dead then			
			for j=1, 25 do
				local ycircle = (j*(120/25*2)-120)
				local r = math.sqrt(120^2-ycircle^2)
				ycircle = ycircle/1.3
				DrawCircle(mTarget.x, mTarget.y+100+ycircle, mTarget.z, r, onDqCollcolor)				
			end		 
		end	
	end
end

function GetCustomTarget()
    if Config.sts.useOWTS and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair.target and _G.AutoCarry.Crosshair.Attack_Crosshair.target.type == myHero.type then 		
		mTarget = _G.AutoCarry.Crosshair.Attack_Crosshair.target
    elseif Config.sts.useOWTS and _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
		mTarget = _G.MMA_Target
    else
		mTarget = TS:GetTarget(SpellData[_R].range) 
	end
end

--Game Functions

function Combo()
	local QTarget, Qinfo = ProdictionQ:GetPrediction(mTarget)
	local ETarget, Einfo = ProdictionE:GetPrediction(mTarget)
	qColl = CountObjectsOnLineSegment(myHero, Vector(QTarget.x, QTarget.z), (SpellData[_Q].width + Config.mBuff), enemyMinions.objects)

	if mTarget and qColl > 1 then
		qCollstart = GetTickCount()
		collTime = false
	end

	if GetTickCount() > (qCollstart + qCollduration) then			
		collTime = true
	end	
	
	if SpellData[_Q].ready and QTarget and Qinfo.hitchance >= Config.ComboSub.coQChance and qColl <= 1 and collTime and Config.ComboSub.useQ and myManaPct() > Config.ComboSub.minM then
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
	elseif SpellData[_E].ready and IsBinded(mTarget) and Config.ComboSub.useE and myManaPct() > Config.ComboSub.minM then
		if Config.ComboSub.coPass then
			if (not HasPassive(mTarget)) or (not orbActive) then
				CastSpell(_E, mTarget.x, mTarget.z)
			elseif passiveUsed then
				CastSpell(_E, mTarget.x, mTarget.z)
			end			
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, mTarget) > (550 * 550) then
			CastSpell(_E, mTarget.x, mTarget.z)
		else
			CastSpell(_E, mTarget.x, mTarget.z)
		end
	elseif SpellData[_E].ready and (not SpellData[_Q].ready) and ETarget and Einfo.hitchance >= Config.ComboSub.coEChance and Config.ComboSub.useE and myManaPct() > Config.ComboSub.minM then
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
	
	if SpellData[_E].ready and ETarget and Einfo.hitchance >= Config.HarassSub.hrssChance and Config.HarassSub.useE and myManaPct() > Config.HarassSub.minM then
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
			if QTarget and Config.JungleSub.useQjclear and SpellData[_Q].ready and ValidTarget(jungleMinion, SpellData[_Q].range) and myManaPct() > Config.JungleSub.minM then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
	
			if ETarget and Config.JungleSub.useEjclear and SpellData[_E].ready and ValidTarget(jungleMinion, SpellData[_E].range) and myManaPct() > Config.JungleSub.minM then
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

function ReactivateE() 
	if mTarget and orbActive then	
		if Config.ComboSub.coPass then
			for _,Target in pairs(GetEnemyHeroes()) do
				if Target.name == mTarget.name and not HasPassive(mTarget) then
					CastSpell(_E)
				elseif passiveUsed then
					CastSpell(_E)
				end
			end
		elseif Config.ComboSub.coPass and GetDistanceSqr(myHero, orbActive) > (550 * 550) then
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

function KillSteal() 
	if isRecalling or (not Config.KS.active) then return end
		
	for _,enemy in pairs(GetEnemyHeroes()) do
		local QTarget, Qinfo = ProdictionQ:GetPrediction(enemy)
		local ETarget, Einfo = ProdictionE:GetPrediction(enemy)
		local RTarget, Rinfo = ProdictionR:GetPrediction(enemy)
		local ksDmg = GetTotalDmg(enemy)
		
		if ValidTarget(enemy, SpellData[_Q].range) and GetDistanceSqr(myHero, enemy) < SpellData[_Q].rangeSqr then	
			if ksDmg.Q > enemy.health then	
				if SpellData[_Q].ready and (Q:GetManaUsage() < myHero.mana) and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z) 
					return
				end	
			elseif IsBinded(mTarget) and ksDmg.E > enemy.health then
				if SpellData[_E].ready and (E:GetManaUsage() < myHero.mana) and Config.KS.useE then
					CastSpell(_E, mTarget.x, mTarget.z)
					return
				end					
			elseif (not SpellData[_Q].ready) and ksDmg.E > enemy.health then
				if SpellData[_E].ready and (E:GetManaUsage() < myHero.mana) and ETarget and Einfo.hitchance >= Config.KS.ksEChance and Config.KS.useE then
					CastSpell(_E, ETarget.x, ETarget.z)
					return
				end			
			elseif (ksDmg.Q + ksDmg.E) > enemy.health then
				if SpellData[_E].ready and SpellData[_Q].ready and ((E:GetManaUsage() + Q:GetManaUsage()) < myHero.mana) and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end
			elseif IsBinded(mTarget) and ksDmg.R > enemy.health then
				if SpellData[_R].ready and (R:GetManaUsage() < myHero.mana) and Config.KS.useR then
					CastSpell(_R, mTarget.x, mTarget.z)
					return
				end					
			elseif (not SpellData[_Q].ready) and ksDmg.R > enemy.health then
				if SpellData[_R].ready and (R:GetManaUsage() < myHero.mana) and RTarget and Rinfo.hitchance >= Config.KS.ksRChance and Config.KS.useR then
					CastSpell(_R, RTarget.x, RTarget.z)
					return
				end				
			elseif (ksDmg.Q + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_Q].ready and ((R:GetManaUsage() + Q:GetManaUsage()) < myHero.mana) and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
					CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end
			elseif IsBinded(mTarget) and (ksDmg.E + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_E].ready and ((E:GetManaUsage() + R:GetManaUsage()) < myHero.mana) and Config.KS.useR and Config.KS.useE then
						CastSpell(_E, mTarget.x, mTarget.z)
						CastSpell(_R, mTarget.x, mTarget.z)
					return
				end	
			elseif (ksDmg.E + ksDmg.R) > enemy.health then
				if SpellData[_R].ready and SpellData[_E].ready and ((E:GetManaUsage() + R:GetManaUsage()) < myHero.mana) and ETarget and RTarget and Einfo.hitchance >= Config.KS.ksEChance and Rinfo.hitchance >= Config.KS.ksRChance and Config.KS.useR and Config.KS.useE then
						CastSpell(_E, ETarget.x, ETarget.z)
						CastSpell(_R, RTarget.x, RTarget.z)
					return
				end	
			elseif ksDmg.total > enemy.health then
				if SpellData[_Q].ready and SpellData[_E].ready and SpellData[_R].ready and ((E:GetManaUsage() + Q:GetManaUsage() + R:GetManaUsage()) < myHero.mana) and QTarget and Qinfo.hitchance >= Config.KS.ksQChance and Config.KS.useQ and qColl <= 1 then
						CastSpell(_Q, QTarget.x, QTarget.z)
					return
				end	
			end	
		elseif ValidTarget(enemy, SpellData[_R].range) and ((GetDistanceSqr(enemy) > SpellData[_E].rangeSqr) or ( not SpellData[_Q].ready and not SpellData[_E].ready)) then
			if ksDmg.R > enemy.health then
				if SpellData[_R].ready and (R:GetManaUsage() < myHero.mana) and RTarget and Rinfo.hitchance >= Config.KS.ksRChance and Config.KS.useR then
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

function ForceRUnbinded()
	local RTarget, Rinfo = ProdictionR:GetPrediction(mTarget)	
	if SpellData[_R].ready and RTarget and Rinfo.hitchance >= Config.UltSub.ultChance then
		CastSpell(_R, RTarget.x, RTarget.z)
  end
end 

function AutoUlt()
	if mTarget then
	hCollision = {}
	ultPos = GenerateLineSegmentFromCastPosition(myHero, mTarget, SpellData[_R].range)
	local ultCount = GetHeroCollision(myHero, ultPos, HERO_ENEMY)
		if ultCount then
			CastSpell(_R, mTarget.x, mTarget.z)
		end
	end
end

--Helpers
		
function CDHandler()
	SpellData[_Q].ready = (myHero:CanUseSpell(_Q) == READY)
	SpellData[_E].ready = (myHero:CanUseSpell(_E) == READY)
	SpellData[_R].ready = (myHero:CanUseSpell(_R) == READY)
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
		
		if Config.UltSub.forceR and SpellData[_R].ready and ValidTarget(RTarget, SpellData[_R].range) and unit and mTarget and mTarget.name == unit.name then
			CastSpell(_R, mTarget.x, mTarget.z)
		end
		
		if QTarget and SpellData[_Q].ready and ValidTarget(QTarget, SpellData[_Q].range) and Config.chainSub.useQchain and qColl <= 1 then
			if Config.ComboSub.coPass then
				if not HasPassive(mTarget) then
					CastSpell(_Q, QTarget.x, QTarget.z)
				end
			else
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
		end
		
		if ETarget and SpellData[_E].ready and ValidTarget(ETarget, SpellData[_R].range) and Config.chainSub.useEchain then
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

function ActivateE(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "LuxLightStrikeKugel")
	end
end

function HasPassive(target)
	if target ~= nil then
		return HasBuff(target, "luxilluminatingfraulein")
	end
end		
		
function IsBinded(target) 
	if target ~= nil then
		return HasBuff(target, "LuxLightBindingMis")
	end
end		
		
function GenerateLineSegmentFromCastPosition(CastPosition, FromPosition, SkillShotRange) --From LineSkillShotPosition.lua by dienofail
    local MaxEndPosition = CastPosition + (-1 * (Vector(CastPosition.x - FromPosition.x, 0, CastPosition.z - FromPosition.z):normalized()*SkillShotRange))
    return MaxEndPosition
end		
		
function GetHeroCollision(pStart, pEnd, mode) --From Collision 1.1.1 by Klokje
        if mode == nil then mode = HERO_ENEMY end
        local heros = {}
 
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if (mode == HERO_ENEMY or mode == HERO_ALL) and hero.team ~= myHero.team then
                table.insert(heros, hero)
            elseif (mode == HERO_ALLY or mode == HERO_ALL) and hero.team == myHero.team and not hero.isMe then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetDistance(pStart, pEnd)
        local prediction = ProdictionR
		
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
                    local pos, t, vec  = prediction:GetPrediction(hero)
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

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end


