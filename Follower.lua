local PrimaryFollow, SecondaryFollow, EscapeTurret, ClosestEnemy, StartPos, RecallPosition, debugdraw = nil, nil, nil, nil, nil, nil, nil
local Loaded, GoingHome, StayInBrush = false, false, false
local MinionAggro, HeroAggro, FallBackPing, DragonAggro, BaronAggro, HaveTowerAgro = 0, 0, 0, false, false, false
local PrimaryLastMove, LastAction, LastWard, RecallStarted, SurrenderCount = 0, 0, 0, 0, 0
local aaRange = math.pow(myHero.range, 2)

local enemyMinions = minionManager(MINION_ENEMY, 1200, myHero)
local allyMinions = minionManager(MINION_ALLY, 1200, myHero)
local jungleMinions = minionManager(MINION_JUNGLE, 800, myHero, MINION_SORT_MAXHEALTH_DEC)

local wardPositions = {}
local wardSpots = {
    -- Perfect Wards
    { x = 2823.37, y = 55.03, z = 7617.03},     -- BLUE GOLEM
    { x = 7422, y = 46.53, z = 3282},     -- BLUE LIZARD
    { x = 10148, y = 44.41, z = 2839},     -- BLUE TRI BUSH
    { x = 6269, y = 42.51, z = 4445},     -- BLUE PASS BUSH
    { x = 7151.64, y = 51.67, z = 4719.66},     -- BLUE RIVER ENTRANCE
    { x = 4728, y = -51.29, z = 8336},     -- BLUE RIVER ROUND BUSH
    { x = 6762.52, y = 55.68, z = 2918.75},     -- BLUE SPLIT PUSH BUSH
    { x = 11217.39, y = 54.87, z = 6841.89},     -- PURPLE GOLEM
    { x = 6610.35, y = 54.45, z = 11064.61},    -- PURPLE LIZARD
    { x = 3883, y = 39.87, z = 11577},    -- PURPLE TRI BUSH
    { x = 7775, y = 43.14, z = 10046.49}, -- PURPLE PASS BUSH
    { x = 6867.68, y = 57.01, z = 9567.63},     -- PURPLE RIVER ENTRANCE
    { x = 9720.86, y = 54.85, z = 7501.50},     -- PURPLE ROUND BUSH
    { x = 9233.13, y = -44.63, z = 6094.48},     -- PURPLE RIVER ROUND BUSH
    { x = 7282.69, y = 52.59, z = 11482.53},    -- PURPLE SPLIT PUSH BUSH
    { x = 10180.18, y = -62.32, z = 4969.32},      -- DRAGON
    { x = 8875.13, y = -64.07, z = 5390.57}, -- DRAGON BUSH
    { x = 3920.88, y = -60.42, z = 9477.78},      -- BARON
    { x = 5017.27, y = -62.70, z = 8954.09}, -- BARON BUSH   
    { x = 12657.58, y = 49.99, z = 1969.98}, -- BOT SIDE BUSH
    { x = 12321.70, y = 49.77, z = 1643.73}, -- BOT SIDE BUSH
	{ x = 9641.6591796875,  y = 53.01416015625,  z = 6368.748046875}, -- Edited
	{ x = 8081.4360351563,  y = 55.9482421875,  z = 4683.443359375}, -- Edited
	{ x = 5943.51953125,  y = 53.189331054688,  z = 9792.4091796875}, -- Edited
	{ x = 4379.513671875,  y = 42.734619140625,  z = 8093.740234375}, -- Edited
	{ x = 4222.724609375,  y = 53.612548828125,  z = 7038.5805664063}, -- Edited
	{ x = 9068.0224609375,  y = 53.22705078125,  z = 11186.685546875}, -- Edited
	{ x = 7970.822265625,  y = 53.527709960938,  z = 10005.072265625}, -- Edited
	{ x = 4978.1943359375,  y = 54.343017578125,  z = 3042.6975097656}, -- Edited
	{ x = 7907.6357421875,  y = 49.947143554688,  z = 11629.322265625}, -- Edited
	{ x = 7556.0654296875,  y = 50.61547851625,  z = 11739.625}, -- Edited
	{ x = 5973.4853515625,  y = 54.348999023438,  z = 11115.6875}, -- Edited
	{ x = 5732.8198242188,  y = 53.397827148438,  z = 10289.76953125}, -- Edited
	{ x = 7969.15625,  y = 56.940795898438,  z = 3307.5673828125}, -- Edited
	{ x = 12073.184570313,  y = 52.322265625,  z = 4795.50390625}, -- Edited
	{ x = 4044.1313476563,  y = 48.591918945313,  z = 11600.502929688}, -- Edited
	{ x = 5597.6669921875,  y = 39.739379882813,  z = 12491.047851563}, -- Edited
	{ x = 10070.202148438,  y = -60.332153320313,  z = 4132.4536132813}, -- Edited
	{ x = 8320.2890625,  y = 56.473876953125,  z = 4292.8090820313}, -- Edited
	{ x = 9603.5205078125,  y = 54.713745117188,  z = 7872.2368164063}, -- Edited
	{x = 9843.38, y = 43.02, z = 3125.16},
	{x = 4214.93, y = 36.62, z = 11202.01},
	{x = 2267.97, y = 44.20, z = 10783.37},
	{x = 5688.96, y = 45.64, z = 7825.20},
	{x = 7927.65, y = 47.71, z = 4239.77},
	{x = 8539.27, y = 46.98, z = 6637.38},
	{x = 11974.23, y = 42.84, z = 3807.21}
}
local towerSpots = {
    --BlueSide
    { x = 575, y = 27, z = 10220},--Top Outer, Inner, Inhib
    { x = 1106, y = 42, z = 6479},
    { x = 803, y = 97, z = 4052},
    
	{ x = 5439, y = 44, z = 6167},--Middle Outer, Inner, Inhib
    { x = 4641, y = 44, z = 4592},
    { x = 3244, y = 96, z = 3447},
    
	{ x = 10098, y = 41, z = 809},--Bottom Outer, Inner, Inhib
    { x = 6513, y = 43, z = 1263},
    { x = 3747, y = 96, z = 1041},
    --PurpleSide
    { x = 3912, y = 13,  z = 13655},--Top Outer, Inner, Inhib
    { x = 7537, y = 39,  z = 13192},
    { x = 10262, y = 95,  z = 13466},
    
	{ x = 8549, y = 44,  z = 8289},--Middle Outer, Inner, Inhib
    { x = 9361, y = 41, z = 9893},
    { x = 10744, y = 97, z = 11010},
   
    { x = 13460, y = 41, z = 4284},--Bottom Outer, Inner, Inhib
    { x = 12921, y = 38, z = 8005},
    { x = 13206, y = 96, z = 10475},
}

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       Recall      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function ShouldRecall()
	if myHero.dead or NearFountain() then
		return false
	elseif myHealthPct() < 30 or myHero.health < 100 then 
		return true
	elseif myManaPct() < 15 or myHero.mana < 50 then
		if GetInventoryHaveItem(2004) then
			return false
		elseif ManaPotionBuff() then
			return false
		elseif myHealthPct() < 60 then
			return true
		end	
	else
		return false
	end
end

function ManaPotionBuff()
	for i = 1, myHero.buffCount do
		tBuff = myHero:getBuff(i)
		if tBuff.name == "FlaskOfCrystalWater" and BuffIsValid(tBuff) then
			return true
		end	
	end
	return false
end

function IsRecalling(unit)
	assert(type(unit) == 'userdata', "IsOnCC: Wrong type. Expected userdata got: "..tostring(type(unit)))
	for i = 1, unit.buffCount do
		tBuff = unit:getBuff(i)
		if BuffIsValid(tBuff) then
			if tBuff.name == "Recall" then
				return true
			elseif tBuff.name == "RecallImproved" then
				return true
			end
		end	
	end
	return false
end

function RecallSpamCheck(seconds)
	if IsRecalling(myHero) then
		return false
	elseif StartPos and GetDistanceSqr(StartPos) > math.pow(3000, 2) then 
		return false	
	elseif (RecallStarted + seconds) < GetInGameTimer() then
		return true
	else
		return false
	end
end

function RecallSafetyCheck()
	if ClosestEnemy and GetDistanceSqr(ClosestEnemy) > math.pow(1300, 2) then 
		return true
	elseif ClosestEnemy == nil then
		return true
	else
		return false
	end
end

function CastRecall()
	if myHero.dead then return end
	if RecallPosition then 
		if GetDistanceSqr(RecallPosition) < math.pow(200, 2) then
			if RecallSafetyCheck() then
				CastSpell(RECALL)
			elseif ActionSpamCheck(0.2) then
				myHero:MoveTo(StartPos.x, StartPos.z)
			end
		elseif ActionSpamCheck(0.2) then
			myHero:MoveTo(RecallPosition.x, RecallPosition.z)
		end	
	elseif ActionSpamCheck(0.2) then
		myHero:MoveTo(StartPos.x, StartPos.z)
	end
	
	if NearFountain() then
		GoingHome = false
		RecallPosition = nil
	end
end

function GetSafeRecallPos() --NEEDS REWORK
	local ClosestTower = GetClosestTurret(myHero, myHero.team)
	local SafeSpot = (ClosestTower and Vector(ClosestTower) + Vector(Vector(StartPos) - Vector(ClosestTower)):normalized()*1500)
	if SafeSpot then
		RecallPosition = SafeSpot
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       Follow      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function ShouldFollow(unit)
	if unit == nil or GetInGameTimer() < 62 or unit.dead or IsRecalling(unit) then 
		return false 
	elseif not InDanger() and unit and GetDistanceSqr(unit) > math.pow(625, 2) then
		if StartPos and GetDistanceSqr(StartPos, unit) < math.pow(3800, 2) and GetDistanceSqr(StartPos) > math.pow(4200, 2) then
			return false
		else
			return true
		end
	else 
		return false
	end
end

function Follow(unit)
	if ShouldFollow(unit) and ActionSpamCheck(0.4) then
		local FollowMove = Vector((unit.x + math.random(-150, 150)), unit.y, (unit.z + math.random(-150, 150))) + (Vector(Vector(unit.x, unit.y, unit.z) - Vector(myHero.x, myHero.y, myHero.z))):normalized()*math.random(500, 900)
		if FollowMove then
			myHero:MoveTo(FollowMove.x, FollowMove.z)
			LastAction = GetInGameTimer()
			debugdraw = FollowMove
		end
	end
	
	if not InDanger() and ActionSpamCheck(2) and GetInGameTimer() > 91 and not NearFountain() then
		local closest = nil
		for i, ally in ipairs(GetAllyHeroes()) do
			if closest == nil then 
				closest = Vector(ally.x, ally.y, ally.z)
			elseif ally and closest and GetDistanceSqr(ally) < GetDistanceSqr(closest) then
				closest = Vector(ally.x, ally.y, ally.z)
			end
		end		
		if closest then
			local IdleMove = Vector((closest.x + math.random(-150, 150)), closest.y, (closest.z + math.random(-150, 150))) + (Vector(Vector(closest.x, closest.y, closest.z) - Vector(myHero.x, myHero.y, myHero.z))):normalized()*math.random(300, 600)
			if IdleMove then
				myHero:MoveTo(IdleMove.x, IdleMove.z)
				LastAction = GetInGameTimer()
				debugdraw = IdleMove
			end
		end
	end
end

function Fallback()
	myHero:MoveTo(StartPos.x, StartPos.z)
	LastAction = GetInGameTimer()
end

function GetSecondaryFollow()
	local closest = nil
	for i, ally in ipairs(GetAllyHeroes()) do
		if not ally.dead and ally.name ~= PrimaryFollow.name and not IsRecalling(ally) then	
			if closest == nil then 
				closest = ally
			elseif ally and closest and GetDistanceSqr(ally) < GetDistanceSqr(closest) then
				closest = ally
			end
		end
	end
	if closest ~= nil then 
		SecondaryFollow = closest
		print("Secondary - "..closest.name)
	else 
		SecondaryFollow = nil
	end
end

local CheckIfADC =
	function(string)
		local ADCcharNames = {
			"ashe",
			"corki",
			"ezreal",
			"caitlyn",
			"draven",
			"graves",
			"jinx",
			"kogmaw",
			"lucian",
			"missfortune",
			"quinn",
			"sivir",
			"tristana",
			"twitch",
			"varus",
			"vayne",
			"urgot",
			"twistedfate"
		}
		local toLowerString = string.lower(string)
		for _, v in ipairs(ADCcharNames) do
			if (string.find(toLowerString, v)) then
				return true
			end
		end
	return false
end

function GetPrimaryFollow()
	local possibleADC = 0
	for i, ally in ipairs(GetAllyHeroes()) do
		if CheckIfADC(ally.charName) and SmiteCheck(ally) then
			LastCandidate = ally
			possibleADC = possibleADC + 1
		end
	end	
	if possibleADC == 1 then 
		PrimaryFollow = LastCandidate
		print("Primary - "..LastCandidate.name)
	else
		DelayAction(function() GetPrimaryFollowBackup() end, 123)
	end
end

function GetPrimaryFollowBackup()
	local FromBottom = Vector(12321, 54, 1643)
	local closest = nil
	for i, ally in ipairs(GetAllyHeroes()) do
		if ally and SmiteCheck(ally) then
			if closest == nil then
				closest = ally
			elseif closest and GetDistanceSqr(FromBottom, ally) < GetDistanceSqr(FromBottom, closest) then
				closest = ally
			end
		end
	end
	PrimaryFollow = closest
	print("Primary - "..closest.name)	
end

function AutoAttackHeroes()
	for i, hero in pairs(GetEnemyHeroes()) do
		if ValidTarget(hero, math.sqrt(aaRange)) and ActionSpamCheck(0.8) and not InDanger() then 
			myHero:Attack(hero)
			LastAction = GetInGameTimer()
			debugdraw = Vector(hero.x, hero.y, hero.z)
		end
	end
end
	
function AutoAttackMinions()
	if not InDanger() and (#allyMinions.objects < #enemyMinions.objects or myHero.level == 1 or myHero.level >= 12) then
		for i,minion in ipairs(enemyMinions.objects) do
			if minion and GetDistanceSqr(minion) < aaRange and minion.health > 200 and ActionSpamCheck(0.8) then
				local closest = nil
				for i, hero in pairs(GetEnemyHeroes()) do
					if closest == nil then 
						closest = hero
					elseif hero and closest and GetDistanceSqr(hero) < GetDistanceSqr(closest) then
						closest = hero
					end
				end
				if not ValidTarget(closest, 575) then			
					myHero:Attack(minion)
					LastAction = GetInGameTimer()
					debugdraw = Vector(minion.x, minion.y, minion.z)
				end
			end
		end
	end
end

function AutoAttackJungle()
	if not InDanger() then
		for i, jungle in ipairs(jungleMinions.objects) do
			if jungle and GetDistanceSqr(jungle) < aaRange and jungle.health > 200 and ActionSpamCheck(0.8) then
				myHero:Attack(jungle)
				LastAction = GetInGameTimer()
				debugdraw = Vector(jungle.x, jungle.y, jungle.z)
			end
		end
	end
end

function AutoAttackTurrets()
	local closestTurret = GetClosestTurret(myHero, NotMyTeam())
	if closestTurret and GetDistanceSqr(closestTurret) < aaRange and ActionSpamCheck(0.8) then
		myHero:Attack(closestTurret)
		LastAction = GetInGameTimer()
		debugdraw = Vector(closestTurret.x, closestTurret.y, closestTurret.z)
	end
end

function NotMyTeam()
	if myHero.team == 100 then
		return 200
	else 
		return 100
	end
end

function SmiteCheck(hero)
	if hero:GetSpellData(SUMMONER_1).name ~= "summonersmite" and hero:GetSpellData(SUMMONER_2).name ~= "summonersmite" then
		return true
	else
		return false
	end
end

function AvoidTowers()
	if HaveTowerAgro and EscapeTurret ~= nil then
		local EscapeTo = GetClosestTurret(myHero, myHero.team)
		if EscapeTo then 
			myHero:MoveTo(EscapeTo.x, EscapeTo.z)
			LastAction = GetInGameTimer()
			debugdraw = Vector(EscapeTo.x, EscapeTo.y, EscapeTo.z)
		end
	end
end

function PrimaryInBase()
	if PrimaryFollow then
		if PrimaryFollow.dead then
			return true
		elseif StartPos and GetDistanceSqr(StartPos, PrimaryFollow) < math.pow(5900, 2) and GetDistanceSqr(PrimaryFollow) > math.pow(2500, 2) then
			return true
		elseif IsRecalling(PrimaryFollow) then
			return true
		else
			return false
		end
	end
end

function PrimarySecondarySelection()
	if PrimaryFollow and PrimaryInBase() then -- or AFKCheck()
		if SecondaryFollow == nil or SecondaryFollow.dead or IsRecalling(SecondaryFollow) then 
			GetSecondaryFollow()
		elseif SecondaryFollow then
			Follow(SecondaryFollow)
		--[[PUT WARD ROAMING HERE]]
		end
	elseif PrimaryFollow then
		Follow(PrimaryFollow)
		SecondaryFollow = nil
	end
end

function GenerateWardLine()

end

function WardRoam() 

end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      Helpers      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function PrimaryInBrush()
	if ClosestEnemy == nil or (ClosestEnemy and GetDistanceSqr(ClosestEnemy) > math.pow(400, 2)) then
		if PrimaryFollow and IsWallOfGrass(D3DXVECTOR3(PrimaryFollow.x, 0, PrimaryFollow.z)) then
			StayInBrush = true
		else 
			StayInBrush = false
		end
	else
		StayInBrush = false
	end		
end

function GetClosestEnemyHero()
	local closest = nil
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if closest == nil then 
			closest = enemy
		elseif enemy and closest and GetDistanceSqr(enemy) < GetDistanceSqr(closest) then
			closest = enemy
		end
	end
	return closest
end
	
function GetClosestTurret(pos, team)
	local ClosestTurretFromPos = nil
	for i=1, objManager.maxObjects, 1 do
		local closest = objManager:getObject(i)
		if closest and closest.valid and closest.type == "obj_AI_Turret" and closest.visible and closest.team == team then
			if ClosestTurretFromPos == nil and (closest.health/closest.maxHealth > 0.1) then
				ClosestTurretFromPos = closest
			elseif pos and ClosestTurretFromPos and GetDistanceSqr(closest, pos) < GetDistanceSqr(ClosestTurretFromPos, pos) and (closest.health/closest.maxHealth > 0.1) then
				ClosestTurretFromPos = closest
			end
		end		
	end
	return ClosestTurretFromPos
end

function StayAtFountain()
	if NearFountain() then
		if (myHealthPct() < 90 or myManaPct() < 90) then
			return true
		else
			return false
		end
	else 
		return false
	end
end

function BlockRecallMovement()
	if IsRecalling(myHero) then
		if ClosestEnemy and GetDistanceSqr(ClosestEnemy) < math.pow(1150, 2) then
			return false
		else 
			return true
		end
	else
		return false
	end
end

function ActionSpamCheck(seconds)
	if StayAtFountain() or BlockRecallMovement() then
		return false
	else
		local CurrentTime = GetInGameTimer()
		if (LastAction + seconds) < CurrentTime then
			return true
		else 
			return false
		end
	end	
end

function MoveToBotLane()
	if myHero.team == 100 and NearFountain() then
		DelayAction(function() myHero:MoveTo(9865, 1090) end, 10)
	elseif myHero.team == 200 and NearFountain() then
		DelayAction(function() myHero:MoveTo(12850, 4200) end, 10)
	end
end

function GetWardItems()
	if GetInventoryItemIsCastable(3340) then
		return GetInventorySlotItem(3340)
	elseif GetInventoryItemIsCastable(2049) then
		return GetInventorySlotItem(2049)
	elseif GetInventoryItemIsCastable(2045) then
		return GetInventorySlotItem(2045)
	elseif GetInventoryItemIsCastable(3362) then
		return GetInventorySlotItem(3362)
	else 
		return nil
	end
end

function UseWards()
	local currentTime = GetInGameTimer()
	if #wardPositions >= 4 or (LastWard+4) > currentTime or currentTime < 140 then return end
	
	local WardSlot = GetWardItems()
	if WardSlot then
		for i=1, #wardSpots do 
			local spot = wardSpots[i]		
			if spot and GetDistanceSqr(Vector(spot.x, spot.y, spot.z)) <= math.pow(600, 2) then
				local closest = nil
				for i=1, objManager.iCount, 1 do
					local nearward = objManager:getObject(i)					
					if nearward and string.find(nearward.name, "Ward") and closest == nil then
						closest = nearward
					elseif nearward and closest and string.find(nearward.name, "Ward") and GetDistance(nearward) < GetDistance(closest) then
						closest = nearward
					end
				end
				if closest == nil or (closest and GetDistance(closest) > 1200) then  			
					LastAction = GetInGameTimer()
					CastSpell(WardSlot, spot.x, spot.z)
					LastWard = GetInGameTimer()
					addPlacedWard(spot.x, spot.y, spot.z)
				end
			end
		end
	end	
end

function AFKCheck()
	if PrimaryFollow ~= nil then
		if GetInGameTimer() >= PrimaryLastMove + 15 then
			return true
		else
			return false
		end
	end
end

function myManaPct() return (myHero.mana * 100) / myHero.maxMana end

function myHealthPct() return (myHero.health * 100) / myHero.maxHealth end

function addPlacedWard(posX, posY, posZ)
    local tmpID = math.random(1,10000)
    table.insert(wardPositions, {id = tmpID, pos = Vector(posX, posY, posZ)})
	DelayAction(function() removePlacedWard(tmpID) end, 110)
end

function removePlacedWard(id)
    for i, ward in pairs(wardPositions) do -- remove a timer from the timed drawings table
        if ward.id == id then
            table.remove(wardPositions, i)
            break
        end
    end
end

function SurrenderVote()
	if SurrenderCount >= 3 then
		print("Voted.")
		SendChat("/ff")
	end
end

function InDanger()
	if HaveTowerAgro then
		return true
	elseif ClosestEnemy ~= nil and not ClosestEnemy.dead and ValidTarget(ClosestEnemy, 300) then
		return true
	elseif HeroAggro >= 2 then
		return true
	elseif MinionAggro >= (myHero.level+1) then
		return true
	elseif DragonAggro then
		return true
	elseif BaronAggro then
		return true	
	elseif FallBackPing > GetInGameTimer() then
		return true
	else 
		return false
	end
end

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       OnXxxx      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function OnLoad()
	StartPos = GetSpawnPos()
	GetPrimaryFollow()
	MoveToBotLane()
	Loaded = true
	Menu = scriptConfig("Follower", "Follower")
	Menu:addParam("force", "Force Follow On Selected", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu:addParam("debug", "Debug Drawings", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("debugPrint", "Debug Print", SCRIPT_PARAM_ONOFF, true)
	print("Follower Loaded")
end

function OnTick()
	if not Loaded then return end

	
	if ShouldRecall() and RecallPosition == nil and not GoingHome then
		GetSafeRecallPos()
		GoingHome = true
	return end
	if GoingHome then CastRecall() return end
		
	AvoidTowers()
	ClosestEnemy = GetClosestEnemyHero()
	if InDanger() then DelayAction(function() Fallback() end, 0.15) return end

	PrimarySecondarySelection()
	UseWards()
	AutoAttackHeroes()
	AutoAttackTurrets()
	enemyMinions:update()
	allyMinions:update()
	AutoAttackMinions()
	jungleMinions:update()
	AutoAttackJungle()

	if Menu.force then
		local selectedAlly = GetTarget()
		if selectedAlly and selectedAlly.type == myHero.type and selectedAlly.team == myHero.team then
			PrimaryFollow = selectedAlly
		end
	end
end

function OnSendPacket(p)
	if BlockRecallMovement() or StayAtFountain() then
		packet = Packet(p)
		packetName = packet:get('name')
		if packet:get('sourceNetworkId') == myHero.networkID then
			if packetName == 'S_MOVE' then
				packet:block()
			elseif packetName == 'S_CAST' then
				packet:block()
			end
		end
	elseif PrimaryInBrush() then
		packet = Packet(p)
		packetName = packet:get('name')
		if packet:get('sourceNetworkId') == myHero.networkID then
			if packetName == 'S_MOVE' then
				local packetX = packet:get('x')
				local packetZ = packet:get('y')
				if not IsWallOfGrass(D3DXVECTOR3(packetX, 0, packetZ)) then
					packet:block()
					if PrimaryFollow then
						Packet('S_MOVE',{x = PrimaryFollow.x, y = PrimaryFollow.z}):send()
					end
				end
			end
		end
	end	
end

function OnRecvPacket(p)
	packet = Packet(p)
	packetName = packet:get('name')	
	if packetName == "R_PING" then
		packetType = packet:get('type')
		if packetType == PING_DANGER or packetType == PING_FALLBACK then
			packetX = packet:get('x')
			packetZ = packet:get('y')
			if packetX and packetZ and GetDistanceSqr(Vector(packetX, 0 , packetZ)) < math.pow(1200, 2) then
				FallBackPing = GetInGameTimer() + 2
			end
		end
	end
	
	if p.header == 97 and PrimaryFollow then
		p.pos = 12
		local netID = p:DecodeF()
		if netID == PrimaryFollow.networkID then
			PrimaryLastMove = GetInGameTimer()
		end
	end

   if p.header == 165 then -- NOT RIGHT HEADER
        SurrenderCount = 0
		print("Vote Ended")
   elseif p.header == 201 then
		SurrenderCount = SurrenderCount + 1
		print(SurrenderCount)
		DelayAction(function() SurrenderVote() end, 50)
    end
end

function OnDraw()
	if PrimaryFollow ~= nil then
		DrawCircle3D(PrimaryFollow.x, PrimaryFollow.y, PrimaryFollow.z, 100, 1, ARGB(255, 0, 255, 0))
	end
	if SecondaryFollow ~= nil then
		DrawCircle3D(SecondaryFollow.x, SecondaryFollow.y, SecondaryFollow.z, 100, 1, ARGB(255, 0, 0, 255))
	end
	if Menu.debug and debugdraw ~= nil then
		DrawCircle3D(debugdraw.x, debugdraw.y, debugdraw.z, 25, 1, ARGB(255, 255, 0, 0))
	end
end

function OnDeleteObj(object)
	if object.name:find("Ward") and object.team == myHero.team then
		for i, ward in pairs(wardPositions) do
			if ward and GetDistanceSqr(ward.pos, object) < math.pow(70, 2) then 
            table.remove(wardPositions, i)
            break
			end
		end
	end
end
	
function OnGainAggro(attacker)
	if string.find(attacker.name, "Turret") then
		HaveTowerAgro = true
		EscapeTurret = GetClosestTurret(myHero, TEAM_ENEMY)
	elseif string.find(attacker.name, "Minion") then
		MinionAggro = MinionAggro + 1
	elseif attacker.type == myHero.type then 
		HeroAggro = HeroAggro + 1
	elseif attacker.name == "Dragon6.1.1" then 
		DragonAggro = true
	elseif attacker.name == "Worm12.1.1" then 
		BaronAggro = true	
	end
end

function OnLoseAggro(attacker)
	if string.find(attacker.name, "Turret") then
		HaveTowerAgro = false
		EscapeTurret = nil
	elseif string.find(attacker.name, "Minion") then
		MinionAggro = MinionAggro - 1
	elseif attacker.type == myHero.type then 
		HeroAggro = HeroAggro - 1
	elseif attacker.name == "Dragon6.1.1" then 
		DragonAggro = false
	elseif attacker.name == "Worm12.1.1" then 
		BaronAggro = false
	end
end



