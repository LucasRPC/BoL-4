--[[
		***** If you want to completely disable one of the features, comment it out in OnLoad(), for ex:
		*****
		*****	WARD()
		*****	--MISS()
		*****	--SKILLS()
		*****	TIMERS()
		*****
		***** Will disable the enemy missing timers and skill cooldowns while ward tracking and object timers will remain functional.
		***** I suggest doing this over disabling via the Menus if you don't think you'll ever use a certain feature.
		
		Ward Tracker:
				--Tracks enemy wards, Mushrooms, Caitlyn/Nidalee Traps, Shaco's Boxes, Maokai's Saplings
		Missing Tracker:
				--Tracks missing enemies and draws timers on minimap indicating the length they have been missing,
				  hover over the timer to show which character, or use Minimap Hack when working(suggested)^^
		Cooldown Tracker:
				--Very simple HUD to track Cooldowns with minimal FPS cost, skills and summoners.
		Object Timers:
				Summoners Rift:
						--Tracks Inhibitor respawn.
						--Tracks any jungle camp you have vision of clearing.
						--If Dragon or Baron are cleared without your team having vision, will grab respawn timer from the buff.
				Twisted Treeline: 
						--Tracks Inhibitor respawn.
						--Tracks any jungle camp you have vision of clearing.
						--Tracks center health relic.
				Howling Abyss:
						--Tracks Inhibitor respawn.
						--Tracks health relics.
				Crystal Scar:
						--Tracks health relics.
		
		***** Update 1
		
		-Added Inhibitor timers
		-Added option to display ward timers on minimap instead of marker
		-Added trinket buy/sell utility
		-Fixed bug not displaying dragon timer from FoW if it was the 5th dragon buff
--]]

--[[
unit.visible always returns true

--]]

local IDBytes = {
	[0x00] = 0x7A, [0x01] = 0x5C, [0x02] = 0x90, [0x03] = 0x2A, [0x04] = 0xB0, [0x05] = 0x17, [0x06] = 0x00, [0x07] = 0xE6, [0x08] = 0x65, [0x09] = 0x87, [0x0A] = 0xA6, [0x0B] = 0xAD, [0x0C] = 0xED, 
	[0x0D] = 0x32, [0x0E] = 0x92, [0x0F] = 0x0D, [0x10] = 0xF8, [0x11] = 0x72, [0x12] = 0xDE, [0x13] = 0xAC, [0x14] = 0xA7, [0x15] = 0x78, [0x16] = 0x0E, [0x17] = 0x59, [0x18] = 0x0F, [0x19] = 0xBE, 
	[0x1A] = 0x3D, [0x1B] = 0x45, [0x1C] = 0xFC, [0x1D] = 0xBF, [0x1E] = 0xB7, [0x1F] = 0xCD, [0x20] = 0xDC, [0x21] = 0x52, [0x22] = 0xC3, [0x23] = 0xE3, [0x24] = 0x26, [0x25] = 0xE2, [0x26] = 0x3C,
	[0x27] = 0x3E, [0x28] = 0xAA, [0x29] = 0x6D, [0x2A] = 0x2F, [0x2B] = 0xAE, [0x2C] = 0x46, [0x2D] = 0x0C, [0x2E] = 0x5F, [0x2F] = 0xD1, [0x30] = 0x7F, [0x31] = 0x08, [0x32] = 0xD7, [0x33] = 0x4A,
	[0x34] = 0x50, [0x35] = 0x1C, [0x36] = 0xD3, [0x37] = 0x14, [0x38] = 0x05, [0x39] = 0xF6, [0x3A] = 0x0A, [0x3B] = 0x9E, [0x3C] = 0x8B, [0x3D] = 0xB5, [0x3E] = 0x07, [0x3F] = 0x6C, [0x40] = 0xD8, 
	[0x41] = 0x2B, [0x42] = 0xE4, [0x43] = 0x21, [0x44] = 0xBB, [0x45] = 0x5E, [0x46] = 0xB6, [0x47] = 0xEE, [0x48] = 0x23, [0x49] = 0xF9, [0x4A] = 0x9F, [0x4B] = 0xCB, [0x4C] = 0x22, [0x4D] = 0x8C, 
	[0x4E] = 0x70, [0x4F] = 0xEF, [0x50] = 0x1E, [0x51] = 0x84, [0x52] = 0x30, [0x53] = 0xC0, [0x54] = 0x33, [0x55] = 0xF4, [0x56] = 0x63, [0x57] = 0xDA, [0x58] = 0xDF, [0x59] = 0xD4, [0x5A] = 0xB4, 
	[0x5B] = 0x28, [0x5C] = 0x96, [0x5D] = 0x67, [0x5E] = 0x11, [0x5F] = 0x41, [0x60] = 0x12, [0x61] = 0x85, [0x62] = 0x51, [0x63] = 0x69, [0x64] = 0x1D, [0x65] = 0xDB, [0x66] = 0xE8, [0x67] = 0x74, 
	[0x68] = 0x94, [0x69] = 0x98, [0x6A] = 0x1B, [0x6B] = 0xA9, [0x6C] = 0xF3, [0x6D] = 0x79, [0x6E] = 0x77, [0x6F] = 0xC2, [0x70] = 0x03, [0x71] = 0x13, [0x72] = 0xA4, [0x73] = 0x75, [0x74] = 0x88, 
	[0x75] = 0x2D, [0x76] = 0x7B, [0x77] = 0x62, [0x78] = 0x53, [0x79] = 0x1A, [0x7A] = 0x6F, [0x7B] = 0x4B, [0x7C] = 0xA0, [0x7D] = 0xD6, [0x7E] = 0x02, [0x7F] = 0x24, [0x80] = 0xFB, [0x81] = 0x10, 
	[0x82] = 0xD2, [0x83] = 0x9D, [0x84] = 0xFD, [0x85] = 0x7C, [0x86] = 0xDD, [0x87] = 0x3F, [0x88] = 0xB3, [0x89] = 0xE1, [0x8A] = 0xBC, [0x8B] = 0x49, [0x8C] = 0xEC, [0x8D] = 0x86, [0x8E] = 0x06, 
	[0x8F] = 0xC1, [0x90] = 0x5B, [0x91] = 0x4D, [0x92] = 0x55, [0x93] = 0x81, [0x94] = 0x60, [0x95] = 0xAB, [0x96] = 0x71, [0x97] = 0x44, [0x98] = 0x8D, [0x99] = 0xA5, [0x9A] = 0x40, [0x9B] = 0xC7, 
	[0x9C] = 0x93, [0x9D] = 0x61, [0x9E] = 0xFA, [0x9F] = 0xC9, [0xA0] = 0x54, [0xA1] = 0x31, [0xA2] = 0x15, [0xA3] = 0x66, [0xA4] = 0xA3, [0xA5] = 0x18, [0xA6] = 0xF2, [0xA7] = 0x37, [0xA8] = 0x7E, 
	[0xA9] = 0x64, [0xAA] = 0x2C, [0xAB] = 0xD9, [0xAC] = 0x04, [0xAD] = 0xE5, [0xAE] = 0xA1, [0xAF] = 0x8F, [0xB0] = 0x57, [0xB1] = 0xF0, [0xB2] = 0x5D, [0xB3] = 0x3A, [0xB4] = 0x8E, [0xB5] = 0x6E, 
	[0xB6] = 0xB2, [0xB7] = 0x9B, [0xB8] = 0x4E, [0xB9] = 0x6A, [0xBA] = 0xA8, [0xBB] = 0xC8, [0xBC] = 0xCF, [0xBD] = 0x97, [0xBE] = 0xFF, [0xBF] = 0x73, [0xC0] = 0x19, [0xC1] = 0x3B, [0xC2] = 0x89, 
	[0xC3] = 0xEB, [0xC4] = 0x91, [0xC5] = 0xC4, [0xC6] = 0x4F, [0xC7] = 0xA2, [0xC8] = 0x38, [0xC9] = 0x34, [0xCA] = 0x25, [0xCB] = 0x43, [0xCC] = 0x2E, [0xCD] = 0x1F, [0xCE] = 0x4C, [0xCF] = 0x42, 
	[0xD0] = 0xB9, [0xD1] = 0xC6, [0xD2] = 0xE9, [0xD3] = 0x27, [0xD4] = 0x76, [0xD5] = 0x29, [0xD6] = 0xE7, [0xD7] = 0xAF, [0xD8] = 0x0B, [0xD9] = 0x56, [0xDA] = 0x09, [0xDB] = 0x99, [0xDC] = 0xD0, 
	[0xDD] = 0xF1, [0xDE] = 0xEA, [0xDF] = 0x6B, [0xE0] = 0x47, [0xE1] = 0x48, [0xE2] = 0x01, [0xE3] = 0x95, [0xE4] = 0x68, [0xE5] = 0xFE, [0xE6] = 0x80, [0xE7] = 0x58, [0xE8] = 0xB8, [0xE9] = 0xCC,
	[0xEA] = 0x39, [0xEB] = 0xB1, [0xEC] = 0x35, [0xED] = 0x16, [0xEE] = 0xF7, [0xEF] = 0xE0, [0xF0] = 0xD5, [0xF1] = 0x83, [0xF2] = 0x9A, [0xF3] = 0xBA, [0xF4] = 0xC5, [0xF5] = 0xBD, [0xF6] = 0xCA, 
	[0xF7] = 0x8A, [0xF8] = 0x20, [0xF9] = 0x7D, [0xFA] = 0x82, [0xFB] = 0x9C, [0xFC] = 0xF5, [0xFD] = 0x5A, [0xFE] = 0x36, [0xFF] = 0xCE,
}

local loadMsg, MainMenu = '', nil
function OnLoad()
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	
	WARD()
	MISS()
	SKILLS()
	TIMERS()
	print('<font color=\'#0099FF\'>[Loaded]</font> <font color=\'#FF6600\'>'..loadMsg:sub(1,#loadMsg-2)..'.</font>')
end

class 'WARD'

function WARD:__init()
	self.types = {
		['YellowTrinket'] 		 = { color = ARGB(255, 255, 255, 50), 	duration = 60, 		  },
		['YellowTrinketUpgrade'] = { color = ARGB(255, 255, 255, 50),	duration = 120, 	  },
		['SightWard'] 			 = { color = ARGB(255, 0, 255, 0),		duration = 180, 	  },
		['VisionWard']  		 = { color = ARGB(255, 255, 50, 255), 	duration = math.huge, },
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
	--AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
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
	if o.team ~= myHero.team and self.types[o.charName] then
		local timeReduction = 0
		local charName
		for id, ward in pairs(self.known) do
			if ward and ward.pos.x == o.x and ward.pos.z == o.z then
				timeReduction = (ward and self.types[o.charName]) and self.types[o.charName].duration - (ward.endTime-os.clock()) or 0
				charName = ward.charName
				self.known[id] = nil
			end
		end
		self.known[o.networkID] = {
			pos 		= Vector(o.x, o.y, o.z),
			minimap   	= GetMinimap(Vector(o.x, o.y, o.z)), 
			color 		= self.types[o.charName].color, 
			endTime 	= (self.types[o.charName].duration ~= math.huge) and os.clock()+self.types[o.charName].duration-timeReduction or os.clock()+self.types[o.charName].duration,
			charName 	= charName or 'Unkown', 
		}	
	end
end

function WARD:DeleteObj(o)
	if self.known[o.networkID] then
		self.known[o.networkID] = nil
	end
end

function WARD:RecvPacket(p) --4.21
		if p.header == 0x58 then
		local o = {}
		p.pos=2
		o.networkID = p:DecodeF()
		o.x 		= p:DecodeF()
		o.y			= p:DecodeF()
		o.z			= p:DecodeF()
		p.pos=26
		o.name		= ''
		for i=1, p.size do
			local b = p:Decode1()
			if b == 0 then break end
			o.name = o.name..string.char(b)
		end
		p.pos=51
		o.source 	= objManager:GetObjectByNetworkId(p:DecodeF())
		p.pos=63
		o.team		= p:Decode1()
		if o.team == myHero.team then return end
		p.pos=65
		o.charName	= ''
		for i=1, p.size do
			local b = p:Decode1()
			if b == 0 then break end
			o.charName = o.charName..string.char(b)
		end
		local timeReduction = 0
		for id, ward in pairs(self.known) do
			if (ward.pos.x == o.x and ward.pos.z == o.z) or id == ward.networkID then
				timeReduction = (ward and self.types[o.name]) and self.types[o.name].duration - (ward.endTime-os.clock()) or 0
				self.known[id] = nil
			end
		end		
		if self.types[o.name] then
			self.known[o.networkID] = {
				pos 		= Vector(o.x, o.y, o.z),
				minimap   	= GetMinimap(Vector(o.x, o.y, o.z)), 
				color 		= self.types[o.name].color, 
				endTime 	= (self.types[o.name].duration ~= math.huge) and os.clock()+self.types[o.name].duration-timeReduction or os.clock()+self.types[o.name].duration,
				charName 	= o.source.charName, 
			}
		elseif self.types[o.charName] then
			self.known[o.networkID] = {
				pos 		= Vector(o.x, o.y, o.z),
				minimap 	= GetMinimap(Vector(o.x, o.y, o.z)),
				color 		= self.types[o.charName].color,
				endTime 	= (self.types[o.charName].duration ~= math.huge) and os.clock()+self.types[o.charName].duration-timeReduction or os.clock()+self.types[o.charName].duration,
				charName 	= o.source.charName,
			}
		end
		return
	end
	if p.header == 0x8D then
		p.pos = 2
		local id = p:DecodeF()
		if self.known[id] then
			self.known[id] = nil
		end
		return
	end
end

function WARD:Draw()
	if not self.wM.draw then return end
	for i, o in pairs(self.known) do
		local timer = math.ceil(o.endTime-os.clock())
		local minutes = tostring(math.floor(timer/60))
		local sInit = tostring(math.ceil((((timer/60)-math.floor(timer/60))*60)))
		local seconds = (#sInit == 2) and sInit or '0'..sInit
		local tText = (self.wM.type == 1) and tostring(math.ceil(timer)) or minutes..':'..seconds
		local text = (o.endTime ~= math.huge and o.charName) and tText..'\n'..o.charName or o.charName
		DrawText3D(text, o.pos.x, o.pos.y, o.pos.z+10, self.wM.size, o.color, true)
		DrawText((self.wM.mapTpe == 1 or o.endTime == math.huge) and 'o' or tText, self.wM.mapsize, o.minimap.x-(self.wM.mapsize/6), o.minimap.y-(self.wM.mapsize/6), o.color)
		self:DrawHex(o.pos.x, o.pos.y, o.pos.z, o.color)
		if o.endTime < os.clock() then
			self.known[i] = nil
		end
	end
end

function WARD:ProcessSpell(u, s)
	if u and u.team ~= myHero.team and self.onSpell[s.name:lower()] then
		self.known[#self.known+1] = {
			pos 		= Vector(s.endPos.x, s.endPos.y, s.endPos.z),
			minimap   	= GetMinimap(Vector(s.endPos.x, s.endPos.y, s.endPos.z)),
			color 		= self.onSpell[s.name:lower()].color,
			endTime 	= os.clock()+self.onSpell[s.name:lower()].duration,
			charName 	= u.charName,
		}
	end
end

function WARD:DrawHex(x, y, z, c)
    local pi2 = 2*math.pi
    local hex = {}
    for theta = 0, (pi2+(pi2/6)), (pi2/6) do
        local tS = WorldToScreen(D3DXVECTOR3(x+(75*math.cos(theta)), y, z-(75*math.sin(theta))))
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
		if o and o.name:find('__Spawn_T') and o.team ~= myHero.team then
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
	for i=1, heroManager.iCount do ---??
		if heroManager:getHero(i).team ~= myHero.team then
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
	mM:addParam('RGB', 'Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})	
	mM:addParam('recall', 'Display Recall Status', SCRIPT_PARAM_ONOFF, true)
	return mM	
end

function MISS:RecvPacket(p)
	if p.header == 0x104 then --losevision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.type == myHero.type and o.team ~= myHero.team then
			if o.dead then
				self.missing[o.networkID] = {
					pos = self.recallEndPos,
					name = o.charName, 
					mTime = os.clock(),
				}				
			else
				self.missing[o.networkID] = {
					pos = GetMinimap(Vector(o.pos)),
					name = o.charName, 
					mTime = os.clock(),
				}
				return
			end
		end	
	end
	if p.header == 0xCE then --gainvision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.type == myHero.type and o.team ~= myHero.team then
			self.missing[o.networkID] = nil
			return
		end
	end
	if p.header == 0x117 then --recall
		p.pos = 54
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = IDBytes[p:Decode1()]
		end
		local b1 = bit32.lshift(bit32.band(bytes[1],0xFF),24)
		local b2 = bit32.lshift(bit32.band(bytes[2],0xFF),16)
		local b3 = bit32.lshift(bit32.band(bytes[3],0xFF),8)
		local b4 = bit32.band(bytes[4],0xFF)
		local netID = bit32.bxor(b1,b2,b3,b4)
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if o and o.type == myHero.type and o.team ~= myHero.team then
			p.pos = 60
			local str = ''
			for i=1, p.size do
				local char = p:Decode1()
				if char == 0 then break end
				str=str..string.char(char)
			end
			p.pos = 76
			if p:Decode1() ~= 0 then
				self.activeRecalls[o.networkID] = {
					name = o.charName,
					startT = os.clock(),
					endT = self.recallTimes[str:lower()] and os.clock()+self.recallTimes[str:lower()] or os.clock()+7.9,
				}
				return
			else
				if self.activeRecalls[o.networkID] and self.activeRecalls[o.networkID].endT > os.clock() then
					self.activeRecalls[o.networkID] = nil
					return
				else
					self.missing[o.networkID] = {pos = self.recallEndPos, name = o.charName, mTime = os.clock(),}
					self.activeRecalls[o.networkID] = nil
					return
				end
			end
		end
	end
end

function MISS:Draw()
	if not self.mM.draw then return end
	for _, info in pairs(self.missing) do
		if info then
			local cP = GetCursorPos()
			if math.abs(cP.x-info.pos.x) < 10 and math.abs(cP.y-info.pos.y) < 10 then
				local text = info.name..'\n'
				for i=1, #text/2 do text=text..' ' end
				text = text..tostring(math.ceil(os.clock()-info.mTime))
				DrawText(text, self.mM.size, info.pos.x-30-(self.mM.size/6), info.pos.y-20-(self.mM.size/6), ARGB(self.mM.RGB[1], self.mM.RGB[2], self.mM.RGB[3], self.mM.RGB[4]))
			else
				local text = tostring(math.ceil(os.clock()-info.mTime))
				DrawText(text, self.mM.size, info.pos.x-5-(self.mM.size/6), info.pos.y-5-(self.mM.size/6), ARGB(self.mM.RGB[1], self.mM.RGB[2], self.mM.RGB[3], self.mM.RGB[4]))
			end
		end
	end
	if self.mM.recall then
		local minimap = GetMinimap(0, 18000)
		local count = 0
		for _, info in pairs(self.activeRecalls) do
			local yOffset = count*-30
			local recallTime = info.endT-info.startT
			local currentTime = info.endT-os.clock()
			local percent = currentTime/recallTime
			local x2 = minimap.x+((WINDOW_W-10-minimap.x)*percent)
			if x2 > minimap.x then
				DrawLine(minimap.x, minimap.y+yOffset, x2, minimap.y+yOffset, 16, ARGB(255,255*percent,255-(255*percent),0))
				local Lines = {
					D3DXVECTOR2(minimap.x-2, minimap.y-8+yOffset), 
					D3DXVECTOR2(WINDOW_W-10, minimap.y-8+yOffset), 
					D3DXVECTOR2(WINDOW_W-10, minimap.y+8+yOffset), 
					D3DXVECTOR2(minimap.x-2, minimap.y+8+yOffset),
					D3DXVECTOR2(minimap.x-2, minimap.y-8+yOffset), 
				}
				DrawLines2(Lines, 2, ARGB(255,255,255,255))
				DrawText(info.name..' '..tostring(math.ceil(percent*100))..'%', 12, (minimap.x+WINDOW_W-60)/2, minimap.y-6+yOffset, ARGB(255,255,255,255))
			end
			count = count + 1
		end
	end
end

class 'SKILLS'		--done

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
		if h.team ~= myHero.team then
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
		['xLeft']   	= math.floor((29  * (WINDOW_H / 1080))  * self.HudScale),
		['xRight']  	= math.floor((49  * (WINDOW_H / 1080))  * self.HudScale),
		['yUp']     	= math.floor((102 * (WINDOW_H / 1080)) * self.HudScale),
		['size']    	= math.floor((42  * (WINDOW_H / 1080))  * self.HudScale),
		['skill']   	= math.floor((13  * (WINDOW_H / 1080))  * self.HudScale),
		['lineOffset'] 	= math.floor(((8  * (WINDOW_H / 1080))  * self.HudScale) / 2),
		['lineWidth']   = math.floor(7.5 * self.HudScale),
	}
	self.HeroOffsets = {
		['alistar']  = -4,  	['annie']       = -4,  	['blitzcrank'] = -4,
		['brand']    = -3,   	['cassiopeia']  = -2, 	['darius']     = -2,
		['drmundo']  =  1,  	['galio']       =  1,  	['garen']      =  1,
		['jarvaniv'] =  2,  	['jax']         = -4,   ['lux']        = -4, --  TO CHECK
		['lucian']   = -4,  	['kayle']       = -5,  	['tristana']   = -3, --aatrox, ahri, akali, anivia, diana, draven, elise, evelyn, fiora, fizz, gangplank, 
		['malzahar'] = -2,  	['missfortune'] = -4,   ['morgana']    = -2, --gnar, gragas, hecarim, heimerdinger, janna, jayce, jinx, kalista, karma, kassadin, katarina, kennen
		['nunu']     = -2,      ['renekton']    = -2,	['soraka']     = -5, --khazix, leblanc, leesin, lissandra, lulu, maokai, mordekaiser, nami, nautilus, nocturne, olaf, orianna,
		['ryze']     = -3,      ['shen']		= -4,	['shyvana']    = -1, --pantheon, poppy, quinn, rammus, reksai, rengar, riven, rumble, sejuani, shaco, singed, sion, skarner, sona
		['swain']    = -3,		['trundle']     =  4,   ['xinzhao']    =  7, --syndra, talon, teemo, thresh, tryndamere, twistedfate, twitch, urgot, varus, vayne, velkoz, vi, 
		['ziggs']    = -3,		['zilean']      = -2,	['braum']      = -3, --volibear, xerath, yasuo, yorick, zac, zed
		['corki']    = -4,		['viktor']      = -3,	['azir']       = -2,
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
	for _, info in ipairs(self.enemies) do
		local enemy = info.hero
		if enemy.visible and not enemy.dead then
			local barData = self:BarData(enemy)
			if OnScreen(barData.x, barData.y) then
				for i=_Q, SUMMONER_2 do
					local data = enemy:GetSpellData(i)
					local color = (data.level>0 and data.currentCd == 0) and ARGB(255,0,255,0) or ARGB(255,255,0,0)
					local text,x,y,Lines
					if i<=_R then
						text = self.toText[i+1]
						x = barData.x-22+(i*27)
						local offset = self.HeroOffsets[enemy.charName:lower()] or 0
						y = barData.y+6+offset
						Lines = {D3DXVECTOR2(x-4, y+12), D3DXVECTOR2(x-4, y), D3DXVECTOR2(x+20, y), D3DXVECTOR2(x+20, y+12)}
						text = data.currentCd == 0 and text or tostring(math.ceil(data.cd-(data.cd-data.currentCd)))
						text = #text>1 and text or ' '..text
						DrawText(text, 12, x, y, color)
						DrawLines2(Lines, 2, color)					
					else
						text = info['sum'..tostring(i-3)]
						x = barData.x-76+((i-2)*27)
						local offset = self.HeroOffsets[enemy.charName:lower()] or 0
						y = barData.y+38+offset
						if data.currentCd == 0 then
							Lines = {D3DXVECTOR2(x-4, y), D3DXVECTOR2(x-4, y+13), D3DXVECTOR2(x+20, y+13), D3DXVECTOR2(x+20, y)}
							DrawLines2(Lines, 2, color)
						else
							Lines = {}
							local cd = math.ceil(data.currentCd*100/data.cd/2)
							for j=1, 13 do Lines[#Lines+1] = D3DXVECTOR2(x-4, y+j) end
							for j=1, 24 do Lines[#Lines+1] = D3DXVECTOR2(x-4+j, y+13) end
							for j=1, 13 do Lines[#Lines+1] = D3DXVECTOR2(x+20, y+13-j) end
							local LinesRed, LinesYellow = {}, {}
							for j=1, cd do LinesRed[#LinesRed+1] = Lines[j] end
							for j=cd, #Lines do LinesYellow[#LinesYellow+1] = Lines[j] end
							DrawLines2(LinesYellow, 2, ARGB(255,255,255,0))
							DrawLines2(LinesRed, 2, ARGB(255,255,0,0))
						end
						DrawText(text, 12, x-2, y, color)
					end
				end
			end
		end
	end
	for i, info in ipairs(self.allies) do
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
			local offset = math.floor(self.HudScale*0.75)
			DrawLines2(Lines, 1+offset, ARGB(150,255,255,255))
			if data.currentCd == 0 then
				DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xRight, y, self.AllyHud.lineWidth, ARGB(150,0,255,0))
			else
				local cd = data.currentCd/data.cd
				DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, self.AllyHud.lineWidth, ARGB(150,255,0,0))
				DrawLine(self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, self.AllyHud.xRight, y, self.AllyHud.lineWidth, ARGB(150,255,255,0))				
			end
			if j ~= _R then
				text = info['sum'..tostring(j-3)]
				DrawText(text, math.floor(8 * self.HudScale), self.AllyHud.xLeft + self.AllyHud.lineOffset, y - self.AllyHud.lineOffset, ARGB(255,255,255,255))
			end
		end
	end
end

function SKILLS:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	return {['x'] = math.floor(barPos.x+(barPosOffset.x-0.55)*70), ['y'] = math.floor(barPos.y+(barPosOffset.y-0.5)*45),}
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

class 'TIMERS'		--done

function TIMERS:__init()
	self.map = GetGame().map.shortName
	if self.map == 'summonerRift' then		--Done
		self.pos = {
			[0x19] = Vector(3850, 60, 7880),	--bottom blue
			[0x27] = Vector(3800, 60, 6500), 	--bottom wolves
			[0x02] = Vector(7000, 60, 5400),	--bottom raptors
			[0x97] = Vector(7800, 60, 4000), 	--bottom red
			[0xA0] = Vector(8400, 60, 2700), 	--bottom krugs
			[0x69] = Vector(9866, 60, 4414),	--dragon
			[0x6D] = Vector(10950, 60, 7030),	--top blue
			[0x74] = Vector(11000, 60, 8400),	--top wolves
			[0xA6] = Vector(7850, 60, 9500),	--top raptors
			[0x14] = Vector(7100, 60, 10900),	--top red
			[0xCB] = Vector(6400, 60, 12250),	--top krugs
			[0x0A] = Vector(4950, 60, 10400),	--baron
			[0xEA] = Vector(2200, 60, 8500),	--bottom frog
			[0xA9] = Vector(12600, 60, 6400),	--top frog
			[0x94] = Vector(10500, 60, 5170),	--bottom crab
			[0x70] = Vector(4400, 60, 9600),		--top crab
		}
		self.times = {
			[0x19] = 300,
			[0x27] = 100,
			[0x02] = 100,
			[0x97] = 300,
			[0xA0] = 100,
			[0x69] = 360,
			[0x6D] = 300,
			[0x74] = 100,
			[0xA6] = 100,
			[0x14] = 300,
			[0xCB] = 100,
			[0x0A] = 420,
			[0xEA] = 100,
			[0xA9] = 100,
			[0x94] = 180,
			[0x70] = 180
		}
		self.inhibs = {
			[4291968000] = 100,
			[4283048192] = 101, 
			[4287824896] = 102, 
			[4284978176] = 200,
			[4294938368] = 201, 
			[4280724480] = 202,
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
			[0x27] = Vector(5088, 60, 8065), 
			[0x02] = Vector(6148, 60, 5993), 
			[0x97] = Vector(11008, 60, 5775),
			[0xA0] = Vector(10341, 60, 8084), 
			[0x69] = Vector(9239, 60, 6022), 
			[0x6D] = Vector(7711, 60, 6722), 
			[0x74] = Vector(7711, 60, 10080),
		}	
		self.times = {
			[0x19] = 75,
			[0x27] = 75,
			[0x02] = 75,
			[0x97] = 75,
			[0xA0] = 75,
			[0x69] = 75,
			[0x6D] = 90,
			[0x74] = 300,
		}
		self.inhibs = { 
			[4287824896] = 100,
			[4291968000] = 101, 
			[4280724480] = 200, 
			[4284978176] = 201,
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
			[0x27] = Vector(5929, -100, 5190), 
			[0x02] = Vector(8893, -100, 7889), 
			[0x97] = Vector(4790, -100, 3934),
		}
		self.times = {
			[0x19] = 40,
			[0x27] = 40,
			[0x02] = 40,
			[0x97] = 40,
		}
		self.inhibs = { 
			[4283048192] = 100, 
			[4294938368] = 200, 
		}
		self.inhibPos = { 
			[100] = Vector(3110, -201, 3189), 
			[200] = Vector(9689, -190, 9524),
		}
		self.inhibTime = 300
	elseif self.map == 'crystalScar' then		--done
		self.pos = { 
			 [122] = Vector(4948, -100, 9329),  
			 [70]  = Vector(8972, -100, 9329), 
			 [203] = Vector(6949, -100, 2855), 
			 [81]  = Vector(6947, -100, 12116),
			 [160] = Vector(12881, -100, 8294), 
			 [96]  = Vector(10242, -100, 1519), 
			 [202] = Vector(3639, -100, 1490), 
			 [145] = Vector(1027, -100, 8288), 
			 [197] = Vector(4324, -100, 5500),
			 [244] = Vector(9573, -100, 5530), 
		}
		self.times = {
			 [0x9D] = 30, 
			 [0x37] = 30, 
			 [0x2C] = 30,
			 [0x9E] = 30, 
			 [0x5E] = 30, 
			 [0x95] = 30, 
			 [0x9A] = 30, 
			 [0x0F] = 30, 
			 [0xC3] = 30, 
			 [0x9C] = 30,
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
		local timer = math.ceil(info.spawnTime-os.clock())
		local minutes = timer/60
		local sInit = tostring(math.ceil(((minutes-math.floor(minutes))*60)))
		local seconds = (#sInit == 2) and sInit or '0'..sInit
		local text = (self.tM.type == 1) and tostring(math.ceil(timer)) or tostring(math.floor(minutes))..':'..seconds
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
			if h and h.team ~= myHero.team and h.visible then
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
			if b.startT+356 > os.clock() then
				self.activeTimers[6] = {spawnTime = b.startT+356, pos = self.pos[6], minimap = GetMinimap(self.pos[6]),}
				self.checkLastDragon = false
			end
		end
	end
	if self.checkLastBaron then
		for i=1, heroManager.iCount do
			local h = heroManager:getHero(i)
			if h and h.team ~= myHero.team and h.visible then
				for j=1, h.buffCount do
					local b = h:getBuff(j)
					if b and b.name and b.name:lower():find('exaltedwithbaronnashor') then
						self.activeTimers[12] = {spawnTime = b.startT+416, pos = self.pos[12], minimap = GetMinimap(self.pos[12]),}
						self.checkLastBaron = false
						return
					end
				end
			end
		end
	end
end

function TIMERS:RecvPacket(p)
	if p.header == 0x89 then
		p.pos = 14
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = IDBytes[p:Decode1()]
		end
		local b1 = bit32.lshift(bit32.band(bytes[1],0xFF),24)
		local b2 = bit32.lshift(bit32.band(bytes[2],0xFF),16)
		local b3 = bit32.lshift(bit32.band(bytes[3],0xFF),8)
		local b4 = bit32.band(bytes[4],0xFF)
		local netID = bit32.bxor(b1,b2,b3,b4)
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if not o then return end
		local camp = p:Decode1()
		if self.pos[camp] then
			if hasVision ~= 2678038528 then
				self.activeTimers[camp] = {spawnTime = os.clock()+self.times[camp], pos = self.pos[camp], minimap = GetMinimap(self.pos[camp]),}
				return
			elseif camp == 102 and self.map == 'summonerRift' then
				self.checkLastDragon = true
				return
			elseif camp == 194 and self.map == 'summonerRift' then
				self.checkLastBaron = true
				return
			end
		end
	end
	if p.header == 0xE4 then
		p.pos=2
		local inhib = p:Decode4()
		if self.inhibs[inhib] then
			self.activeTimers[self.inhibs[inhib]] = {spawnTime = os.clock()+self.inhibTime, pos = self.inhibPos[self.inhibs[inhib]], minimap = GetMinimap(self.inhibPos[self.inhibs[inhib]]),}
		end
		return
	end
end

function TIMERS:WndMsg(m,k)
	if m == 513 and k == 1 and IsKeyDown(self.tM._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for camp, pos in ipairs(self.pos) do
			local miniMap = GetMinimap(pos)
			if math.abs(cP.x-miniMap.x) < 10 and math.abs(cP.y-miniMap.y) < 10 then
				self.activeTimers[camp] = {spawnTime = os.clock()+self.times[camp], pos = pos, minimap = miniMap,}
			end
		end
	end
end





--[[
	--OTHER()	
	--TRINKET()

class 'TRINKET'

function TRINKET:__init()
	self.trinketID = { [3340] = true, [3341] = true, [3342] = true, [3361] = true, [3362] = true, [3363] = true, [3364] = true, }
	self.currentTrinket = 0
	self.trM = self:Menu()
	if self.trM.ward and GetGame().map.shortName == 'summonerRift' and os.clock()/60 < 1.1 then 
		DelayAction(function() BuyItem(3339+self.trM.type) end, 1)
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

function TRINKET:RecvPacket(p)
	if p.header == 0x129 then
		p.pos=2
		if p:DecodeF() == myHero.networkID then
			p.pos=11
			local itemID = p:Decode4()
			if self.trinketID[itemID] then
				self.currentTrinket = itemID
			end
			local gameTime = os.clock()/60
			if self.trM and self.currentTrinket == 3340 and gameTime >= self.trM.timer then
				SellItem(ITEM_7)
				DelayAction(function() BuyItem(3341) end, 0.2)
				return
			end
			if (self.currentTrinket == 3340 or self.currentTrinket == 3341) and self.trM.scryorb and gameTime >= self.trM.timer2 then
				SellItem(ITEM_7)
				DelayAction(function() BuyItem(3342) end, 0.2)
				return
			end
			if self.trM.sweeper and self.trM.sightstone and self.currentTrinket == 3340 and itemID == 2049 then
				SellItem(ITEM_7)
				DelayAction(function() BuyItem(3341) end, 0.2)
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
		if obj and obj.type == 'obj_AI_Turret' and obj.team ~= myHero.team and obj.name:find('Shrine') ==  nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	self.enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team ~= myHero.team then
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
			if self.Turrets[i] and not self.Turrets[i].dead then
				local c = WorldToScreen(D3DXVECTOR3(self.Turrets[i].pos.x, self.Turrets[i].pos.y, self.Turrets[i].pos.z))
				if c.x > -300 and c.x < WINDOW_W + 200 and c.y > -300 and c.y < WINDOW_H + 300 then
					local quality =  2 * math.pi / 36
					local points = {}
					for theta = 0, 2 * math.pi + quality, quality do
						local c = WorldToScreen(D3DXVECTOR3(self.Turrets[i].pos.x + 850 * math.cos(theta), self.Turrets[i].pos.y, self.Turrets[i].pos.z - 850 * math.sin(theta)))
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
							pathLength = pathLength + GetDistance(Vector(p1.x, p1.y, p1.z), Vector(e.x, e.y, e.z))
						else
							pathLength = pathLength + GetDistance(Vector(p1.x, p1.y, p1.z), Vector(p2.x, p2.y, p2.z))
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
						DrawText3D(tostring(math.ceil(pathLength/e.ms))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, ARGB(255,255,255,255))
					end
				else
					if points[#points].x > 0 and points[#points].x < WINDOW_W and points[#points].y > 0 and points[#points].y < WINDOW_H then
						DrawText3D(tostring(math.ceil(pathLength/(e.ms^2)))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, ARGB(255,255,255,255)) --ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4])			
					end
				end
			end
		end
	end
end
--]]



