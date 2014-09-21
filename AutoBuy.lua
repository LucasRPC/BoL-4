local LoadComplete = false
local LastBuy, LastPotionBuy = 0, 0
local BuyList

function OnLoad()
	print("AutoBuy Loaded :D")
	TableInit()
	ReloadCheck()
	LoadComplete = true
end

function TableInit()
	if myHero.charName == "Soraka" or myHero.charName == "Morgana" then
		BuyList = {
			[1] = {itemID = "3301", haveBought = false, name = "Coin"},
			[2] = {itemID = "3340", haveBought = false, name = "WardTrinket"},
			[3] = {itemID = "1028", haveBought = false, name = "RubyCrystal"},
			[4] = {itemID = "2049", haveBought = false, name = "Sightstone"},
			[5] = {itemID = "1004", haveBought = false, name = "FairieCharm"},
			[6] = {itemID = "1001", haveBought = false, name = "BootsT1"},
			[7] = {itemID = "3028", haveBought = false, name = "Chalice"},
			[8] = {itemID = "3096", haveBought = false, name = "Nomad"},
			[9] = {itemID = "3114", haveBought = false, name = "ForbiddenIdol"},
			[10] = {itemID = "3069", haveBought = false, name = "Talisman"},
			[11] = {itemID = "3111", haveBought = false, name = "MercTreads"},
			[12] = {itemID = "3222", haveBought = false, name = "Crucible"},
			[13] = {itemID = "2045", haveBought = false, name = "RubySightstone"},
			[14] = {itemID = "3362", haveBought = false, name = "TrinketT2"},
			[15] = {itemID = "1057", haveBought = false, name = "Negatron"},
			[16] = {itemID = "3105", haveBought = false, name = "Aegis"},
			[17] = {itemID = "3190", haveBought = false, name = "Locket"},
			[18] = {itemID = "3082", haveBought = false, name = "Wardens"},
			[19] = {itemID = "1011", haveBought = false, name = "GiantsBelt"},
			[20] = {itemID = "3143", haveBought = false, name = "Randuins"},	
			[21] = {itemID = "3275", haveBought = false, name = "Homeguard"},
		}
	elseif myHero.charName == "Zilean" or myHero.charName == "Sona" then
		BuyList = {
			[1] = {itemID = "3303", haveBought = false, name = "Spellthief"}, --1
			[2] = {itemID = "3340", haveBought = false, name = "WardTrinket"},
			[3] = {itemID = "1027", haveBought = false, name = "ManaCrystal"}, --2
			[4] = {itemID = "3070", haveBought = false, name = "Tear"},			
			[5] = {itemID = "1028", haveBought = false, name = "RubyCrystal"}, --3
			[6] = {itemID = "2049", haveBought = false, name = "Sightstone"},
			[7] = {itemID = "1001", haveBought = false, name = "BootsT1"}, --4
			[8] = {itemID = "3098", haveBought = false, name = "FrostFang"}, 
			[9] = {itemID = "3028", haveBought = false, name = "Chalice"}, --5
			[10] = {itemID = "3092", haveBought = false, name = "FrostQueen"},
			[11] = {itemID = "3114", haveBought = false, name = "ForbiddenIdol"},
			[12] = {itemID = "3111", haveBought = false, name = "MercTreads"},
			[13] = {itemID = "3222", haveBought = false, name = "Crucible"},
			[14] = {itemID = "2045", haveBought = false, name = "RubySightstone"},
			[15] = {itemID = "3362", haveBought = false, name = "TrinketT2"},
			[16] = {itemID = "3024", haveBought = false, name = "Glacial"}, --6
			[17] = {itemID = "3110", haveBought = false, name = "FrozenHeart"},
			[18] = {itemID = "3007", haveBought = false, name = "ArchStaff"},	
			[19] = {itemID = "3275", haveBought = false, name = "Homeguard"},
		}
	end
end 

function OnTick()
	if not LoadComplete then return end
	
	PurchaseItems()
	BuyPotions()
end

function BuyTimeCheck()
	if LastBuy < GetInGameTimer() then
		return true
	else
		return false
	end
end

function BuyPotionCheck()
	if LastPotionBuy < GetInGameTimer() then
		return true
	else
		return false
	end
end

function PurchaseItems()
	if InFountain() or myHero.dead then
		if BuyTimeCheck() then
			for i=1, #BuyList do
				if BuyList[i].itemID ~= nil and GetInventoryHaveItem(tonumber(BuyList[i].itemID)) then
					BuyList[i].haveBought = true
				elseif not BuyList[i].haveBought and (i == 1 or BuyList[i-1].haveBought) then			
					BuyItem(tonumber(BuyList[i].itemID))
					LastBuy = GetInGameTimer() + 1
				end
			end
		end
	end
end

function ReloadCheck()
	for i=#BuyList, 1, -1 do
		if BuyList[i].itemID ~= nil and GetInventoryHaveItem(tonumber(BuyList[i].itemID)) then
			BuyList[i].haveBought = true
			for j=i, 1, -1 do
				BuyList[j].haveBought = true
			end
			break
		end
	end
end

function BuyPotions()
	if NearFountain() or myHero.dead then
		if GetInGameTimer() < 1200 then
			if not GetInventorySlotItem(2010) and BuyPotionCheck() then 
				BuyItem(2003)
				LastPotionBuy = GetInGameTimer() + 1
			end	
			if not GetInventorySlotItem(2004) and BuyPotionCheck() then 
				BuyItem(2004)
				DelayAction(function() BuyItem(2004) end , 1.5)
				DelayAction(function() BuyItem(2004) end , 3.0)
				LastPotionBuy = GetInGameTimer() + 1
			end	
		end
	end
end		

