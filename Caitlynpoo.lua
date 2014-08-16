--[[                                                               ------------------------Script Core------------------------]]

if myHero.charName ~= "Caitlyn" then return end

require "SourceLib"
require "Prodiction"
require "VPrediction"
require "SOW"

local TS = SimpleTS(NEAR_MOUSE)
local QAble, EAble, RAble = false, false
local rDmg
local rRange = nil
local Prodiction = ProdictManager.GetInstance()
local ProdictionQ
local VP = nil
local version = 0.1

function Menu()
Config = scriptConfig("Caitlynpoo", "Caitlynpoo")
Config:addParam("onoff", "AutoTrap", SCRIPT_PARAM_ONOFF, true)
Config:addParam("AGConoff", "AntiGapClose", SCRIPT_PARAM_ONOFF, true)
Config:addParam("agptrap", "Use trap with AGP", SCRIPT_PARAM_ONOFF, false)
Config:addParam("net", "E to Mouse", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
Config:addParam("kill", "R Killshot", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
Config:addParam("usepro", "Use Prodiction Q", SCRIPT_PARAM_ONOFF, false)
Config:addParam("pmaker", "Q Not Mana-Managed", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
Config:addParam("pmaker2", "Q Mana-Managed", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
Config:addParam("minM", "Mana Manager %", SCRIPT_PARAM_SLICE, 50, 0, 100)
Config:addParam("vphit", "Q - VPrediction Hitchance", SCRIPT_PARAM_LIST, 2, { "Low", "High", "Target Slowed", "Immobile", "Dashing" })
Config:addParam("prohit", "Q - Prodiction Hitchance", SCRIPT_PARAM_LIST, 3, { "Low", "Normal", "High", "Very High" })
Config:addParam("sacmode", "SaC Mode", SCRIPT_PARAM_ONOFF, false)
Config:addSubMenu("Simple OrbWalker", "sow")
Orbwalker:LoadToMenu(Config.sow)
end

function OnLoad()
	ProdictionQ = Prodiction:AddProdictionObject(_Q, 1300, 2200, 0.250, 90)
	VP = VPrediction()
	Orbwalker = SOW(VP)
	PrintChat("<font color=\"#FF6600\">[Caitlynpoo!]</font> <font color=\"#FFFFFF\">Script loaded. Running version v"..version..".</font>")
	Menu()	
end

function OnTick()
	Checks()
	
	if Config.usepro and Config.pmaker then
		PeacemakerPRO()
	end
	
	if (not Config.usepro) and Config.pmaker then
		Peacemaker()
	end
	
	if Config.usepro and Config.pmaker2 and myManaPct() > Config.minM then
		PeacemakerPRO()
	end
	
	if (not Config.usepro) and Config.pmaker2 and myManaPct() > Config.minM then
		Peacemaker()
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
	
	if (not Config.pmaker) and Config.net then
		NetToMouse()
	end
	
	if Config.sacmode then
		HeadShot()
	end
end

--[[                                                               ------------------------Game Functions------------------------]]
function NetToMouse()
         if EAble and Config.net then
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
	
    if Config.sacmode and _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair and _G.AutoCarry.Crosshair.Attack_Crosshair.target and _G.AutoCarry.Crosshair.Attack_Crosshair.target.type == myHero.type then 		
		mTarget = _G.AutoCarry.Crosshair.Attack_Crosshair.target
	else
		mTarget = TS:GetTarget(1300) 
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
        if ValidTarget(Enemy, rRange, true) and Config.kill and (Enemy.health + 60) < rDmg then
        CastSpell(_R, Enemy) end
    end
end

function Peacemaker()
	if mTarget then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(mTarget, 0.632, 90, 1300, 2225, myHero)
		if QAble and HitChance >= Config.vphit and GetDistanceSqr(CastPosition) < 1690000 then
			if Config.sacmode and _G.AutoCarry.Orbwalker:IsAfterAttack() then			
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			elseif (not Config.sacmode) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function PeacemakerPRO()
	if mTarget then
        local QTarget, Qinfo = ProdictionQ:GetPrediction(mTarget)
        if QAble and Qinfo.hitchance >= Config.prohit and GetDistanceSqr(QTarget) < 1690000 then 
			if Config.sacmode and _G.AutoCarry.Orbwalker:IsAfterAttack() then
				CastSpell(_Q, QTarget.x, QTarget.z)
			elseif (not Config.sacmode) then
				CastSpell(_Q, QTarget.x, QTarget.z)
			end
    	end
	end
end

function HasPassive(unit)
	if unit and unit.isMe then
		return HasBuff(unit, "caitlynheadshot")
	end
end

function HeadShot()
	if HasPassive(myHero) and _G.AutoCarry.Plugins then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(PassiveDmg())
	elseif _G.AutoCarry and _G.AutoCarry.Plugins and (not HasPassive(myHero)) then
		_G.AutoCarry.Plugins:RegisterBonusLastHitDamage(NoPassive())
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end
function PassiveDmg() return ((_G.AutoCarry.MyHero:GetTotalAttackDamageAgainstTarget(_G.AutoCarry.Minions.EnemyMinions)) * 1.7) end
function NoPassive() return 0 end

--[[                                                               ------------------------Not So Simple AutoTrap------------------------
AutoTrap CC support for: Amumu, Elise, J4, Jax, Nautilus, Pantheon, Warwick, Udyr, Vi, Ahri, Anivia, Lissandra, Sion, Syndra, Swain, Viktor, Vel'Koz, Veigar, TwistedFate, Xerath, Yasuo, Blitzcrank, Braum,
Karma, Leona, Morganna, Nami, Taric, Thresh, Zyra, Alistar, Brand, Aatrox, Cho'Gath, Irelia, Maokai, Shen, Ryze, Riven, Renekton, Janna, Gragas, Rammus]]

function CastW()
	if mTarget and (AhriE(mTarget) or BlitzE(mTarget) or BraumP(mTarget) or ChoGathQ(mTarget) or EliseE(mTarget) or FiddleQ(mTarget) or JannaQ(mTarget) or KarmaW(mTarget) or LuxQ(mTarget) or LissandraW(mTarget) or MaokaiW(mTarget)
	or MorgQ(mTarget) or NamiQ(mTarget) or NautilusQ(mTarget) or RyzeW(mTarget) or ShenE(mTarget) or StunALL(mTarget) or SwainW(mTarget) or ThreshQ(mTarget) or VelKozE(mTarget) or ViR(mTarget) or ViktorW(mTarget) or WarwickR(mTarget) 
	or YasuoQ(mTarget) or ZyraE(mTarget)) then
		CastSpell(_W, mTarget.x, mTarget.z)
	end
end

function AatroxQ(target)
	if target ~= nil then
	return HasBuff(target, "aatroxqknockup")
	end
end

function AhriE(target)
	if target ~= nil then
	return HasBuff(target, "ahriseducedoom")
	end
end

function BlitzE(target)
	if target ~= nil then
	return HasBuff(target, "powerfistslow")
	end
end

function BraumP(target)
	if target ~= nil then
	return HasBuff(target, "braumstundebuff")
	end
end

function ChoGathQ(target)
	if target ~= nil then
	return HasBuff(target, "rupturetarget")
	end
end

function EliseE(target)
	if target ~= nil then
	return HasBuff(target, "EliseHumanE")
	end
end

function FiddleQ(target)
	if target ~= nil then
	return HasBuff(target, "Flee")
	end
end

function JannaQ(target)
	if target ~= nil then
	return HasBuff(target, "HowlingGaleSpell")
	end
end

function JarvanEQ(target)
	if target ~= nil then
	return HasBuff(target, "jarvanivdragonstrikeph2")
	end
end

function KarmaW(target)
	if target ~= nil then
	return HasBuff(target, "karmaspiritbindroot")
	end
end

function LuxQ(target)
	if target ~= nil then
	return HasBuff(target, "LuxLightBindingMis")
	end
end

function LissandraW(target)
	if target ~= nil then
	return HasBuff(target, "lissandrawfrozen")
	end
end

function MaokaiW(target)
	if target ~= nil then
	return HasBuff(target, "maokaiunstablegrowthroot")
	end
end

function MorgQ(target)
	if target ~= nil then
	return HasBuff(target, "DarkBindingMissile")
	end
end

function NamiQ(target)
	if target ~= nil then
	return HasBuff(target, "namiqdebuff")
	end
end

function NautilusQ(target)
	if target ~= nil then
	return HasBuff(target, "nautilusanchordragroot")
	end
end

function RyzeW(target)
	if target ~= nil then
	return HasBuff(target, "RunePrison")
	end
end

function ShenE(target) -- RammusE
	if target ~= nil then
	return HasBuff(target, "Taunt")
	end
end

function StunALL(target) -- LeonaQ, TaricE, AlistarQ, BrandQ, AmumuQ, JaxE, UdyrE, PantheonW, AniviaQ, SionQ, VeigarE, IreliaE, RenektonW, SyndraQE, TwistedFateGoldCard, XerathE, AnnieP, RivenW, Gragas E, MorgannaR + more..
	if target ~= nil then
	return HasBuff(target, "Stun")
	end
end

function SwainW(target)
	if target ~= nil then
	return HasBuff(target, "swainshadowgrasproot")
	end
end	

function ThreshQ(target)
	if target ~= nil then
	return HasBuff(target, "threshqfakeknockup")
	end
end

function VelKozE(target)
	if target ~= nil then
	return HasBuff(target, "velkozestun")
	end
end

function ViR(target)
	if target ~= nil then
	return HasBuff(target, "virdunkstun")
	end
end

function ViktorW(target)
	if target ~= nil then
	return HasBuff(target, "viktorgravitonfieldstun")
	end
end

function WarwickR(target)
	if target ~= nil then
	return HasBuff(target, "suppression")
	end
end

function YasuoQ(target)
	if target ~= nil then
	return HasBuff(target, "yasuoq3mis")
	end
end

function ZyraE(target)
	if target ~= nil then
	return HasBuff(target, "zyragraspingrootshold")
	end
end


--[[                                                               ------------------------Not So Simple AGC------------------------
AntiGapClose support for: Aatrox, Alistar, Ahri, Corki, Fiora, Graves, Leblanc, Gragas, J4, LeeSin, Malphite, Yasuo, Diana, Hecarim, Riven, Shen, Volibear, Quinn, Zac, Sejuani, Renekton, Vi, Wukong, Ezreal, Leona, 
Khazix, Lucian, Nautilus, Tryndamere, Nidalee, XinZhao, Yasuo, Maokai, Poppy, Jax, Pantheon, Thresh, Irelia]]

function OnProcessSpell(unit, spell)
	if unit.charName == ("Ezreal") and spell.name == ("EzrealArcaneShift") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, spell.endPos.x, spell.endPos.z)
	end
	
	if unit.charName == ("Alistar") and spell.name == ("Headbutt") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end

	if unit.charName == ("Yasuo") and spell.name == ("YasuoDashWrapper") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == ("Malphite") and spell.name == ("UFSlash") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == ("Diana") and spell.name == ("DianaTeleport") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == ("Hecarim") and spell.name == ("HecarimUlt") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == ("Leona") and spell.name == ("LeonaZenithBlade") and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end	
	
	if unit.charName == "Khazix" and spell.name == "KhazixE" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end	
	
	if unit.charName == "Lucian" and spell.name == "LucianE" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, spell.endPos.x, spell.endPos.z)
	end	
	
	if unit.charName == "Nautilus" and spell.name == "NautilusAnchorDrag" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Tryndamere" and spell.name == "slashCast" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Nidalee" and spell.name == "Pounce" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "XinZhao" and spell.name == "XenZhaoSweep" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Maokai" and spell.name == "MaokaiUnstableGrowth" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Poppy" and spell.name == "PoppyHeroicCharge" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
		
	if unit.charName == "Jax" and spell.name == "JaxLeapStrike" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Pantheon" and spell.name == "PantheonW" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Thresh" and spell.name == "threshqleap" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
	
	if unit.charName == "Irelia" and spell.name == "IreliaGatotsu" and GetDistanceSqr(myHero, spell.endPos) <= 90000 then
		CastSpell(_E, unit.x, unit.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
end
	
function AGCCastE()
	if mTarget and (AGCAatroxQ(mTarget) or AGCAhriR(mTarget) or AGCCorkiW(mTarget) or AGCFioraQ(mTarget) or AGCGragasE(mTarget) or AGCGravesE(mTarget) or AGCJ4EQ(mTarget) or AGCLeblancW(mTarget) 
	or AGCLeeSinQ(mTarget) or AGCQuinnE(mTarget) or AGCRenektonE(mTarget) or AGCRiven(mTarget) or AGCSejuaniQ(mTarget) or AGCShenE(mTarget) or AGCViQ(mTarget) or AGCVolibearQ(mTarget) or AGCWukongE(mTarget) 
	or AGCZacE(mTarget)) and GetDistanceSqr(myHero, mTarget) <= 250000 then
		CastSpell(_E, mTarget.x, mTarget.z)
		if Config.AGCtrap then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
end

function AGCAatroxQ(target)
	if target ~= nil then
	return HasBuff(target, "aatroxqdescent")
	end
end

function AGCAhriR(target)
	if target ~= nil then
	return HasBuff(target, "AhriTumble")
	end
end

function AGCCorkiW(target)
	if target ~= nil then
	return HasBuff(target, "valkyriesound")
	end
end

function AGCFioraQ(target)
	if target ~= nil then
	return HasBuff(target, "fiorqcd")
	end
end

function AGCGravesE(target)
	if target ~= nil then
	return HasBuff(target, "gravesmovesteroid")
	end
end

function AGCLeblancW(target)
	if target ~= nil then
	return HasBuff(target, "LeblancSlide")
	end
end

function AGCGragasE(target)
	if target ~= nil then
	return HasBuff(target, "GragasE")
	end
end

function AGCJ4EQ(target)
	if target ~= nil then
	return HasBuff(target, "jarvanivdragonstrikeph")
	end
end

function AGCLeeSinQ(target)
	if target ~= nil then
	return HasBuff(target, "blindmonkqtwodash")
	end
end

function AGCRiven(target)
	if target ~= nil then
	return HasBuff(target, "RivenTriCleave")
	end
end

function AGCShenE(target)
	if target ~= nil then
	return HasBuff(target, "ShenShadowDash")
	end
end

function AGCVolibearQ(target)
	if target ~= nil then
	return HasBuff(target, "VolibearQ")
	end
end

function AGCQuinnE(target)
	if target ~= nil then
	return HasBuff(target, "QuinnE")
	end
end

function AGCZacE(target)
	if target ~= nil then
	return HasBuff(target, "ZacE")
	end
end

function AGCSejuaniQ(target)
	if target ~= nil then
	return HasBuff(target, "SejuaniArcticAssault")
	end
end

function AGCRenektonE(target)
	if target ~= nil then
	return HasBuff(target, "renektonsliceanddicedelay")
	end
end

function AGCViQ(target)
	if target ~= nil then
	return HasBuff(target, "viqdash")
	end
end

function AGCWukongE(target)
	if target ~= nil then
	return HasBuff(target, "monkeykingnimbuskick")
	end
end




