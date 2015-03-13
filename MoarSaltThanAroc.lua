local lshift, rshift, band, bxor = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor
local floor, ceil, huge, cos, sin, pi, pi2, abs, sqrt = math.floor, math.ceil, math.huge, math.cos, math.sin, math.pi, math.pi*2, math.abs, math.sqrt
local clock, pairs, ipairs, tostring = os.clock, pairs, ipairs, tostring
local TEAM_ENEMY, TEAM_ALLY
local IDBytes = {
	[0x00] = 0x2E, [0x01] = 0xEF, [0x02] = 0x38, [0x03] = 0x39, [0x04] = 0x8E, [0x05] = 0x65, [0x06] = 0xC5, [0x07] = 0x3C, [0x08] = 0x2A, [0x09] = 0x68, [0x0A] = 0xFB, [0x0B] = 0x9B, 
	[0x0C] = 0x1F, [0x0D] = 0xC3, [0x0E] = 0x40, [0x0F] = 0x4E, [0x10] = 0x26, [0x11] = 0x95, [0x12] = 0x70, [0x13] = 0xF5, [0x14] = 0x15, [0x15] = 0x45, [0x16] = 0x49, [0x17] = 0xD0, 
	[0x18] = 0xBB, [0x19] = 0xE6, [0x1A] = 0x7D, [0x1B] = 0x7F, [0x1C] = 0xD3, [0x1D] = 0xE4, [0x1E] = 0x12, [0x1F] = 0xA9, [0x20] = 0xC7, [0x21] = 0x7E, [0x22] = 0x0F, [0x23] = 0xD5, 
	[0x24] = 0xED, [0x25] = 0x29, [0x26] = 0x3B, [0x27] = 0x87, [0x28] = 0x06, [0x29] = 0xFA, [0x2A] = 0xE3, [0x2B] = 0xDA, [0x2C] = 0x5C, [0x2D] = 0xA3, [0x2E] = 0xEE, [0x2F] = 0x2D, 
	[0x30] = 0x54, [0x31] = 0x51, [0x32] = 0xC9, [0x33] = 0x75, [0x34] = 0x94, [0x35] = 0x4C, [0x36] = 0x82, [0x37] = 0x0D, [0x38] = 0xF6, [0x39] = 0xB7, [0x3A] = 0xC1, [0x3B] = 0xC8, 
	[0x3C] = 0x91, [0x3D] = 0xB1, [0x3E] = 0x66, [0x3F] = 0x20, [0x40] = 0x03, [0x41] = 0x98, [0x42] = 0x2F, [0x43] = 0xEB, [0x44] = 0x7C, [0x45] = 0x58, [0x46] = 0x43, [0x47] = 0x9C, 
	[0x48] = 0x93, [0x49] = 0xD7, [0x4A] = 0x10, [0x4B] = 0x5F, [0x4C] = 0x71, [0x4D] = 0x84, [0x4E] = 0x89, [0x4F] = 0x67, [0x50] = 0x7B, [0x51] = 0x3D, [0x52] = 0x02, [0x53] = 0x19, 
	[0x54] = 0xBA, [0x55] = 0xB4, [0x56] = 0x80, [0x57] = 0x22, [0x58] = 0x0E, [0x59] = 0xDB, [0x5A] = 0x64, [0x5B] = 0xB3, [0x5C] = 0x1B, [0x5D] = 0x52, [0x5E] = 0x79, [0x5F] = 0x32, 
	[0x60] = 0xA7, [0x61] = 0xDD, [0x62] = 0xA6, [0x63] = 0x6A, [0x64] = 0x57, [0x65] = 0x97, [0x66] = 0xC4, [0x67] = 0xA1, [0x68] = 0x16, [0x69] = 0x3A, [0x6A] = 0xF2, [0x6B] = 0xE1, 
	[0x6C] = 0x3E, [0x6D] = 0x5B, [0x6E] = 0xB2, [0x6F] = 0xCE, [0x70] = 0x46, [0x71] = 0x8A, [0x72] = 0x30, [0x73] = 0xF1, [0x74] = 0x6E, [0x75] = 0x00, [0x76] = 0x6F, [0x77] = 0x88, 
	[0x78] = 0x1A, [0x79] = 0x0B, [0x7A] = 0xB5, [0x7B] = 0xA2, [0x7C] = 0xB6, [0x7D] = 0x4A, [0x7E] = 0x99, [0x7F] = 0xA5, [0x80] = 0xCB, [0x81] = 0x31, [0x82] = 0x07, [0x83] = 0x08, 
	[0x84] = 0xF4, [0x85] = 0xA4, [0x86] = 0x25, [0x87] = 0x2C, [0x88] = 0xAB, [0x89] = 0xAC, [0x8A] = 0x13, [0x8B] = 0x14, [0x8C] = 0x34, [0x8D] = 0xAF, [0x8E] = 0x90, [0x8F] = 0xCA, 
	[0x90] = 0x6D, [0x91] = 0xDE, [0x92] = 0x69, [0x93] = 0xFD, [0x94] = 0xDC, [0x95] = 0xA0, [0x96] = 0x36, [0x97] = 0x6C, [0x98] = 0xE8, [0x99] = 0x7A, [0x9A] = 0x9D, [0x9B] = 0x27, 
	[0x9C] = 0xF3, [0x9D] = 0x5D, [0x9E] = 0x47, [0x9F] = 0x18, [0xA0] = 0x23, [0xA1] = 0x9A, [0xA2] = 0xBF, [0xA3] = 0xD1, [0xA4] = 0xE5, [0xA5] = 0xC6, [0xA6] = 0xD4, [0xA7] = 0x8C, 
	[0xA8] = 0x04, [0xA9] = 0xB9, [0xAA] = 0x1D, [0xAB] = 0xF0, [0xAC] = 0x63, [0xAD] = 0xD9, [0xAE] = 0x76, [0xAF] = 0x0A, [0xB0] = 0x53, [0xB1] = 0x6B, [0xB2] = 0xE0, [0xB3] = 0x2B, 
	[0xB4] = 0x9E, [0xB5] = 0x83, [0xB6] = 0xD8, [0xB7] = 0xFE, [0xB8] = 0xBC, [0xB9] = 0x8F, [0xBA] = 0xEA, [0xBB] = 0x4D, [0xBC] = 0x41, [0xBD] = 0xC2, [0xBE] = 0x92, [0xBF] = 0xBD, 
	[0xC0] = 0x09, [0xC1] = 0x1C, [0xC2] = 0xAA, [0xC3] = 0xF9, [0xC4] = 0x17, [0xC5] = 0x61, [0xC6] = 0xC0, [0xC7] = 0x44, [0xC8] = 0x85, [0xC9] = 0x74, [0xCA] = 0x5A, [0xCB] = 0x9F, 
	[0xCC] = 0x0C, [0xCD] = 0xAD, [0xCE] = 0x77, [0xCF] = 0xEC, [0xD0] = 0x21, [0xD1] = 0x60, [0xD2] = 0xCF, [0xD3] = 0xE7, [0xD4] = 0x86, [0xD5] = 0x37, [0xD6] = 0xD6, [0xD7] = 0x11, 
	[0xD8] = 0xD2, [0xD9] = 0xCD, [0xDA] = 0xFF, [0xDB] = 0xF7, [0xDC] = 0x33, [0xDD] = 0x8B, [0xDE] = 0xF8, [0xDF] = 0x78, [0xE0] = 0x4B, [0xE1] = 0x28, [0xE2] = 0xFC, [0xE3] = 0xE2, 
	[0xE4] = 0x56, [0xE5] = 0xA8, [0xE6] = 0x35, [0xE7] = 0x62, [0xE8] = 0x5E, [0xE9] = 0x96, [0xEA] = 0xDF, [0xEB] = 0xCC, [0xEC] = 0xAE, [0xED] = 0x81, [0xEE] = 0x3F, [0xEF] = 0x05, 
	[0xF0] = 0x4F, [0xF1] = 0x55, [0xF2] = 0xE9, [0xF3] = 0xBE, [0xF4] = 0xB0, [0xF5] = 0x50, [0xF6] = 0x24, [0xF7] = 0x59, [0xF8] = 0xB8, [0xF9] = 0x1E, [0xFA] = 0x72, [0xFB] = 0x48, 
	[0xFC] = 0x8D, [0xFD] = 0x42, [0xFE] = 0x01, [0xFF] = 0x73, 
}

local loadMsg, MainMenu = '', nil
function OnLoad()
	HookPackets()
	TEAM_ALLY, TEAM_ENEMY = myHero.team, myHero.team == 100 and 200 or 100
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	WARD()
	MISS()
	SKILLS()
	TIMERS()
	TRINKET()
	OTHER()
	local Version = 0.99
	ScriptUpdate(Version, 'raw.githubusercontent.com', '/PewPewPew2/BoL/Danger-Meter/MoarSaltThanAroc.version', '/PewPewPew2/BoL/Danger-Meter/MoarSaltThanAroc.lua', SCRIPT_PATH.._ENV.FILE_NAME, function() Print('Update Complete. Reload(F9 F9)') end, function() Print(loadMsg:sub(1,#loadMsg-2)) end, function() Print('New Version Found, please wait...') end, function() Print('An Error Occured in Update.') end)
end

class "ScriptUpdate"

function ScriptUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript3.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript3.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:OnDraw()
	local bP = {['x1'] = WINDOW_W - (WINDOW_W - 390),['x2'] = WINDOW_W - (WINDOW_W - 20),['y1'] = WINDOW_H / 2,['y2'] = (WINDOW_H / 2) + 20,}
	local text = 'Download Status: '..(self.DownloadStatus or 'Unknown')
	DrawLine(bP.x1, bP.y1 + 10, bP.x2,  bP.y1 + 10, 18, ARGB(0x7D,0xE1,0xE1,0xE1))
	DrawLine(bP.x2 + ((self.File and self.Size) and (370 * (math.round(100/self.Size*self.File:len(),2)/100)) or 0), bP.y1 + 10, bP.x2, bP.y1 + 10, 18, ARGB(0xC8,0xE1,0xE1,0xE1))
	DrawLines2({D3DXVECTOR2(bP.x1, bP.y1),D3DXVECTOR2(bP.x2, bP.y1),D3DXVECTOR2(bP.x2, bP.y2),D3DXVECTOR2(bP.x1, bP.y2),D3DXVECTOR2(bP.x1, bP.y1),}, 3, ARGB(0xB9, 0x0A, 0x0A, 0x0A))
	DrawText(text, 16, WINDOW_W - (WINDOW_W - 205) - (GetTextArea(text, 16).x / 2), bP.y1 + 2, ARGB(0xB9,0x0A,0x0A,0x0A))
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.Socket = self.LuaSocket.connect('sx-bol.eu', 80)
    self.Socket:send("GET "..url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</size>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<size>')+6,self.File:find('</size>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading VersionInfo ('..('%.2f'):format(math.round(100/self.Size*self.File:len(),2))..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local HeaderEnd, ContentStart = self.File:find('<script>')
        local ContentEnd, _ = self.File:find('</script>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1,ContentEnd-1))
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</size>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<size>')+6,self.File:find('</size>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading Script ('..('%.2f'):format(math.round(100/self.Size*self.File:len(),2))..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Download Complete.'
        local HeaderEnd, ContentStart = self.File:find('<script>')
        local ContentEnd, _ = self.File:find('</script>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
				self.DownloadStatus = 'Download Error!'
                self.CallbackError()
            end
        else
            local f = io.open(self.SavePath,"w+")
            f:write(self.File:sub(ContentStart + 1,ContentEnd-1))
            f:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
        self.GotScriptUpdate = true
    end
end

function Print(text)
	print('<font color=\'#0099FF\'>[Pewtility] </font> <font color=\'#FF6600\'>'..text..'.</font>')
end


class 'WARD'

function WARD:__init()
	self.types = {
		['YellowTrinket'] 		 = { color = ARGB(255, 255, 255, 50), 	duration = 60, 		  },
		['YellowTrinketUpgrade'] = { color = ARGB(255, 255, 255, 50),	duration = 120, 	  },
		['SightWard'] 			 = { color = ARGB(255, 0, 255, 0),		duration = 180, 	  },
		['VisionWard']  		 = { color = ARGB(255, 255, 50, 255), 	duration = huge,	  },
		['TeemoMushroom'] 		 = { color = ARGB(255, 255, 0, 0),		duration = 600, 	  },
		['CaitlynTrap'] 		 = { color = ARGB(255, 255, 0, 0),		duration = 240, 	  },
		['Nidalee_Spear'] 		 = { color = ARGB(255, 255, 0, 0),		duration = 120, 	  },
		['ShacoBox'] 			 = { color = ARGB(255, 255, 0, 0),		duration = 60, 		  },
		['DoABarrelRoll'] 		 = { color = ARGB(255, 255, 0, 0),		duration = 35, 		  },
	}
	self.onSpell = {
		['sightward'] = self.types['SightWard'], ['visionward'] = self.types['VisionWard'], ['itemghostward'] = self.types['SightWard'], ['trinkettotemlvl2'] =  self.types['YellowTrinketUpgrade'],
		['trinkettotemlvl1'] = self.types['YellowTrinket'], ['trinkettotemlvl3'] = self.types['SightWard'], ['trinkettotemlvl3b'] = self.types['VisionWard'], ['bantamtrap'] = self.types['TeemoMushroom'],
		['caitlynyordletrap'] = self.types['CaitlynTrap'], ['bushwhack'] = self.types['Nidalee_Spear'], ['jackinthebox'] = self.types['ShacoBox'], ['maokaisapling'] = self.types['DoABarrelRoll'],
	}
	self.known = {}
	self.wM = self:Menu()
	AddDrawCallback(function() self:Draw() end)
	AddProcessSpellCallback(function(u, s) self:ProcessSpell(u, s) end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	loadMsg = loadMsg..'WardTracker, '
end

function WARD:Menu()
	MainMenu:addSubMenu('Ward Tracker', 'WardTracker')
	local wM = MainMenu.WardTracker
	wM:addParam('draw', 'Enable Ward Timers', SCRIPT_PARAM_ONOFF, true)
	wM:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	wM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	wM:addParam('mapsize', 'Minimap Marker Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	wM:addParam('maptype', 'Minimap Marker Type', SCRIPT_PARAM_LIST, 1, { 'Marker', 'Timer' })
	return wM
end

function WARD:CreateObj(o)
	if o.valid and o.team == TEAM_ENEMY and self.types[o.charName] then
		local timeReduction = 0
		local charName
		for id, ward in pairs(self.known) do
			if ward and GetDistanceSqr(ward.pos, o.pos) < 40000 then
				timeReduction = (ward and self.types[o.charName]) and self.types[o.charName].duration - (ward.endTime-clock()) or 0
				charName = ward.charName
				self.known[id] = nil
			end
		end
		if not charName and o.spellOwner and #o.spellOwner.charName < 20 then
			charName = o.spellOwner.charName
		end
		self.known[o.networkID] = {
			pos 		= Vector(o.x, o.y, o.z),
			minimap   	= GetMinimap(Vector(o.x, o.y, o.z)), 
			color 		= self.types[o.charName].color, 
			endTime 	= (self.types[o.charName].duration ~= huge) and clock()+self.types[o.charName].duration-timeReduction or clock()+self.types[o.charName].duration,
			charName 	= charName or 'Unkown', 
		}	
	end
end

function WARD:DeleteObj(o)
	if o.valid and self.known[o.networkID] then
		self.known[o.networkID] = nil
	end
end

function WARD:Draw()
	if not self.wM.draw then return end
	for i, o in pairs(self.known) do
		local timer = ceil(o.endTime-clock())
		local tText = (self.wM.type == 1 or o.endTime == huge) and tostring(ceil(timer)) or floor(timer/60)..':'..('%.2d'):format(timer%60)
		local text = (o.endTime ~= huge and o.charName) and tText..'\n'..o.charName or o.charName
		DrawText3D(text, o.pos.x, o.pos.y+85, o.pos.z+10, self.wM.size, o.color, true)
		DrawText((self.wM.mapTpe == 1 or o.endTime == huge) and 'o' or tText, self.wM.mapsize, o.minimap.x-(self.wM.mapsize/6), o.minimap.y-(self.wM.mapsize/6), o.color)
		self:DrawHex(o.pos.x, o.pos.y, o.pos.z, o.color)
		if o.endTime < clock() then
			self.known[i] = nil
		end
	end
end

function WARD:ProcessSpell(u, s)
	if u.valid and u.team == TEAM_ENEMY and self.onSpell[s.name:lower()] then
		self.known[#self.known+1] = {
			pos 		= Vector(s.endPos.x, s.endPos.y, s.endPos.z),
			minimap   	= GetMinimap(Vector(s.endPos.x, s.endPos.y, s.endPos.z)),
			color 		= self.onSpell[s.name:lower()].color,
			endTime 	= clock()+self.onSpell[s.name:lower()].duration,
			charName 	= u.charName,
		}
	end
end

function WARD:DrawHex(x, y, z, c)
    local hex = {}
    for theta = 0, (pi2+(pi2/6)), (pi2/6) do
        local tS = WorldToScreen(D3DXVECTOR3(x+(75*cos(theta)), y, z-(75*sin(theta))))
        hex[#hex + 1] = D3DXVECTOR2(tS.x, tS.y)
    end
	if OnScreen({x = hex[1].x, y = hex[1].y}, {x = hex[4].x, y = hex[4].y}) then
		DrawLines2(hex, 1, c)
	end
end

class 'MISS'

function MISS:__init()
	self.missing = {}
	self.activeRecalls = {}
	for i=0, objManager.maxObjects do
		local o = objManager:getObject(i)
		if o and o.name:find('__Spawn_T') and o.team == TEAM_ENEMY then
			self.recallEndPos = GetMinimap(Vector(o.pos))
		end
	end
	self.recallTimes = {
		['recall'] = 7.9,
		['odinrecall'] = 4.4,
		['odinrecallimproved'] = 3.9,
		['recallimproved'] = 6.9,
		['superrecall'] = 3.9,
	}
	self.Colors = {ARGB(255, 255, 0, 255), ARGB(255, 0, 255, 0), ARGB(255, 255, 0, 0), ARGB(255, 0, 0, 255), ARGB(255, 255, 255, 0)}
	self.recallBar = GetMinimap(0, 18000)
	for i=1, heroManager.iCount do ---??
		if heroManager:getHero(i).team == TEAM_ENEMY then
			self.missing[heroManager:getHero(i).networkID] = nil
		end
	end
	self.mM = self:Menu()
	AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
	AddDrawCallback(function() self:Draw() end)
	loadMsg = loadMsg..'MissTimers, '
end

function MISS:Menu()
	MainMenu:addSubMenu('Missing Enemies', 'MissTracker')
	local mM = MainMenu.MissTracker
	mM:addParam('draw', 'Enable Missing Timers', SCRIPT_PARAM_ONOFF, true)
	mM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	mM:addParam('recall', 'Display Recall Status', SCRIPT_PARAM_ONOFF, true)
	return mM	
end

function MISS:RecvPacket(p)
	if p.header == 0x006B then --losevision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.dead then
				self.missing[o.networkID] = {
					pos = self.recallEndPos,
					name = o.charName, 
					mTime = clock(),
				}			
			else
				self.missing[o.networkID] = {
					pos = GetMinimap(Vector(o.pos)),
					name = o.charName, 
					mTime = clock(),
				}
				return
			end
		end	
	end
	if p.header == 0x001A then --gainvision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.missing[o.networkID] = nil
			return
		end
	end
	if p.header == 0x0101 then --recall
		p.pos = 7
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = IDBytes[p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			p.pos=60
			local str = ''
			for i=1, p.size do
				local char = p:Decode1()
				if char == 0 then break end
				str=str..string.char(char)
			end
			if self.recallTimes[str:lower()] then
				local r = {}
				r.name = o.charName
				r.startT = clock()
				r.duration = self.recallTimes[str:lower()]
				r.endT = r.startT + r.duration
				self.activeRecalls[o.networkID] = r
				return
			elseif self.activeRecalls[o.networkID] then
				if self.activeRecalls[o.networkID] and self.activeRecalls[o.networkID].endT > clock() then
					self.activeRecalls[o.networkID] = nil
					return
				else
					self.missing[o.networkID] = {pos = self.recallEndPos, name = o.charName, mTime = clock(),}
					self.activeRecalls[o.networkID] = nil
					return
				end
			end
		end
	end
end

function MISS:Draw()
	if not self.mM.draw then return end
	local mCount = 1
	for _, info in pairs(self.missing) do
		if info then
			DrawText(info.name, self.mM.size, self.recallBar.x - 60 - (GetTextArea(info.name, self.mM.size).x / 2), WINDOW_H - 80 - (12 * mCount) - (self.mM.size / 6), self.Colors[mCount])	
			DrawText(tostring(ceil(clock()-info.mTime)), self.mM.size, info.pos.x - (self.mM.size / 6), info.pos.y - (self.mM.size / 6), self.Colors[mCount])
			mCount = mCount + 1
		end
	end
	if self.mM.recall then
		local count = 0
		for _, info in pairs(self.activeRecalls) do
			local yOffset = count * -30
			local percent = (info.endT - clock()) / info.duration
			local x2 = self.recallBar.x + ((WINDOW_W - 10 - self.recallBar.x) * percent)
			if x2 > self.recallBar.x then
				DrawLine(self.recallBar.x, self.recallBar.y + yOffset, x2, self.recallBar.y + yOffset, 16, ARGB(255, 255 * percent, 255 - (255 * percent), 0))
				local Lines = {
					D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y - 8 + yOffset),
					D3DXVECTOR2(WINDOW_W - 10, 			self.recallBar.y - 8 + yOffset),
					D3DXVECTOR2(WINDOW_W - 10, 			self.recallBar.y + 8 + yOffset),
					D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y + 8 + yOffset),
					D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y - 8 + yOffset),
				}
				DrawLines2(Lines, 2, ARGB(255, 255, 255, 255))
				local text = info.name..' '..ceil(percent * 100)..'%'
				DrawText(text, 12, ((self.recallBar.x + (WINDOW_W - 10)) / 2) - (GetTextArea(text, 12).x / 2), self.recallBar.y - 6 + yOffset, ARGB(255,255,255,255))
			end
			count = count + 1
		end
	end
end

class 'SKILLS'

function SKILLS:__init()
	self.enemies = {}
	self.allies = {}
	self.sumText = {
		['summonerdot']      		= 'Ign',
		['summonerexhaust']  		= 'Exh',
		['summonerflash']    		= 'Fla',
		['summonerheal']     		= 'Hea',
		['summonersmite']    		= 'Smi',
		['summonerbarrier']  		= 'Bar',
		['summonerclairvoyance']    = 'Cla',
		['summonermana']     		= 'Cla',
		['summonerteleport']     	= ' TP',
		['summonerrevive']     		= 'Rev',
		['summonerhaste']     		= 'Gho',
		['summonerboost']     		= 'Cle',
	}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ENEMY then
			self.enemies[#self.enemies+1] = {
				hero = h,
				sum1 = self.sumText[h:GetSpellData(SUMMONER_1).name:lower()],
				sum2 = self.sumText[h:GetSpellData(SUMMONER_2).name:lower()],
			}
		elseif h ~= myHero then
			self.allies[#self.allies+1] = {
				hero = h,
				sum1 = self.sumText[h:GetSpellData(SUMMONER_1).name:lower()],
				sum2 = self.sumText[h:GetSpellData(SUMMONER_2).name:lower()],
			}		
		end
	end
	self:HudData()
	self.AllyHud = {
		['xLeft']   	= floor((29  * (WINDOW_H / 1080))  * self.HudScale),
		['xRight']  	= floor((49  * (WINDOW_H / 1080))  * self.HudScale),
		['yUp']     	= floor((102 * (WINDOW_H / 1080)) * self.HudScale),
		['size']    	= floor((42  * (WINDOW_H / 1080))  * self.HudScale),
		['skill']   	= floor((13  * (WINDOW_H / 1080))  * self.HudScale),
		['lineOffset'] 	= floor(((8  * (WINDOW_H / 1080))  * self.HudScale) / 2),
		['lineWidth']   = floor(7.5 * self.HudScale),
	}
	self.HeroOffsets = {
		['aatrox']   = -4,		['anivia']		= -2,	['diana']	   =  4,	['fiora']	 = -2,		['gnar']		= -2,	['gragas']	   = -3,
		['janna']	 = -2,		['jayce']		= -2,	['karma']	   = -2,	['kassadin'] = -4,		['kennen']		= -2,	['khazix']	   = -1,
		['leblanc']  =  1,		['leesin']		= -2,	['lulu']  	   = -4,	['nami']     = -4,		['nautilus']	= -4,	['olaf']   	   = -4,
		['orianna']  = -3,		['pantheon']	= -2,	['poppy']      = -4,	['quinn']    = -1,		['quinnvalor']	= -9,	['rammus']     = -1,
		['riven']    = -4,		['rumble']		= -4,	['sion']       = -2,	['sona']     = -5,		['syndra']		= -2,	['teemo']      = -2,
		['twitch']   = -1,		['tryndamere']  = -1,	['urgot']      = -2,	['velkoz']   = -12,		['volibear'] 	= -2,	['vi']         = -1,
		['xerath']   = -2,		['yasuo'] 		= -4,	['zac']        = -1,	['alistar']  = -4,  	['annie']       = -4,  	['blitzcrank'] = -4,
		['brand']    = -3,   	['cassiopeia']  = -2, 	['darius']     = -2,	['drmundo']  =  1,  	['galio']       =  1,  	['garen']      =  1,
		['jarvaniv'] =  2,  	['jax']         = -4,   ['lux']        = -4,	['lucian']   = -4,  	['kayle']       = -5,  	['tristana']   = -3,
		['malzahar'] = -2,  	['missfortune'] = -4,   ['morgana']    = -2,	['nunu']     = -2,      ['renekton']    = -2,	['soraka']     = -5,
		['ryze']     = -3,      ['shen']		= -4,	['shyvana']    = -1,	['swain']    = -3,		['trundle']     =  4,   ['xinzhao']    =  7,
		['ziggs']    = -3,		['zilean']      = -2,	['braum']      = -3,	['corki']    = -4,		['viktor']      = -3,	['azir']       = -2,
		['kalista']  = -4,
	}
	self.sM = self:Menu()
	self.toText = {' Q ',' W ',' E ',' R '}
	AddDrawCallback(function() self:Draw() end)
	loadMsg = loadMsg..'CDTracker, '
end

function SKILLS:Menu()
	MainMenu:addSubMenu('Cooldown Tracker', 'CooldownTracker')
	local sM = MainMenu.CooldownTracker
	sM:addParam('draw', 'Enable Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)	
	return sM
end

function SKILLS:Draw()	
	if not self.sM.draw then return end
	for _, info in ipairs({{hero=myHero, sum1 = 'ign', sum2='exh'}}) do
		local enemy = info.hero
		if enemy.valid and enemy.visible and not enemy.dead then
			local barData = self:BarData(enemy)
			if OnScreen(barData.x, barData.y) then
				for i=_Q, SUMMONER_2 do
					local data = enemy:GetSpellData(i)
					local color = (data.level>0 and data.currentCd == 0) and ARGB(255,0,255,0) or ARGB(255,255,0,0)
					local text,x,y
					if i<=_R then
						x = barData.x-22+(i*27)
						local offset = self.HeroOffsets[enemy.charName:lower()] or 0
						y = barData.y+6+offset
						text = data.currentCd == 0 and self.toText[i+1] or tostring(ceil(data.cd-(data.cd-data.currentCd)))
						DrawText(text, 12, x + 7 - (GetTextArea(text, 12).x / 2), y, color)
						DrawLines2({D3DXVECTOR2(x-4, y+12), D3DXVECTOR2(x-4, y), D3DXVECTOR2(x+20, y), D3DXVECTOR2(x+20, y+12)}, 2, color)			
					else
						text = info['sum'..(i-3)]
						x = barData.x-76+((i-2)*27)
						local offset = self.HeroOffsets[enemy.charName:lower()] or 0
						y = barData.y+38+offset
						if data.currentCd == 0 then
							DrawLines2({D3DXVECTOR2(x-4, y), D3DXVECTOR2(x-4, y+13), D3DXVECTOR2(x+20, y+13), D3DXVECTOR2(x+20, y)}, 2, color)
						else
							local Lines = {}
							local cd = ceil(data.currentCd*100/data.cd/2)
							for j=1, 13 do Lines[#Lines+1] = D3DXVECTOR2(x-4, y+j) end
							for j=1, 24 do Lines[#Lines+1] = D3DXVECTOR2(x-4+j, y+13) end
							for j=1, 13 do Lines[#Lines+1] = D3DXVECTOR2(x+20, y+13-j) end
							local LinesRed, LinesYellow = {}, {}
							for j=1, cd do LinesRed[#LinesRed+1] = Lines[j] end
							for j=cd, #Lines do LinesYellow[#LinesYellow+1] = Lines[j] end
							DrawLines2(LinesYellow, 2, ARGB(255,255,255,0))
							DrawLines2(LinesRed, 2, ARGB(255,255,0,0))
						end
						DrawText(text, 12, x + 8 - (GetTextArea(text, 12).x / 2), y, color)
					end
				end
			end
		end
	end
	for i, info in ipairs(self.allies) do
		if info.hero.valid then
			for j=_R, SUMMONER_2 do
				local data = info.hero:GetSpellData(j)
				local y = ((j - 3) * self.AllyHud.skill) + (self.AllyHud.yUp + (self.AllyHud.size * (i - 1)))
				local Lines = {
					D3DXVECTOR2(self.AllyHud.xLeft,  y + self.AllyHud.lineOffset), 
					D3DXVECTOR2(self.AllyHud.xRight, y + self.AllyHud.lineOffset),
					D3DXVECTOR2(self.AllyHud.xRight, y - self.AllyHud.lineOffset),
					D3DXVECTOR2(self.AllyHud.xLeft,  y - self.AllyHud.lineOffset),
					D3DXVECTOR2(self.AllyHud.xLeft,  y + self.AllyHud.lineOffset),
				}
				local offset = floor(self.HudScale*0.75)
				DrawLines2(Lines, 1+offset, ARGB(150,255,255,255))
				if data.currentCd == 0 then
					DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xRight, y, self.AllyHud.lineWidth, ARGB(150,0,255,0))
				else
					local cd = data.currentCd/data.cd
					DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, self.AllyHud.lineWidth, ARGB(150,255,0,0))
					DrawLine(self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, self.AllyHud.xRight, y, self.AllyHud.lineWidth, ARGB(150,255,255,0))				
				end
				if j ~= _R then
					text = info['sum'..j-3]
					DrawText(text, floor(8 * self.HudScale), self.AllyHud.xLeft + self.AllyHud.lineOffset, y - self.AllyHud.lineOffset, ARGB(255,255,255,255))
				end
			end
		end
	end
end

function SKILLS:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	return {['x'] = floor(barPos.x+(barPosOffset.x-0.55)*70), ['y'] = floor(barPos.y+(barPosOffset.y-0.5)*45),}
end

function SKILLS:HudData()
	local gameSettings = GetGameSettings()
	if gameSettings and gameSettings.General and gameSettings.General.Width and gameSettings.General.Height then
		windowWidth, windowHeight = gameSettings.General.Width, gameSettings.General.Height
		local path = GAME_PATH .. 'DATA\\menu\\hud\\hud' .. windowWidth .. 'x' .. windowHeight .. '.ini'
		local hudSettings = ReadIni(path)
		if hudSettings and hudSettings.Globals and hudSettings.Globals.GlobalScale then 
			self.HudScale = hudSettings.Globals.GlobalScale + 1
		end
	end
end

class 'TIMERS'

function TIMERS:__init()
	self.map = GetGame().map.shortName
	if self.map == 'summonerRift' then		--Done
		self.pos = {
			[0x19] = Vector(3850, 60, 7880),	--bottom blue
			[0x12] = Vector(3800, 60, 6500), 	--bottom wolves
			[0x87] = Vector(7000, 60, 5400),	--bottom raptors
			[0x73] = Vector(7800, 60, 4000), 	--bottom red
			[0x77] = Vector(8400, 60, 2700), 	--bottom krugs
			[0x57] = Vector(9866, 60, 4414),	--dragon
			[0x4C] = Vector(10950, 60, 7030),	--top blue
			[0xF6] = Vector(11000, 60, 8400),	--top wolves
			[0x8A] = Vector(7850, 60, 9500),	--top raptors
			[0x95] = Vector(7100, 60, 10900),	--top red
			[0xED] = Vector(6400, 60, 12250),	--top krugs
			[0x43] = Vector(4950, 60, 10400),	--baron
			[0xE5] = Vector(2200, 60, 8500),	--bottom frog
			[0x42] = Vector(12600, 60, 6400),	--top frog
			[0x04] = Vector(10500, 60, 5170),	--bottom crab
			[0xBC] = Vector(4400, 60, 9600),	--top crab
		}
		self.times = {
			[0x19] = 300,
			[0x12] = 100,
			[0x87] = 100,
			[0x73] = 300,
			[0x77] = 100,
			[0x57] = 360,
			[0x4C] = 300,
			[0xF6] = 100,
			[0x8A] = 100,
			[0x95] = 300,
			[0xED] = 100,
			[0x43] = 420,
			[0xE5] = 100,
			[0x42] = 100,
			[0x04] = 180,
			[0xBC] = 180,
		}
		self.inhibs = {
			[4291968062] = 100,
			[4283048177] = 101, 
			[4287824865] = 102, 
			[4284978128] = 200,
			[4294938399] = 201, 
			[4280724495] = 202,
		}
		self.inhibPos = {
			[100] = Vector(1171, 91, 3571), 
			[101] = Vector(3203, 92, 3208), 
			[102] = Vector(3452, 89, 1236), 
			[200] = Vector(11261, 88, 13676), 
			[201] = Vector(11598, 89, 11667),
			[202] = Vector(13604, 89, 11316),
		}
		self.inhibTime = 300
	elseif self.map == 'twistedTreeline' then
		self.pos = {
			[0x19] = Vector(4414, 60, 5774), 
			[0x12] = Vector(5088, 60, 8065), 
			[0x87] = Vector(6148, 60, 5993), 
			[0x73] = Vector(11008, 60, 5775),
			[0x77] = Vector(10341, 60, 8084), 
			[0x57] = Vector(9239, 60, 6022), 
			[0x4C] = Vector(7711, 60, 6722), 
			[0xF6] = Vector(7711, 60, 10080),
		}	
		self.times = {
			[0x19] = 75,
			[0x12] = 75,
			[0x87] = 75,
			[0x73] = 75,
			[0x77] = 75,
			[0x57] = 75,
			[0x4C] = 90,
			[0xF6] = 300,
		}
		self.inhibs = { 
			[4287824865] = 100,
			[4291968062] = 101, 
			[4284978128] = 201, 
			[4280724495] = 200,
		}
		self.inhibPos = { 
			[100] = Vector(2126, 11, 6146), 
			[101] = Vector(2146, 11, 8420), 
			[200] = Vector(13285, 17, 6124), 
			[201] = Vector(13275, 17, 8416),
		}
		self.inhibTime = 240
	elseif self.map == 'howlingAbyss' then	--done
		self.pos = {
			[0x19] = Vector(7582, -100, 6785), 
			[0x12] = Vector(5929, -100, 5190), 
			[0x87] = Vector(8893, -100, 7889), 
			[0x73] = Vector(4790, -100, 3934),
		}
		self.times = {
			[0x19] = 40,
			[0x12] = 40,
			[0x87] = 40,
			[0x73] = 40,
		}
		self.inhibs = { 
			[4283048177] = 100, 
			[4294938399] = 200, 
		}
		self.inhibPos = { 
			[100] = Vector(3110, -201, 3189), 
			[200] = Vector(9689, -190, 9524),
		}
		self.inhibTime = 300
	elseif self.map == 'crystalScar' then		--done
		self.pos = { 
			 [0x25] = Vector(4948, -100, 9329),  
			 [0xC3] = Vector(8972, -100, 9329), 
			 [0x07] = Vector(6949, -100, 2855), 
			 [0x41] = Vector(6947, -100, 12116),
			 [0xE0] = Vector(12881, -100, 8294), 
			 [0xBD] = Vector(10242, -100, 1519), 
			 [0x88] = Vector(3639, -100, 1490), 
			 [0x40] = Vector(1027, -100, 8288), 
			 [0x85] = Vector(4324, -100, 5500),
			 [0xE7] = Vector(9573, -100, 5530), 
		}
		self.times = {
			 [0x25] = 30, 
			 [0xC3] = 30, 
			 [0x07] = 30,
			 [0x41] = 30, 
			 [0xE0] = 30, 
			 [0xBD] = 30, 
			 [0x88] = 30, 
			 [0x40] = 30, 
			 [0x85] = 30, 
			 [0xE7] = 30, 
		}
	end
	self.activeTimers = {}
	self.checkLastDragon = false
	self.checkLastBaron = false
	self.tM = self:Menu()
	AddTickCallback(function() self:Tick() end)
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	
	loadMsg = loadMsg..'ObjectTimers, '
end

function TIMERS:Menu()
	MainMenu:addSubMenu('Object Timers', 'ObjectTimers')
	local tM = MainMenu.ObjectTimers
	tM:addParam('draw', 'Enable Object Timers', SCRIPT_PARAM_ONOFF, true)
	tM:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	tM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('RGB', 'Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})	
	tM:addParam('mapsize', 'Minimap Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('mapRGB', 'Minimap Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})
	tM:addParam('modKey', 'Modifier Key(Default: Alt)', SCRIPT_PARAM_ONKEYDOWN, false, 18)
	tM:addParam('', 'ModKey+LeftClick a camp to start a timer.', SCRIPT_PARAM_INFO, '')
	return tM
end

function TIMERS:Draw()
	if not self.tM.draw then return end
	for camp, info in pairs(self.activeTimers) do
		local timer = ceil(info.spawnTime-clock())
		local text = (self.tM.type == 1) and tostring(ceil(timer)) or floor(timer/60)..':'..('%.2d'):format(timer%60)
		DrawText3D(text, info.pos.x, info.pos.y, (info.pos.z-50), self.tM.size, ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4]))
		DrawText(text, self.tM.mapsize, info.minimap.x-5, info.minimap.y-5, ARGB(self.tM.mapRGB[1], self.tM.mapRGB[2], self.tM.mapRGB[3], self.tM.mapRGB[4]))
		if timer < 1 then self.activeTimers[camp] = nil end
	end
end

function TIMERS:Tick()
	if self.checkLastDragon then
		local hD = {['h'] = nil, ['d'] = 0, ['b'] = 0,}
		for i=1, heroManager.iCount do
			local h = heroManager:getHero(i)
			if h and h.valid and h.team == TEAM_ENEMY and h.visible then
				for j=1, h.buffCount do
					local b = h:getBuff(j)
					if b and b.name and b.name:lower():find('dragonslayerbuff') then
						for d=5,1,-1 do
							if b.name:lower():find('v'..tostring(d)) and d>hD.d then
								hD.d=d
								hD.b=j
								hD.h=h
							end
						end
					end
				end
			end
		end
		if hD.h then
			local b = hD.h:getBuff(hD.b)
			if b.startT+356 > clock() then
				self.activeTimers[0x1F] = {spawnTime = b.startT+356, pos = self.pos[0x1F], minimap = GetMinimap(self.pos[0x1F]),}
				self.checkLastDragon = false
			end
		end
	end
	if self.checkLastBaron then
		for i=1, heroManager.iCount do
			local h = heroManager:getHero(i)
			if h and h.valid and h.team == TEAM_ENEMY and h.visible then
				for j=1, h.buffCount do
					local b = h:getBuff(j)
					if b and b.name and b.name:lower():find('exaltedwithbaronnashor') then
						self.activeTimers[0x05] = {spawnTime = b.startT+416, pos = self.pos[0x05], minimap = GetMinimap(self.pos[0x05]),}
						self.checkLastBaron = false
						return
					end
				end
			end
		end
	end
end

function TIMERS:RecvPacket(p)
	if p.header == 0x0044 then
		p.pos = 10
		local camp = p:Decode1()
		if self.pos[camp] then
			p.pos = 14
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[p:Decode1()]
			end
			local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
			local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
			if not o then 
				if camp == 0x1F and self.map == 'summonerRift' then
					self.checkLastDragon = true
				elseif camp == 0x05 and self.map == 'summonerRift' then
					self.checkLastBaron = true
				end
				return
			end
			self.activeTimers[camp] = {spawnTime = clock()+self.times[camp], pos = self.pos[camp], minimap = GetMinimap(self.pos[camp]),}
		end
		return
	end
	if p.header == 0x0080 then
		p.pos=2
		local inhib = p:Decode4()
		if self.inhibs[inhib] then
			self.activeTimers[self.inhibs[inhib]] = {spawnTime = clock()+self.inhibTime, pos = self.inhibPos[self.inhibs[inhib]], minimap = GetMinimap(self.inhibPos[self.inhibs[inhib]]),}
		end
		return
	end
end

function TIMERS:WndMsg(m,k)
	if m == 513 and k == 1 and IsKeyDown(self.tM._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for camp, pos in pairs(self.pos) do
			local miniMap = GetMinimap(pos)
			if abs(cP.x-miniMap.x) < 17 and abs(cP.y-miniMap.y) < 17 then
				self.activeTimers[camp] = {spawnTime = clock()+self.times[camp], pos = pos, minimap = miniMap,}
				return
			end
		end
	end
end

class 'OTHER'

function OTHER:__init()
	self.Turrets = {}
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and obj.type == 'obj_AI_Turret' and obj.team == TEAM_ENEMY and obj.name:find('Shrine') ==  nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	self.enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ENEMY then
			self.enemies[#self.enemies+1] = h	
		end
	end
	self.oM = self:Menu()
	AddDrawCallback(function() self:Draw() end)
end

function OTHER:Menu()
	MainMenu:addSubMenu('Other Stuff', 'Other')
	local oM = MainMenu.Other
	oM:addParam('path', 'Draw Enemy Paths', SCRIPT_PARAM_ONOFF, true)
	oM:addParam('type', 'Path Draw Type', SCRIPT_PARAM_LIST, 1, { 'Lines', 'End Position', })
	oM:addParam('turret', 'Draw Turret Ranges', SCRIPT_PARAM_ONOFF, true)
	return oM
end

function OTHER:Draw()
	if self.oM.turret then
		for i=1, #self.Turrets do
			if self.Turrets[i] and self.Turrets[i].valid and not self.Turrets[i].dead then
				local c = WorldToScreen(D3DXVECTOR3(self.Turrets[i].pos.x, self.Turrets[i].pos.y, self.Turrets[i].pos.z))
				if c.x > -300 and c.x < WINDOW_W + 200 and c.y > -300 and c.y < WINDOW_H + 300 then
					local quality =  2 * pi / 36
					local points = {}
					for theta = 0, 2 * pi + quality, quality do
						local c = WorldToScreen(D3DXVECTOR3(self.Turrets[i].pos.x + 850 * cos(theta), self.Turrets[i].pos.y, self.Turrets[i].pos.z - 850 * sin(theta)))
						points[#points + 1] = D3DXVECTOR2(c.x, c.y)
					end
					DrawLines2(points, 2, ARGB(255,255,0,0))
				end			
			else
				table.remove(self.Turrets, i)
			end
		end
	end
	if self.oM.path then
		for i=1, #self.enemies do
			local e = self.enemies[i]
			if e and not e.dead and e.visible and e.pathCount > 1 then
				local points = {}
				local eC = WorldToScreen(D3DXVECTOR3(e.pos.x, e.pos.y, e.pos.z))
				points[1] = D3DXVECTOR2(eC.x, eC.y)
				local pathLength = 0
				for j=e.pathIndex, e.pathCount do
					local p1 = e:GetPath(j)
					local p2 = e:GetPath(j-1)
					local c = WorldToScreen(D3DXVECTOR3(p1.x, p1.y, p1.z))
					points[#points + 1] = D3DXVECTOR2(c.x, c.y)
					if p1 and p2 then
						if (j==e.pathIndex) then
							pathLength = pathLength + GetDistanceSqr(Vector(p1.x, p1.y, p1.z), Vector(e.x, e.y, e.z))
						else
							pathLength = pathLength + GetDistanceSqr(Vector(p1.x, p1.y, p1.z), Vector(p2.x, p2.y, p2.z))
						end
					end
				end			
				if self.oM.type == 1 then
					local draw = false
					for j=1, #points do
						if points[j].x > 0 and points[j].x < WINDOW_W and points[j].y > 0 and points[j].y < WINDOW_H then
							draw = true
							break
						end
					end
					if draw then
						DrawLines2(points, 2, ARGB(255,255,0,0))
						DrawText3D(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, ARGB(255,255,255,255))
					end
				else
					if points[#points].x > 0 and points[#points].x < WINDOW_W and points[#points].y > 0 and points[#points].y < WINDOW_H then
						DrawText3D(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, ARGB(255,255,255,255)) --ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4])			
					end
				end
			end
		end
	end
end

class 'TRINKET'

function TRINKET:__init()
	self.trinketID = { 
		['TrinketTotemLvl2'] = 3350,
		['TrinketTotemLvl1'] = 3340,
		['TrinketSweeperLvl1'] = 3341,
		['TrinketOrbLvl1'] = 3342,
		['TrinketTotemLvl3'] = 3361,
		['TrinketTotemLvl4'] = 3362,
		['TrinketOrbLvl3'] = 3363,
		['TrinketSweeperLvl3'] = 3364,
	}
	self.trM = self:Menu()
	if self.trM.ward and GetGame().map.shortName == 'summonerRift' and clock()/60 < 1.1 then 
		DelayAction(
		function() 
			if not myHero:getItem(ITEM_7) then
				self:BuyItem(3339+self.trM.type) 
			end
		end, 5)
	end
	AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
	loadMsg = loadMsg..'TrinketHelper, '
end

function TRINKET:Menu()
	MainMenu:addSubMenu('Trinket Helper', 'Trinket')
	local trM = MainMenu.Trinket
	trM:addParam('ward', 'Buy Trinket on Game Start', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('type', 'Trinket on Game Start', SCRIPT_PARAM_LIST, 1, { 'Ward Totem', 'Sweeper', 'ScryingOrb' })
	trM:addParam('sweeper', 'Enable Sweeper Purchase', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('timer', 'Buy Sweeper after x Minutes', SCRIPT_PARAM_SLICE, 10, 1, 60)
	trM:addParam('scryorb', 'Enable ScryingOrb Purchase', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('timer2', 'Buy ScryingOrb after x Minutes', SCRIPT_PARAM_SLICE, 40, 10, 60)
	trM:addParam('sightstone', 'Buy Sweeper on Sightstone', SCRIPT_PARAM_ONOFF, true)
	return trM
end

function TRINKET:BuyItem(id)
	local rB = {}
	for i=0, 255 do rB[IDBytes[i]] = i end
	local p = CLoLPacket(0x00AD)
	p.vTable = 0xDC9DD8
	p:EncodeF(myHero.networkID)
	local b1 = lshift(band(rB[band(rshift(band(id,0xFFFF),24),0xFF)],0xFF),24)
	local b2 = lshift(band(rB[band(rshift(band(id,0xFFFFFF),16),0xFF)],0xFF),16)
	local b3 = lshift(band(rB[band(rshift(band(id,0xFFFFFFFF),8),0xFF)],0xFF),8)
	local b4 = band(rB[band(id ,0xFF)],0xFF)
	p:Encode4(bxor(b1,b2,b3,b4))
	p:Encode4(0xE1240DFD) --hash?
	SendPacket(p)
end

function TRINKET:RecvPacket(p)
	if p.header == 0x0055 then
		p.pos=2
		if p:DecodeF() == myHero.networkID then
			p.pos=11
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[p:Decode1()]
			end
			local itemID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
			local currentTrinket = myHero:getItem(ITEM_7)
			if not currentTrinket then return end
			local gameTime = clock()/60
			if self.trM and self.trinketID[currentTrinket.name] == 3340 and gameTime >= self.trM.timer then
				self:BuyItem(3341)
				return
			end
			if (self.trinketID[currentTrinket.name] == 3340 or self.trinketID[currentTrinket.name] == 3341) and self.trM.scryorb and gameTime >= self.trM.timer2 then
				self:BuyItem(3342)
				return
			end
			if self.trM.sweeper and self.trM.sightstone and self.trinketID[currentTrinket.name] == 3340 and itemID == 2049 then
				self:BuyItem(3341)
				return
			end
		end
	end
end
