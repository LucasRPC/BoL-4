local FLASH_DIST = 400 - 20
local FAIL_DIST = 122500
local MIN_PATH_DIST = FLASH_DIST + 300

function GetPathDistance(targetPosition) -- return true distance based on unit path
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

function FindNearestNonWall( x0, y0, z0, maxRadius, precision )
    if not IsWall(D3DXVECTOR3(x0, y0, z0)) then return D3DXVECTOR3(x0, y0, z0) end
    local radius, gP = 1, precision or 50
    x0, y0, z0, maxRadius = math.round(x0/gP)*gP, math.round(y0/gP)*gP, math.round(z0/gP)*gP, maxRadius and math.floor(maxRadius/gP) or math.huge
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

function OnLoad()
    PerfectFlash = scriptConfig("PerfectFlash", "PerfectFlashConfig")
    PerfectFlash:addParam("perfectFlash", "Run -> flash -> Run", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("F"))
    PerfectFlash:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, false)
    --PerfectFlash:addParam("block", "Block fail flash", SCRIPT_PARAM_ONOFF, false)
    FLASHSlot = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") and SUMMONER_2) or nil)
    print("Perfect Flash v6d loaded")
end

function FindBestPos()
    local N_CHECKS = 7

    local flashCastPos = Vector(myHero) + (Vector(mousePos) - myHero):normalized()*FLASH_DIST
    local start_angle = math.atan2(flashCastPos.z - myHero.z, flashCastPos.x - myHero.x)
    local dx_angle = math.pi/40
    local x,z,angle,path = 0,0,0,0
    paths = {}

    for i=-N_CHECKS,N_CHECKS do
        angle = start_angle + i * dx_angle
        x = myHero.x + FLASH_DIST * math.cos(angle)
        y = myHero.y
        z = myHero.z + FLASH_DIST * math.sin(angle)
        local flashRealPos = FindNearestNonWall(x, y, z, FLASH_DIST, 20)
        if flashRealPos then
        	paths[i] = GetPathDistance(Point(flashRealPos.x, flashRealPos.z))
        else
        	paths[i] = 0
        end
    end
    angle = nil

    local maxPath = 0
    for i=-N_CHECKS+1,N_CHECKS-1 do
        if maxPath < paths[i] and paths[i-1] > MIN_PATH_DIST and paths[i+1] > MIN_PATH_DIST then
            maxPath = paths[i]
            angle = start_angle + i * dx_angle
        end
    end
    if angle ~= nil then
	    x = myHero.x + FLASH_DIST * math.cos(angle)
	    z = myHero.z + FLASH_DIST * math.sin(angle)
	    return Point(x, z)
	else
		return nil
	end
end

function OnTick()
    FLASHRReady = (FLASHSlot ~= nil and myHero:CanUseSpell(FLASHSlot) == READY)
    if PerfectFlash.perfectFlash then
        if FLASHRReady then
			local bestPos = FindBestPos()
            if bestPos then
            	local flashRealPos = FindNearestNonWall(bestPos.x, myHero.y, bestPos.y, FLASH_DIST, 20)
            	if flashRealPos and GetDistanceSqr(Point(flashRealPos.x, flashRealPos.z)) > FAIL_DIST then
                	print("wallcast")
					Packet("S_CAST", { spellId = FLASHSlot, toX = bestPos.x, toY = bestPos.z, fromX = bestPos.x, fromY = bestPos.z }):send()
				end
			elseif GetDistanceSqr(mousePos) < 144400 then
				local flashCastPos = Vector(myHero) + (Vector(mousePos) - myHero):normalized()*FLASH_DIST
				if not IsWall(D3DXVECTOR3(flashCastPos.x, flashCastPos.y, flashCastPos.z)) then
					print("non-wallcast")
					Packet("S_CAST", { spellId = FLASHSlot, toX = flashCastPos.x, toY = flashCastPos.z, fromX = flashCastPos.x, fromY = flashCastPos.z }):send()
				end
            end
        end
        MoveToCursor()
    end
end

function OnDraw()
    if PerfectFlash.drawcircles then
        local bestPos = FindBestPos()
        if bestPos then
	        local flashRealPos = FindNearestNonWall(bestPos.x, myHero.y, bestPos.y, FLASH_DIST, 20)
	        if flashRealPos and GetPathDistance(Point(flashRealPos.x, flashRealPos.z)) > MIN_PATH_DIST then
	            DrawCircle3D(flashRealPos.x, flashRealPos.y, flashRealPos.z, 50, 2, ARGB(255,255,255,255), 20)
	        end
	    end
        local flashCastPos = Vector(myHero) + (Vector(mousePos) - myHero):normalized()*FLASH_DIST
        DrawCircle3D(flashCastPos.x, flashCastPos.y, flashCastPos.z, 25, 2, ARGB(150,255,0,0), 10)
    end
end

--[[function OnSendPacket(p) -- block flash for distance < FAIL_DIST
    if PerfectFlash.block then
        packet = Packet(p)
        packetName = packet:get('name')     
		if packet:get('sourceNetworkId') == player.networkID and packetName == 'S_CAST' and packet:get('spellId') == 13 then
			local flashCastPos = Vector(myHero) + (Vector(mousePos) - myHero):normalized()*FLASH_DIST
            local flashRealPos = FindNearestNonWall(flashCastPos.x, flashCastPos.y, flashCastPos.z, FLASH_DIST, 20)
            if flashRealPos and GetDistanceSqr(flashRealPos) < FAIL_DIST then
                print("blocked")
			    packet:block()
                MoveToCursor()
            end     
        end
    end
end]]

function GetClosestForWallPos(endPoint)
    local checks = 5
    local checkDistance = FLASH_DIST/checks
    local wall = false
    local checksPos = endPoint
    for k=1, checks, 1 do
        checksPos = Vector(myHero) + (endPoint - myHero):normalized()*(checkDistance*k)
        if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
            wall = true
            break
        end
    end
    return checksPos
end

function MoveToCursor()
    local moveTo = GetClosestForWallPos(Vector(mousePos.x, mousePos.y, mousePos.z))
    Packet('S_MOVE', {x = moveTo.x, y = moveTo.z}):send()
end
