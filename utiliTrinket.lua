--[[
Changelog:
v1 - First!
v2 - Fixed In Game Timer
v3 - Added that ScryingOrb swag(that's what kids say these days right???),
now shops if your dead as well, may as well use that respawn time efficiently :D
]]

local GameTime = 0

function OnLoad()
	Menu = scriptConfig("Trinket", "Trinket")
	Menu:addParam("ward", "Buy Warding Totem at Game Start", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("timer", "Buy Sweeper at x Minutes", SCRIPT_PARAM_SLICE, 10, 1, 30)
	Menu:addParam("scryorb", "Buy ScryingOrb On/Off", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("timer2", "Buy ScryingOrb at x Minutes", SCRIPT_PARAM_SLICE, 40, 30, 60)
	Menu:addParam("sightstone", "Buy Sweeper on Sightstone", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("quill", "Buy Sweeper on Quillcoat", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wriggle", "Buy Sweeper on Wriggle's", SCRIPT_PARAM_ONOFF, true)
	print("Trinket Utility loaded.")
end

function OnTick()
	if NearFountain() or myHero.dead then
		if Menu.ward and not GetInventorySlotItem(3340) and GameTime() < 1 then 
			Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3340 }):send()
		end	
		if GetInventorySlotItem(3340) and GameTime() >= Menu.timer then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3341 }):send() end, 0.2)
		end
		if (GetInventorySlotItem(3340) or GetInventorySlotItem(3341)) and Menu.scryorb and GameTime() >= Menu.timer2 then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3342 }):send() end, 0.2)
		end
		if Menu.sightstone and GetInventorySlotItem(3340) and GetInventorySlotItem(2049) then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3341 }):send() end, 0.2)		
		end
		if Menu.quill and GetInventorySlotItem(3340) and GetInventorySlotItem(3205) then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3341 }):send() end, 0.2)		
		end
		if Menu.wriggle and GetInventorySlotItem(3340) and GetInventorySlotItem(3154) then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3341 }):send() end, 0.2)		
		end
	end	
end

function SellItem(slot)
	p = CLoLPacket(0x9)
	p.dwArg1 = 1
	p.dwArg2 = 0
	p:EncodeF(myHero.networkID)
	p:Encode1(slot)
	SendPacket(p)
end

function GameTime() return GetInGameTimer()/60 end



