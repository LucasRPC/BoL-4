--[[
Perfect Flash v6 by vadash - Edited by PewPewPew (v7)
Credits to grey(math) / husky (movement lib) / viceVersa(idea) / sida(move to mouse)

Features:
--Blocks failed flashes, attempts to move your character to a pos that the flash will be successful, then casts flash

Changelog:
v5 - now move with packet (more precize), use husky movent lib (faster calculate path disatnce), slightly reduced flash distance
v6 - autoaim flash (near mouse position)
v7 - Hmm, which changes were made by me????????? I can't remember what exactly I've all done :(  reference to v6 if you want to know.
]]

local FLASH_DIST = 395
local FAIL_DIST = 365
local MIN_PATH_DIST = 1000
local FlashAttempted = false
local FlashAttemptedTick = 0
local draw1, draw2, draw3, draw4, draw5, draw6 = nil, nil, nil, nil, nil, nil
local TickCount = 5000
function OnLoad()
    Menu = scriptConfig("PerfectFlash", "PerfectFlashConfig")
	Menu:addParam("limit", "+ BetterPerfomance - BetterFPS", SCRIPT_PARAM_SLICE, 7, 5, 10)
	Menu:addParam("debug", "Debug", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("eztest", "Ezreal Test", SCRIPT_PARAM_ONOFF, false)
    if Menu.eztest then 
		FLASHSlot = SUMMONER_1
		SlotID = _E
	elseif myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") then
		FLASHSlot = SUMMONER_1
		SlotID = 12
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") then
		FLASHSlot = SUMMONER_2
		SlotID = 13
	end
    print("Perfect Flash v7 loaded")
end

function OnDraw()
	if not Menu.debug then return end
	
	if draw1 ~= nil then 
		DrawCircle3D(draw1.x, draw1.y, draw1.z, 20, 2, ARGB(255, 255, 0, 0))
		DrawText3D("CastAngle", draw1.x, draw1.y, draw1.z, 20, ARGB(255, 255, 0, 0))
	end
	if draw2 ~= nil then 
		DrawCircle3D(draw2.x, draw2.y, draw2.z, 20, 2, ARGB(255, 0, 255, 0))
		DrawText3D("BestPos", draw2.x, draw2.y, draw2.z, 20, ARGB(255, 0, 255, 0))
	end
	if draw3 ~= nil then 
		DrawCircle3D(draw3.x, draw3.y, draw3.z, 20, 2, ARGB(255, 0, 0, 255))
		DrawText3D("CastPos", draw3.x, draw3.y, draw3.z, 20, ARGB(255, 0, 0, 255))
	end
	if draw4 ~= nil then 
		DrawCircle3D(draw4.x, draw4.y, draw4.z, 20, 2, ARGB(255, 255, 0, 255))
		DrawText3D("End", draw4.x, draw4.y, draw4.z, 20, ARGB(255, 255, 0, 255))
	end
	if draw5 ~= nil then 
		DrawCircle3D(draw5.x, draw5.y, draw5.z, 20, 2, ARGB(255, 0, 255, 255))
		DrawText3D("HeroPos", draw5.x, draw5.y, draw5.z, 20, ARGB(255, 0, 255, 255))
	end
	if draw6 ~= nil then 
		DrawCircle3D(draw6.x, draw6.y, draw6.z, 20, 2, ARGB(255, 255, 255, 255))
		DrawText3D("ActualEndPos", draw6.x, draw6.y, draw6.z, 20, ARGB(255, 255, 255, 255))
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name == "summonerflash" or spell.name =="EzrealArcaneShift") then 
		draw6 = Vector(spell.endPos.x, spell.endPos.y, spell.endPos.z)
	end
end

function OnTick()	
	if FlashAttempted and (FlashAttemptedTick+TickCount) > GetTickCount() and (FLASHSlot ~= nil and myHero:CanUseSpell(SlotID) == READY) then
		local CastFrom, CastPosition, EndPosition = FindBestFlashPos()
		if EndPosition and CastFrom and GetDistanceSqr(CastFrom) < 10000 then
			local FinalCast = Vector(CastFrom.x, CastFrom.y, CastFrom.z) + (Vector(EndPosition.x, EndPosition.y, EndPosition.z) - Vector(CastFrom.x, CastFrom.y, CastFrom.z)):normalized()*550
			if FinalCast then
				Packet("S_CAST", { spellId = SlotID, toX = FinalCast.x, toY = FinalCast.z, fromX = FinalCast.x, fromY = FinalCast.z }):send()
				DelayAction(function() Packet('S_MOVE', {x = mousePos.x, y = mousePos.z}):send() end, 0.2)
				FlashAttempted = false
				if Menu.debug then 	
					local TicksUsed = (TickCount -((FlashAttemptedTick+TickCount) - GetTickCount()))
					print("Duration(ticks) - "..TicksUsed)
				end
			end
		elseif CastFrom then
			Packet('S_MOVE', {x = CastFrom.x, y = CastFrom.z}):send()
		end
	end
end
		
function OnSendPacket(p)
	packet = Packet(p)
	packetName = packet:get('name')
	if packet:get('sourceNetworkId') == myHero.networkID and packetName == 'S_CAST' and packet:get('spellId') == SlotID then	
		local UniqueCastRange = FlashDistance()
		local CastPosition = Vector(myHero.x, 0, myHero.z) + (Vector(mousePos.x, 0, mousePos.z) - Vector(myHero.x, 0, myHero.z)):normalized()*UniqueCastRange
		local CastPositionHalf = Vector(myHero.x, 0, myHero.z) + (Vector(mousePos.x, 0, mousePos.z) - Vector(myHero.x, 0, myHero.z)):normalized()*(UniqueCastRange/2)
		if ((CastPosition and IsWall(D3DXVECTOR3(CastPosition.x, CastPosition.y, CastPosition.z))) or (CastPositionHalf and IsWall(D3DXVECTOR3(CastPositionHalf.x, CastPositionHalf.y, CastPositionHalf.z)))) then
			packet:block()		
			FlashAttempted = true
			FlashAttemptedTick = GetTickCount()				
		end
	end
end

function FlashDistance() 
	if GetDistanceSqr(mousePos) < 160000 then 
		return GetDistance(mousePos) 
	else
		return FLASH_DIST 
	end 
end

function FindBestFlashPos()
	local n = Vector(myHero.x, myHero.y, myHero.z) + (Vector(mousePos.x, mousePos.y, mousePos.z) - Vector(myHero.x, myHero.y, myHero.z)):normalized()*150
	local From = FindNearestNonWallForMove(n.x, n.y, n.z, math.huge, 5)
	local To = (n and Vector(myHero.x, myHero.y, myHero.z) + (Vector(n.x, n.y, n.z) - Vector(myHero.x, myHero.y, myHero.z)):normalized()*FLASH_DIST)
	local End = (To and FindNearestNonWall(To.x, To.y, To.z, FLASH_DIST, 35))
	
	
	draw1 = n
	draw2 = From
	draw3 = To
	draw4 = End
	draw5 = Vector(myHero.x, myHero.y, myHero.z)
	return From, To, End
end

function GetPathDistance(targetPosition)
    path = Movement:CalculatePath(targetPosition)
    if path == nil or path.points == nil or #path.points == 1 
        or math.abs((path.points[#path.points]).x - targetPosition.x) > 30 
        or math.abs((path.points[#path.points]).y - targetPosition.y) > 30 then
        return Point(myHero.x, myHero.z):distance(targetPosition)
    else
        local distance = 0    
        for i, point in ipairs(path.points) do
            if i ~= #path.points then
                distance = distance + path.points[i]:distance(path.points[i+1])
            end
        end
        return distance
    end
end

function FindNearestNonWallForMove( x0, y0, z0, maxRadius, precision )
    local radius, gP = 1, precision or 50
    x0, y0, z0, maxRadius = math.ceil(x0/gP)*gP, math.ceil(y0/gP)*gP, math.ceil(z0/gP)*gP, maxRadius and math.floor(maxRadius/gP) or math.huge
    local function toGamePos(x, y) return x0+x*gP, y0, z0+y*gP end
    while radius<=maxRadius do
        for i = 1, 4 do
           local p = D3DXVECTOR3(toGamePos((i==2 and radius) or (i==4 and -radius) or 0,(i==1 and radius) or (i==3 and -radius) or 0))
		   if not IsWall(p) then return p end
        end
        local f, x, y = 1-radius, 0, radius
        while x<y-1 do
            x = x + 1
            if f < 0 then f = f+1+x+x
            else y, f = y-1, f+1+x+x-y-y end
            for i=1, 8 do
                local w = math.ceil(i/2)%2==0
                local p = D3DXVECTOR3(toGamePos(((i+1)%2==0 and 1 or -1)*(w and x or y),(i<=4 and 1 or -1)*(w and y or x)))
                if not IsWall(p) then return p end
            end
        end
        radius = radius + 1
    end
end

function FindNearestNonWall( x0, y0, z0, maxRadius, precision )
    if not IsWall(D3DXVECTOR3(x0, y0, z0)) then return D3DXVECTOR3(x0, y0, z0) end
    local radius, gP = 1, precision or 50
    x0, y0, z0, maxRadius = math.ceil(x0/gP)*gP, math.ceil(y0/gP)*gP, math.ceil(z0/gP)*gP, maxRadius and math.floor(maxRadius/gP) or math.huge
    local function toGamePos(x, y) return x0+x*gP, y0, z0+y*gP end
    while radius<=maxRadius do
        for i = 1, 4 do
           local p = D3DXVECTOR3(toGamePos((i==2 and radius) or (i==4 and -radius) or 0,(i==1 and radius) or (i==3 and -radius) or 0))
           local m = GetPathDistance(Point(p.x, p.z))
		   if not IsWall(p) and m > MIN_PATH_DIST then return p end
        end
        local f, x, y = 1-radius, 0, radius
        while x<y-1 do
            x = x + 1
            if f < 0 then f = f+1+x+x
            else y, f = y-1, f+1+x+x-y-y end
            for i=1, 8 do
                local w = math.ceil(i/2)%2==0
                local p = D3DXVECTOR3(toGamePos(((i+1)%2==0 and 1 or -1)*(w and x or y),(i<=4 and 1 or -1)*(w and y or x)))
                local m = GetPathDistance(Point(p.x, p.z))
				if not IsWall(p) and m > MIN_PATH_DIST then return p end
            end
        end
        radius = radius + 1
    end
end

function Precision()
	if Menu.limit == 10 then return 20 
	elseif Menu.limit == 9 then return 30 
	elseif Menu.limit == 8 then return 40 
	elseif Menu.limit <= 7 then return 50 
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_RBUTTONDOWN then
		FlashAttemptedTick = FlashAttemptedTick-10000
	end
end


