function OnLoad()
	Menu = scriptConfig("Trinket", "Trinket")
	Menu:addParam("ward", "Buy Warding Totem at Game Start", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("timer", "Buy Sweeper at x Minutes", SCRIPT_PARAM_SLICE, 10, 1, 30)
	Menu:addParam("sightstone", "Buy Sweeper on Sightstone", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("quill", "Buy Sweeper on Quillcoat", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wriggle", "Buy Sweeper on Wriggle's", SCRIPT_PARAM_ONOFF, true)
	print("Trinket Utility loaded.")
end

function OnTick()
	if NearFountain() then
		local GameTimeSeconds = GetGameTimer()
		local GameTime = GameTimeSeconds/60
		if Menu.ward and not GetInventorySlotItem(3340) and GameTime < 2 then 
			Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3340 }):send()
		end	
		if GetInventorySlotItem(3340) and GameTime >= Menu.timer then
			SellItem(134)
			DelayAction(function() Packet("PKT_BuyItemReq", { targetNetworkId = myHero.networkID, itemId = 3341 }):send() end, 0.2)
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
