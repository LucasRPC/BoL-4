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
	
	--if Menu.Harass then ItemTest() end
	if AutoCarry.Keys.AutoCarry then Combo() end
	if AutoCarry.Keys.MixedMode then Harass() end	
end

--[[local itemSlot
local Items = {
	[3077] = {name = "Tiamat"},
	[3074] = {name = "Tiamat"},
	[3142] = {name = "Tiamat"},
	[3144] = {name = "Tiamat"},
	[3153] = {name = "Tiamat"},
}

local HaveItem = {

}

function ItemTest()
	for i, _ in pairs(Items) do
		local itemId = i --:gsub("%s+", "")
		local slot = GetInventorySlotItem(itemID)
		print(""..slot.."")
		--if slot then 
			--HaveItem[slot]
		--end
	end
end]]

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
		elseif ValidTarget(Target, 275) and AutoCarry.Orbwalker:IsAfterAttack() and not WAble then
			Packet("S_CAST", { spellId = _Q}):send()	
		else
			Harass()
		end	
	end
end
    
function Harass()
	if Target and ValidTarget(Target, 660) and EAble and QAble and WAble then 
		Packet("S_CAST", { spellId = _E, targetNetworkId = Target.networkID }):send()
	elseif ValidTarget(Target, 275) and not WAble and AutoCarry.Orbwalker:IsAfterAttack() then
		Packet("S_CAST", { spellId = _Q}):send()
	end	
end

function OnGainBuff(unit, buff)
	if Target and unit.networkID == Target.networkID and buff.name == "talondamageamp" then
		if AutoCarry.Keys.AutoCarry then
			DelayAction(function() Packet("S_CAST", { spellId = _R }):send() end, 0.4)
		end	
		local wPos = Vector(myHero) + Vector(Vector(Target) - Vector(myHero)):normalized()*300
		DelayAction(function() Packet("S_CAST", { spellId = _W, toX = wPos.x, toZ = wPos.z }):send() end, 0.5)
	end
end

--[[function GetInventorySlotItem(itemID, target)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types ( expected)")
    local target = target or player
    for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }) do
        if target:getInventorySlot(j) == itemID then return j end
    end
    return nil
end

Menu = AutoCarry.Plugins:RegisterPlugin(Plugin(), "Talon Combo")
Menu:addParam("Combo", "Combo Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
Menu:addParam("Harass", "Harass Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))]]

  
