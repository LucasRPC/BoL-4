class 'Plugin'
if myHero.charName ~= "Talon" or not VIP_USER then return end

local Target
local QAble, WAble, EAble, RAble = false, false, false, false

function Plugin:__init()
AutoCarry.Crosshair:SetSkillCrosshairRange(1000)
AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
end

function Plugin:OnTick()
	Checks()
	Target = AutoCarry.Crosshair:GetTarget()
	
	if Menu.Harass then ItemTest() end
	if AutoCarry.Keys.AutoCarry then Combo() end
	if AutoCarry.Keys.MixedMode then Harass() end	
end


local Items = {
	[3144] = {name = "BilgewaterCutlass"},
	[3153] = {name = "ItemSwordOfFeastAndFamine"},
	[3077] = {name = "ItemTiamatCleave"},
	[3074] = {name = "ItemTiamatCleave"},
	[3142] = {name = "YoumusBlade"},
}

function ItemTest()
	for i, _ in pairs(Items) do
		local slot = GetInventorySlotItem(i)
		if GetInventoryItemIsCastable(i) then
			Packet("S_CAST", { spellId = slot, targetNetworkId = Target.networkID }):send()
		end
	end
end

function Checks()
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	RAble = (myHero:CanUseSpell(_R) == READY)
end
	
function ComboCheck()
	if QAble and WAble and EAble and RAble then
		return true
	else 
		return false
	end
end

function Combo()
	if Target and ValidTarget(Target, 660) then
		if ComboCheck() then 
			Packet("S_CAST", { spellId = _E, targetNetworkId = Target.networkID }):send()
		elseif not EAble and WAble then
			local wPos = Vector(myHero) + Vector(Vector(Target) - Vector(myHero)):normalized()*660
			Packet("S_CAST", { spellId = _W, toX = wPos.x, toZ = wPos.z }):send()
		elseif ValidTarget(Target, 300) and AutoCarry.Orbwalker:IsAfterAttack() and not WAble then
			Packet("S_CAST", { spellId = _Q }):send()	
		elseif Menu.useItems and ValidTarget(Target, 275) then
			for i, _ in pairs(Items) do
				local slot = GetInventorySlotItem(i)
				if GetInventoryItemIsCastable(i) then
					Packet("S_CAST", { spellId = slot, targetNetworkId = Target.networkID }):send()
				end
			end			
		else
			Harass()
		end	
	end
end
    
function Harass()
	if Target and ValidTarget(Target, 660) and EAble and QAble and WAble then 
		Packet("S_CAST", { spellId = _E, targetNetworkId = Target.networkID }):send()
	elseif ValidTarget(Target, 275) and not WAble and AutoCarry.Orbwalker:IsAfterAttack() then
		Packet("S_CAST", { spellId = _Q }):send()
	end	
end

function OnGainBuff(unit, buff)
	if Target and unit.networkID == Target.networkID and buff.name == "talondamageamp" then
		if AutoCarry.Keys.AutoCarry then
			DelayAction(function() Packet("S_CAST", { spellId = _R }):send() end, 0.8)
		end	
		local wPos = Vector(myHero) + Vector(Vector(Target) - Vector(myHero)):normalized()*300
		DelayAction(function() Packet("S_CAST", { spellId = _W, toX = wPos.x, toZ = wPos.z }):send() end, 0.5)
	end
end

Menu = AutoCarry.Plugins:RegisterPlugin(Plugin(), "Talon Combo")
Menu:addParam("Harass", "Debug key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Menu:addParam("useItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, false)

  
