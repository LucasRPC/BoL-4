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
		
		***** Update 2
		
		--Fixed all packets
		--Removed Trinket Helper for this version as Buy/SellItem are nonfunctional
		--Added side HUD for ally ult/summoner cooldowns.
--]]

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
			if (ward.pos.x == o.x and ward.pos.z == o.z)then
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
	self.recallLongs = {
		[530554793] = 1,
		[530554794] = 2,
		[530554792] = 3,
		[530554787] = 4,
		[530554785] = 5,
		[530554786] = 6,
		[530554784] = 7,
		[530554767] = 8,
		[530554765] = 9,
		[530554766] = 10,
	}
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
	if p.header == 0x8B then --losevision
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
	if p.header == 0xBD then --gainvision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.type == myHero.type and o.team ~= myHero.team then
			self.missing[o.networkID] = nil
			return
		end
	end
	if p.header == 0x22 then --recall
		p.pos = 60
		local str = ''
		for i=1, p.size do
			local char = p:Decode1()
			if char == 0 then break end
			str=str..string.char(char)
		end
		p.pos = 55
		local id = p:Decode4()
		p.pos = 76
		if self.recallLongs[id] then
			if p:Decode1() ~= 0 then
				local o = heroManager:getHero(self.recallLongs[id])
				if o == nil or o.team == myHero.team or o.type ~= myHero.type then return end
				self.activeRecalls[o.networkID] = {
					name = o.charName,
					startT = os.clock(),
					endT = self.recallTimes[str:lower()] and os.clock()+self.recallTimes[str:lower()] or os.clock()+7.9,
				}
				return
			else
				local o = heroManager:getHero(self.recallLongs[id])
				if o == nil or o.team == myHero.team or o.type ~= myHero.type then return end
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

class 'TIMERS'

function TIMERS:__init()
	self.map = GetGame().map.shortName
	if self.map == 'summonerRift' then
		self.pos = {
			[233] = Vector(3850, 60, 7880),		--bottom blue
			[7]   = Vector(3800, 60, 6500), 	--bottom wolves
			[208] = Vector(7000, 60, 5400),		--bottom raptors
			[152] = Vector(7800, 60, 4000), 	--bottom red
			[110] = Vector(8400, 60, 2700), 	--bottom krugs
			[102] = Vector(9866, 60, 4414),		--dragon
			[174] = Vector(10950, 60, 7030),	--top blue
			[93]  = Vector(11000, 60, 8400),	--top wolves
			[192] = Vector(7850, 60, 9500),		--top raptors
			[136] = Vector(7100, 60, 10900),	--top red
			[84]  = Vector(6400, 60, 12250),	--top krugs
			[194] = Vector(4950, 60, 10400),	--baron
			[82]  = Vector(2200, 60, 8500),		--bottom frog
			[79]  = Vector(12600, 60, 6400),	--top frog
			[190] = Vector(10500, 60, 5170),	--bottom crab
			[38]  = Vector(4400, 60, 9600),		--top crab
		}
		self.times = {
			[233] = 300,
			[7]   = 100,
			[208] = 100,
			[152] = 300,
			[110] = 100,
			[102] = 360,
			[174] = 300,
			[93]  = 100,
			[192] = 100,
			[136] = 300,
			[84]  = 100,
			[194] = 420,
			[82]  = 100,
			[79]  = 100,
			[190] = 180,
			[38]  = 180
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
			[233] = Vector(4414, 60, 5774), 
			[7]   = Vector(5088, 60, 8065), 
			[208] = Vector(6148, 60, 5993), 
			[152] = Vector(11008, 60, 5775),
			[110] = Vector(10341, 60, 8084), 
			[102] = Vector(9239, 60, 6022), 
			[174] = Vector(7711, 60, 6722), 
			[93]  = Vector(7711, 60, 10080),
		}	
		self.times = {
			[233] = 75,
			[7]   = 75,
			[208] = 75,
			[152] = 75,
			[110] = 75,
			[102] = 75,
			[174] = 90,
			[93]  = 300,
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
	elseif self.map == 'howlingAbyss' then
		self.pos = {
			[233] = Vector(7582, -100, 6785), 
			[7]   = Vector(5929, -100, 5190), 
			[208] = Vector(8893, -100, 7889), 
			[152] = Vector(4790, -100, 3934),
		}
		self.times = {
			[233] = 40,
			[7]   = 40,
			[208] = 40,
			[152] = 40,
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
	elseif self.map == 'crystalScar' then
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
			 [122] = 30, 
			 [70]  = 30, 
			 [203] = 30,
			 [81]  = 30, 
			 [160] = 30, 
			 [96]  = 30, 
			 [202] = 30, 
			 [145] = 30, 
			 [197] = 30, 
			 [244] = 30,
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
	if p.header == 0xAB then
		p.pos = 10
		local hasVision = p:Decode4()
		p.pos = 19
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
	if p.header == 0xC6 then
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

