local lshift, rshift, band, bxor = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor
local floor, ceil, huge, cos, sin, pi, pi2, abs, sqrt = math.floor, math.ceil, math.huge, math.cos, math.sin, math.pi, math.pi*2, math.abs, math.sqrt
local clock, pairs, ipairs, tostring = os.clock, pairs, ipairs, tostring
local TEAM_ENEMY, TEAM_ALLY
local COLOR_WHITE, COLOR_GREEN, COLOR_RED, COLOR_YELLOW, COLOR_TRANS_WHITE, COLOR_GREY = ARGB(0xFF,0xFF,0xFF,0xFF), ARGB(0xFF,0x00,170,0x00), ARGB(0xFF,0xFF,0x00,0x00), ARGB(0xFF,0xFF,0xFF,0x00), ARGB(0xAA,0xFF,0xFF,0xFF), ARGB(255,128,128,128) 
local COLOR_TRANS_GREEN, COLOR_TRANS_RED, COLOR_TRANS_YELLOW, COLOR_ORANGE, COLOR_BLACK = ARGB(0x96,0x00,0xFF,0x00), ARGB(0x96,0xFF,0x00,0x00), ARGB(0x96,0xFF,0xFF,0x00), ARGB(255,255,125,000), ARGB(255,0,0,000)
local loadMsg, MainMenu, IDBytes = '', nil, nil
local GlobalScale

AddLoadCallback(function()
	HookPackets()
	TEAM_ALLY, TEAM_ENEMY = myHero.team, myHero.team == 100 and 200 or 100
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	MainMenu:addParam('update', 'Enable AutoUpdate', SCRIPT_PARAM_ONOFF, true)
	MainMenu:addParam('version', 'League Version', SCRIPT_PARAM_LIST, 1, {'5.13', '5.12'})
	IDBytes = {
		[1] = {
			[0x00] = 0x10, [0x01] = 0xC5, [0x02] = 0x0C, [0x03] = 0x9F, [0x04] = 0x9C, [0x05] = 0x75, [0x06] = 0xE5, [0x07] = 0x09, [0x08] = 0xC2, [0x09] = 0x43, [0x0A] = 0x97, [0x0B] = 0xB2, 
			[0x0C] = 0xA9, [0x0D] = 0x9A, [0x0E] = 0x0F, [0x0F] = 0x57, [0x10] = 0x54, [0x11] = 0x51, [0x12] = 0x01, [0x13] = 0x8A, [0x14] = 0x1B, [0x15] = 0xC8, [0x16] = 0xD3, [0x17] = 0x58, 
			[0x18] = 0x50, [0x19] = 0x23, [0x1A] = 0x4F, [0x1B] = 0xFF, [0x1C] = 0x95, [0x1D] = 0x84, [0x1E] = 0xA1, [0x1F] = 0x8C, [0x20] = 0x69, [0x21] = 0x30, [0x22] = 0xA8, [0x23] = 0xEF, 
			[0x24] = 0xBF, [0x25] = 0xFC, [0x26] = 0x59, [0x27] = 0x4E, [0x28] = 0x39, [0x29] = 0x5D, [0x2A] = 0x1F, [0x2B] = 0xE8, [0x2C] = 0xB7, [0x2D] = 0xAE, [0x2E] = 0xAC, [0x2F] = 0x9E, 
			[0x30] = 0xF8, [0x31] = 0xE0, [0x32] = 0x62, [0x33] = 0xA0, [0x34] = 0xC7, [0x35] = 0xD4, [0x36] = 0xBD, [0x37] = 0x0D, [0x38] = 0x5F, [0x39] = 0xE3, [0x3A] = 0x2E, [0x3B] = 0xD5, 
			[0x3C] = 0xCE, [0x3D] = 0x6D, [0x3E] = 0x81, [0x3F] = 0x63, [0x40] = 0xC0, [0x41] = 0xCF, [0x42] = 0x40, [0x43] = 0x1C, [0x44] = 0xB8, [0x45] = 0x3B, [0x46] = 0xD9, [0x47] = 0x94, 
			[0x48] = 0xBA, [0x49] = 0x88, [0x4A] = 0xC6, [0x4B] = 0x27, [0x4C] = 0x48, [0x4D] = 0x3E, [0x4E] = 0x1E, [0x4F] = 0xD0, [0x50] = 0x15, [0x51] = 0x7E, [0x52] = 0x08, [0x53] = 0x7C, 
			[0x54] = 0x70, [0x55] = 0x04, [0x56] = 0x41, [0x57] = 0xB1, [0x58] = 0xA6, [0x59] = 0xD1, [0x5A] = 0x4D, [0x5B] = 0xC3, [0x5C] = 0x05, [0x5D] = 0x90, [0x5E] = 0xC4, [0x5F] = 0x98, 
			[0x60] = 0xFE, [0x61] = 0x35, [0x62] = 0xED, [0x63] = 0xA5, [0x64] = 0xC9, [0x65] = 0x85, [0x66] = 0xF9, [0x67] = 0x74, [0x68] = 0x96, [0x69] = 0x8D, [0x6A] = 0xBC, [0x6B] = 0xFA, 
			[0x6C] = 0x31, [0x6D] = 0x11, [0x6E] = 0x5B, [0x6F] = 0xAD, [0x70] = 0x4C, [0x71] = 0xA2, [0x72] = 0xB3, [0x73] = 0xEE, [0x74] = 0xE6, [0x75] = 0xD8, [0x76] = 0x02, [0x77] = 0x3C, 
			[0x78] = 0x8B, [0x79] = 0xE2, [0x7A] = 0x7A, [0x7B] = 0xDD, [0x7C] = 0x4A, [0x7D] = 0x00, [0x7E] = 0x6A, [0x7F] = 0xE9, [0x80] = 0x7B, [0x81] = 0xF6, [0x82] = 0x89, [0x83] = 0x2C, 
			[0x84] = 0xEB, [0x85] = 0xCA, [0x86] = 0x6C, [0x87] = 0x2A, [0x88] = 0xDB, [0x89] = 0xE7, [0x8A] = 0xAF, [0x8B] = 0x4B, [0x8C] = 0x0E, [0x8D] = 0x16, [0x8E] = 0x2F, [0x8F] = 0x76, 
			[0x90] = 0x91, [0x91] = 0xF1, [0x92] = 0x92, [0x93] = 0x66, [0x94] = 0x44, [0x95] = 0xAA, [0x96] = 0x72, [0x97] = 0xF7, [0x98] = 0xF4, [0x99] = 0x93, [0x9A] = 0x2D, [0x9B] = 0x80, 
			[0x9C] = 0x03, [0x9D] = 0x65, [0x9E] = 0x42, [0x9F] = 0xF2, [0xA0] = 0x18, [0xA1] = 0xCC, [0xA2] = 0x8E, [0xA3] = 0x99, [0xA4] = 0x14, [0xA5] = 0x7D, [0xA6] = 0xC1, [0xA7] = 0xD2, 
			[0xA8] = 0x5E, [0xA9] = 0x33, [0xAA] = 0x64, [0xAB] = 0x3F, [0xAC] = 0x38, [0xAD] = 0x0A, [0xAE] = 0xD6, [0xAF] = 0xD7, [0xB0] = 0x6E, [0xB1] = 0xF3, [0xB2] = 0x1A, [0xB3] = 0xE4, 
			[0xB4] = 0x68, [0xB5] = 0x13, [0xB6] = 0x46, [0xB7] = 0xB0, [0xB8] = 0x73, [0xB9] = 0x12, [0xBA] = 0x06, [0xBB] = 0x5C, [0xBC] = 0x37, [0xBD] = 0x86, [0xBE] = 0x61, [0xBF] = 0x78, 
			[0xC0] = 0xB9, [0xC1] = 0xF0, [0xC2] = 0x21, [0xC3] = 0xBE, [0xC4] = 0x24, [0xC5] = 0xEA, [0xC6] = 0x32, [0xC7] = 0xDE, [0xC8] = 0xDA, [0xC9] = 0x8F, [0xCA] = 0x47, [0xCB] = 0x1D, 
			[0xCC] = 0xDF, [0xCD] = 0xBB, [0xCE] = 0x3D, [0xCF] = 0xE1, [0xD0] = 0x6F, [0xD1] = 0xA3, [0xD2] = 0x55, [0xD3] = 0xAB, [0xD4] = 0x83, [0xD5] = 0x17, [0xD6] = 0x7F, [0xD7] = 0x2B, 
			[0xD8] = 0x34, [0xD9] = 0x52, [0xDA] = 0x87, [0xDB] = 0xB6, [0xDC] = 0x45, [0xDD] = 0xFD, [0xDE] = 0x28, [0xDF] = 0xB4, [0xE0] = 0x26, [0xE1] = 0xCB, [0xE2] = 0xA4, [0xE3] = 0xA7, 
			[0xE4] = 0xF5, [0xE5] = 0xCD, [0xE6] = 0x77, [0xE7] = 0xDC, [0xE8] = 0x22, [0xE9] = 0x6B, [0xEA] = 0xEC, [0xEB] = 0x49, [0xEC] = 0x29, [0xED] = 0x9D, [0xEE] = 0x79, [0xEF] = 0x67, 
			[0xF0] = 0x3A, [0xF1] = 0x82, [0xF2] = 0x5A, [0xF3] = 0x9B, [0xF4] = 0xB5, [0xF5] = 0x0B, [0xF6] = 0x56, [0xF7] = 0x71, [0xF8] = 0x19, [0xF9] = 0x25, [0xFA] = 0x07, [0xFB] = 0xFB, 
			[0xFC] = 0x20, [0xFD] = 0x60, [0xFE] = 0x36, [0xFF] = 0x53,  		
		},
		[2] = {
			[0x00] = 0xFF, [0x01] = 0xDF, [0x02] = 0xFB, [0x03] = 0xDB, [0x04] = 0xF7, [0x05] = 0xD7, [0x06] = 0xF3, [0x07] = 0xD3, [0x08] = 0xFE, [0x09] = 0xDE, [0x0A] = 0xFA, [0x0B] = 0xDA, 
			[0x0C] = 0xF6, [0x0D] = 0xD6, [0x0E] = 0xF2, [0x0F] = 0xD2, [0x10] = 0xFD, [0x11] = 0xDD, [0x12] = 0xF9, [0x13] = 0xD9, [0x14] = 0xF5, [0x15] = 0xD5, [0x16] = 0xF1, [0x17] = 0xD1, 
			[0x18] = 0xFC, [0x19] = 0xDC, [0x1A] = 0xF8, [0x1B] = 0xD8, [0x1C] = 0xF4, [0x1D] = 0xD4, [0x1E] = 0xF0, [0x1F] = 0xD0, [0x20] = 0xBF, [0x21] = 0x9F, [0x22] = 0xBB, [0x23] = 0x9B, 
			[0x24] = 0xB7, [0x25] = 0x97, [0x26] = 0xB3, [0x27] = 0x93, [0x28] = 0xBE, [0x29] = 0x9E, [0x2A] = 0xBA, [0x2B] = 0x9A, [0x2C] = 0xB6, [0x2D] = 0x96, [0x2E] = 0xB2, [0x2F] = 0x92, 
			[0x30] = 0xBD, [0x31] = 0x9D, [0x32] = 0xB9, [0x33] = 0x99, [0x34] = 0xB5, [0x35] = 0x95, [0x36] = 0xB1, [0x37] = 0x91, [0x38] = 0xBC, [0x39] = 0x9C, [0x3A] = 0xB8, [0x3B] = 0x98, 
			[0x3C] = 0xB4, [0x3D] = 0x94, [0x3E] = 0xB0, [0x3F] = 0x90, [0x40] = 0x7F, [0x41] = 0x5F, [0x42] = 0x7B, [0x43] = 0x5B, [0x44] = 0x77, [0x45] = 0x57, [0x46] = 0x73, [0x47] = 0x53, 
			[0x48] = 0x7E, [0x49] = 0x5E, [0x4A] = 0x7A, [0x4B] = 0x5A, [0x4C] = 0x76, [0x4D] = 0x56, [0x4E] = 0x72, [0x4F] = 0x52, [0x50] = 0x7D, [0x51] = 0x5D, [0x52] = 0x79, [0x53] = 0x59, 
			[0x54] = 0x75, [0x55] = 0x55, [0x56] = 0x71, [0x57] = 0x51, [0x58] = 0x7C, [0x59] = 0x5C, [0x5A] = 0x78, [0x5B] = 0x58, [0x5C] = 0x74, [0x5D] = 0x54, [0x5E] = 0x70, [0x5F] = 0x50, 
			[0x60] = 0x3F, [0x61] = 0x1F, [0x62] = 0x3B, [0x63] = 0x1B, [0x64] = 0x37, [0x65] = 0x17, [0x66] = 0x33, [0x67] = 0x13, [0x68] = 0x3E, [0x69] = 0x1E, [0x6A] = 0x3A, [0x6B] = 0x1A, 
			[0x6C] = 0x36, [0x6D] = 0x16, [0x6E] = 0x32, [0x6F] = 0x12, [0x70] = 0x3D, [0x71] = 0x1D, [0x72] = 0x39, [0x73] = 0x19, [0x74] = 0x35, [0x75] = 0x15, [0x76] = 0x31, [0x77] = 0x11, 
			[0x78] = 0x3C, [0x79] = 0x1C, [0x7A] = 0x38, [0x7B] = 0x18, [0x7C] = 0x34, [0x7D] = 0x14, [0x7E] = 0x30, [0x7F] = 0x10, [0x80] = 0xEF, [0x81] = 0xCF, [0x82] = 0xEB, [0x83] = 0xCB, 
			[0x84] = 0xE7, [0x85] = 0xC7, [0x86] = 0xE3, [0x87] = 0xC3, [0x88] = 0xEE, [0x89] = 0xCE, [0x8A] = 0xEA, [0x8B] = 0xCA, [0x8C] = 0xE6, [0x8D] = 0xC6, [0x8E] = 0xE2, [0x8F] = 0xC2, 
			[0x90] = 0xED, [0x91] = 0xCD, [0x92] = 0xE9, [0x93] = 0xC9, [0x94] = 0xE5, [0x95] = 0xC5, [0x96] = 0xE1, [0x97] = 0xC1, [0x98] = 0xEC, [0x99] = 0xCC, [0x9A] = 0xE8, [0x9B] = 0xC8, 
			[0x9C] = 0xE4, [0x9D] = 0xC4, [0x9E] = 0xE0, [0x9F] = 0xC0, [0xA0] = 0xAF, [0xA1] = 0x8F, [0xA2] = 0xAB, [0xA3] = 0x8B, [0xA4] = 0xA7, [0xA5] = 0x87, [0xA6] = 0xA3, [0xA7] = 0x83, 
			[0xA8] = 0xAE, [0xA9] = 0x8E, [0xAA] = 0xAA, [0xAB] = 0x8A, [0xAC] = 0xA6, [0xAD] = 0x86, [0xAE] = 0xA2, [0xAF] = 0x82, [0xB0] = 0xAD, [0xB1] = 0x8D, [0xB2] = 0xA9, [0xB3] = 0x89, 
			[0xB4] = 0xA5, [0xB5] = 0x85, [0xB6] = 0xA1, [0xB7] = 0x81, [0xB8] = 0xAC, [0xB9] = 0x8C, [0xBA] = 0xA8, [0xBB] = 0x88, [0xBC] = 0xA4, [0xBD] = 0x84, [0xBE] = 0xA0, [0xBF] = 0x80, 
			[0xC0] = 0x6F, [0xC1] = 0x4F, [0xC2] = 0x6B, [0xC3] = 0x4B, [0xC4] = 0x67, [0xC5] = 0x47, [0xC6] = 0x63, [0xC7] = 0x43, [0xC8] = 0x6E, [0xC9] = 0x4E, [0xCA] = 0x6A, [0xCB] = 0x4A, 
			[0xCC] = 0x66, [0xCD] = 0x46, [0xCE] = 0x62, [0xCF] = 0x42, [0xD0] = 0x6D, [0xD1] = 0x4D, [0xD2] = 0x69, [0xD3] = 0x49, [0xD4] = 0x65, [0xD5] = 0x45, [0xD6] = 0x61, [0xD7] = 0x41, 
			[0xD8] = 0x6C, [0xD9] = 0x4C, [0xDA] = 0x68, [0xDB] = 0x48, [0xDC] = 0x64, [0xDD] = 0x44, [0xDE] = 0x60, [0xDF] = 0x40, [0xE0] = 0x2F, [0xE1] = 0x0F, [0xE2] = 0x2B, [0xE3] = 0x0B, 
			[0xE4] = 0x27, [0xE5] = 0x07, [0xE6] = 0x23, [0xE7] = 0x03, [0xE8] = 0x2E, [0xE9] = 0x0E, [0xEA] = 0x2A, [0xEB] = 0x0A, [0xEC] = 0x26, [0xED] = 0x06, [0xEE] = 0x22, [0xEF] = 0x02, 
			[0xF0] = 0x2D, [0xF1] = 0x0D, [0xF2] = 0x29, [0xF3] = 0x09, [0xF4] = 0x25, [0xF5] = 0x05, [0xF6] = 0x21, [0xF7] = 0x01, [0xF8] = 0x2C, [0xF9] = 0x0C, [0xFA] = 0x28, [0xFB] = 0x08, 
			[0xFC] = 0x24, [0xFD] = 0x04, [0xFE] = 0x20, [0xFF] = 0x00, 	
		},
	}
	local gameSettings = GetGameSettings()
	if gameSettings and gameSettings.General and gameSettings.General.Width and gameSettings.General.Height then
		windowWidth, windowHeight = gameSettings.General.Width, gameSettings.General.Height
		local path = GAME_PATH .. 'DATA\\menu\\hud\\hud' .. windowWidth .. 'x' .. windowHeight .. '.ini'
		local hudSettings = ReadIni(path)
		if hudSettings and hudSettings.Globals and hudSettings.Globals.GlobalScale then 
			GlobalScale = hudSettings.Globals.GlobalScale + 1
		end
	end	
	WARD()
	MISS()
	SKILLS()
	TIMERS()
	TRINKET()
	OTHER()
	local Version = 1.4
	AwareUpdate(
		Version,
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/Danger-Meter/MoarSaltThanAroc.version', 
		'/PewPewPew2/BoL/Danger-Meter/MoarSaltThanAroc.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Reload(F9 F9)') end, 
		function() Print(loadMsg:sub(1,#loadMsg-2)) end, 
		function() Print(MainMenu.update and 'New Version Found, please wait...' or 'New Version found please download manually or enable AutoUpdate') end, 
		function() Print('An Error Occured in Update.') end
	)
end)

class 'AwareUpdate'
  
function AwareUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)	
	if LocalVersion == 'isSprite' then
		self.isSprite = true
		self.Host = Host
		self.SavePath = SavePath
		self.CallbackUpdate = CallbackUpdate
		self.CallbackNoUpdate = CallbackNoUpdate
		self.CallbackNewVersion = CallbackNewVersion
		self.CallbackError = CallbackError
		self:CreateSocket('/Updater.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999))
		AddTickCallback(function() self:DownloadUpdate() end)
	else
		self.LocalVersion = LocalVersion
		self.Host = Host
		self.VersionPath = '/Updater.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
		self.ScriptPath = '/Updater.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
		self.SavePath = SavePath
		self.CallbackUpdate = CallbackUpdate
		self.CallbackNoUpdate = CallbackNoUpdate
		self.CallbackNewVersion = CallbackNewVersion
		self.CallbackError = CallbackError
		self:CreateSocket(self.VersionPath)
		self.DownloadStatus = 'Connect to Server for VersionInfo'
		AddTickCallback(function() self:GetOnlineVersion() end)
	end
end

function AwareUpdate:OnDraw()
	local bP = {['x1'] = WINDOW_W - (WINDOW_W - 390),['x2'] = WINDOW_W - (WINDOW_W - 20),['y1'] = WINDOW_H / 2,['y2'] = (WINDOW_H / 2) + 20,}
	local text = 'Download Status: '..(self.DownloadStatus or 'Unknown')
	DrawLine(bP.x1, bP.y1 + 10, bP.x2,  bP.y1 + 10, 18, ARGB(0x7D,0xE1,0xE1,0xE1))
	local xOff
	if self.File and self.Size then
		local c = math.round(100/self.Size*self.File:len(),2)/100
		xOff = c < 1 and math.ceil(370 * c) or 370
	else
		xOff = 0
	end
	DrawLine(bP.x2 + xOff, bP.y1 + 10, bP.x2, bP.y1 + 10, 18, ARGB(0xC8,0xE1,0xE1,0xE1))
	DrawLines2({D3DXVECTOR2(bP.x1, bP.y1),D3DXVECTOR2(bP.x2, bP.y1),D3DXVECTOR2(bP.x2, bP.y2),D3DXVECTOR2(bP.x1, bP.y2),D3DXVECTOR2(bP.x1, bP.y1),}, 3, ARGB(0xB9, 0x0A, 0x0A, 0x0A))
	DrawText(text, 16, WINDOW_W - (WINDOW_W - 205) - (GetTextArea(text, 16).x / 2), bP.y1 + 2, ARGB(0xB9,0x0A,0x0A,0x0A))
end

function AwareUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('pewpewpew.website', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function AwareUpdate:Base64Encode(data)
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

function AwareUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: pewpewpew.website\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<lua'..'file>') then
            local _,ScriptFind = self.File:find('<lua'..'file>')
            local ScriptEnd = self.File:find('</lua'..'file>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</lua'..'file>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<lua'..'file>')
        local ContentEnd, _ = self.File:find('</lua'..'file>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
				if not MainMenu.update then return end
				AddDrawCallback(function() self:OnDraw() end)
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

function AwareUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: pewpewpew.website\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<lua'..'file>') then
            local _,ScriptFind = self.File:find('<lua'..'file>')
            local ScriptEnd = self.File:find('</lua'..'file>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</lua'..'file>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<lua'..'file>')
        local ContentEnd, _ = self.NewFile:find('</lua'..'file>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
				print('Error1')
				self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if not self.isSprite and type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
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
	self.Types = {
		['YellowTrinket'] 		 = { ['color'] = COLOR_YELLOW,			 	['duration'] = 60,   ['isWard'] = true,  },
		['YellowTrinketUpgrade'] = { ['color'] = COLOR_YELLOW,				['duration'] = 120,  ['isWard'] = true,  },
		['SightWard'] 			 = { ['color'] = ARGB(255,0,255,0),			['duration'] = 180,  ['isWard'] = true,  },
		['VisionWard']  		 = { ['color'] = ARGB(255, 255, 50, 255), 	['duration'] = huge, ['isWard'] = true,  },
		['TeemoMushroom'] 		 = { ['color'] = COLOR_RED,					['duration'] = 600,  ['isWard'] = false, },
		['CaitlynTrap'] 		 = { ['color'] = COLOR_RED,					['duration'] = 240,  ['isWard'] = false, },
		['Nidalee_Spear'] 		 = { ['color'] = COLOR_RED,					['duration'] = 120,  ['isWard'] = false, },
		['ShacoBox'] 			 = { ['color'] = COLOR_RED,					['duration'] = 60, 	 ['isWard'] = false, },
		['DoABarrelRoll'] 		 = { ['color'] = COLOR_RED,					['duration'] = 35, 	 ['isWard'] = false, },
	}
	self.OnSpell = {
		['sightward'] = self.Types['SightWard'], ['visionward'] = self.Types['VisionWard'], ['itemghostward'] = self.Types['SightWard'], ['trinkettotemlvl2'] =  self.Types['YellowTrinketUpgrade'],
		['trinkettotemlvl1'] = self.Types['YellowTrinket'], ['trinkettotemlvl3'] = self.Types['SightWard'], ['trinkettotemlvl3b'] = self.Types['VisionWard'], ['bantamtrap'] = self.Types['TeemoMushroom'],
		['caitlynyordletrap'] = self.Types['CaitlynTrap'], ['bushwhack'] = self.Types['Nidalee_Spear'], ['jackinthebox'] = self.Types['ShacoBox'], ['maokaisapling'] = self.Types['DoABarrelRoll'],
	}
	self.SelfWards = {
		['x1'] = (GlobalScale * 200),
		['y1'] = WINDOW_H - 72,
		['background'] = ARGB(80, 0, 0, 0),
	}
	self.MyWards = {}
	self.Active = {}
	self.Known = {}
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
	wM:addParam('drawSelf', 'Enable Self Ward Tracker', SCRIPT_PARAM_ONOFF, true)
	wM:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	wM:addParam('drawHex', 'Draw Hexagon on Timers', SCRIPT_PARAM_ONOFF, true)
	wM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	wM:addParam('mapsize', 'Minimap Marker Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	wM:addParam('maptype', 'Minimap Marker Type', SCRIPT_PARAM_LIST, 1, { 'Marker', 'Timer' })
	wM:addParam('drawRange', 'Draw Ward Vision Radius', SCRIPT_PARAM_ONKEYDOWN, false, ('G'):byte())
	wM:addParam('remove', 'Remove Object Under Mouse', SCRIPT_PARAM_ONKEYDOWN, false, ('X'):byte())
	return wM
end

function WARD:CreateObj(o)
	if o.valid then
		if o.type == 'obj_AI_Minion' and self.Types[o.charName] then
			if o.team == TEAM_ENEMY then
				local timeReduction = 0
				local charName
				for i, ward in ipairs(self.Known) do
					if ward and GetDistanceSqr(ward.pos, o.pos) < 50000 then
						timeReduction = self.Types[o.charName] and self.Types[o.charName].duration - (ward.endTime-clock()) or 0
						charName = ward.charName
						table.remove(self.Known, i)
						break
					end
				end
				self.Known[#self.Known + 1] = {
					['pos'] 	 = Vector(o.pos),
					['mapPos']   = GetMinimap(Vector(o.pos)), 
					['color']	 = self.Types[o.charName].color, 
					['endTime']	 = clock() + o.mana,
					['charName'] = charName or 'Unknown',
					['isWard']   = self.Types[o.charName].isWard,
					['netID']	 = o.networkID,
				}
			elseif self.Types[o.charName].isWard then
				self.MyWards[#self.MyWards + 1] = {
					['object'] = o,
					['time'] = clock(),
				}			
			end
		end
		if o.type == 'MissileClient' and o.spellOwner and o.spellOwner.isMe and o.spellName == 'itemplacementmissile' then
			for k, v in ipairs(self.MyWards) do
				if v.time + 0.1 > clock() and GetDistanceSqr(o.spellStart, v.object) < 1440000 then
					if self.Types[v.object.charName].duration then
						if self.Types[v.object.charName].duration ~= huge then
							table.insert(self.Active, 1, {
									['object'] = v.object,
									['endTime'] = clock() + self.Types[v.object.charName].duration,
							})
							if self.Active[4] then table.remove(self.Active, 4) end
						else
							self.Active['Pink'] = v.object
						end
					end
				end
			end
		end
	end	
end

function WARD:DeleteObj(o)
	if o.valid and o.type == 'obj_AI_Minion' and self.Types[o.charName] then
		for i, ward in ipairs(self.Known) do
			if ward.netID == o.networkID then
				table.remove(self.Known, i)
				return
			end
		end	
	end
end

function WARD:Draw()
	if self.wM.draw then 
		for i, ward in ipairs(self.Known) do
			if self.wM.remove and GetDistanceSqr(mousePos, ward.pos) < 5625 then
				table.remove(self.Known, i)
				return
			end
			if ward.isWard and self.wM.drawRange then
				local wts = WorldToScreen(D3DXVECTOR3(ward.pos.x, ward.pos.y, ward.pos.z))
				local d32 = D3DXVECTOR2(wts.x,wts.y)
				if OnScreen(d32.x, d32.y) then
					local vision = {}
					for theta = 0, (pi2+(pi2/30)), (pi2/30) do
						local p
						for i=20, 1100, 20 do
							local p2 = D3DXVECTOR3(ward.pos.x+(i*cos(theta)), ward.pos.y, ward.pos.z-(i*sin(theta)))
							if IsWall(p2) or i==1100 then
								p = p2
								break
							end
						end
						local tS = WorldToScreen(p)
						vision[#vision + 1] = D3DXVECTOR2(tS.x, tS.y)
					end
					DrawLines2(vision,2,ward.color)
				end
			end
			local text, mapText
			if ward.endTime == huge then
				mapText = 'o'
				text = ward.charName
			else
				local timer = ward.endTime-clock()
				if self.wM.type == 1 then
					mapText = ('%d'):format(timer)
					text = mapText..'\n'..ward.charName
				else
					mapText = ('%d:%.2d'):format(timer/60, timer%60)
					text = mapText..'\n'..ward.charName
				end
			end	
			DrawText3D(text, ward.pos.x, ward.pos.y+85, ward.pos.z+10, self.wM.size, ward.color, true)
			local c = GetTextArea(mapText, self.wM.mapsize)
			DrawText(mapText, self.wM.mapsize, ward.mapPos.x - (c.x / 2), ward.mapPos.y - (c.y / 2), ward.color)
			if self.wM.drawHex then
				self:DrawHex(ward.pos.x, ward.pos.y, ward.pos.z, ward.color)
			end
			if ward.endTime < clock() then
				table.remove(self.Known, i)
				return
			end
		end
	end
	if self.wM.drawSelf then
		DrawLine(self.SelfWards.x1 - 8, self.SelfWards.y1, self.SelfWards.x1 + 181, self.SelfWards.y1, 95, self.SelfWards.background)
		for k=1, 3 do
			local v = self.Active[k]
			if v then
				local t = v.endTime - clock()
				if t < 1 or not v.object or not v.object.valid or v.object.dead then
					table.remove(self.Active, k)
					return
				else
					DrawText(k..(' - %d:%.2d'):format(t / 60, t % 60), 26, self.SelfWards.x1, WINDOW_H - 30 - (k * 22), COLOR_TRANS_GREEN)
				end
			else
				DrawText(k..' - Not Active', 26, self.SelfWards.x1, WINDOW_H - 30 - (k * 22), COLOR_ORANGE)		
			end
		end
		if self.Active['Pink'] then
			if self.Active['Pink'].valid and not self.Active['Pink'].dead then
				DrawText('Pink - Active', 26, self.SelfWards.x1, WINDOW_H - 118,  ARGB(200, 255, 50, 255))
			else
				self.Active['Pink'] = nil
			end
		else
			DrawText('Pink - Not Active', 26, self.SelfWards.x1, WINDOW_H - 118,  COLOR_TRANS_RED)
		end	
	end
end

function WARD:ProcessSpell(u, s)
	if u.valid and u.team == TEAM_ENEMY and self.OnSpell[s.name:lower()] then
		self.Known[#self.Known+1] = {
			['pos'] 	 = Vector(s.endPos),
			['mapPos']   = GetMinimap(Vector(s.endPos)),
			['color'] 	 = self.OnSpell[s.name:lower()].color,
			['endTime']  = clock()+self.OnSpell[s.name:lower()].duration,
			['charName'] = u.charName or 'Unknown',
			['isWard']   = self.OnSpell[s.name:lower()].isWard,
			['netID']	 = 0,
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
	if not FileExist(SPRITE_PATH..'mapIcons/'..myHero.charName..'.png') then
		Print('Minimap Sprites Not Found!!! Please Download from forum')
		if not FileExist(SPRITE_PATH..'Generic.png') then
			AwareUpdate(
				'isSprite', 
				'i.imgur.com',
				nil, 
				'/6dSBvc1.png',
				SPRITE_PATH..'Generic.png', 
				function() Print('Sprite Download complete') end, 
				function() return end, 
				function() return end, 
				function() Print('An error occured downloading sprite') end
			)
		end
	end
	if not FileExist(SPRITE_PATH..'mapIcons/Ekko.png') then
		AwareUpdate(
			'isSprite', 
			'i.imgur.com',
			nil, 
			'/ObTTrXL.png', 
			SPRITE_PATH..'mapIcons/Ekko.png', 
			function() Print('Sprite Download complete') end, 
			function() return end, 
			function() return end, 
			function() Print('An error occured downloading sprite') end
		)
	end
	self.missing = {}
	self.activeRecalls = {}
	self.Sprites = {}	
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
	self.Allies = {}
	self.recallBar = GetMinimap(0, 18000)
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team == TEAM_ENEMY then
			self.missing[hero.networkID] = nil
            self.Sprites[hero.networkID] = createSprite(io.open(SPRITE_PATH..'mapIcons/'..hero.charName..'.png', 'r') and "mapIcons/".. hero.charName ..".png" or 'Generic.png')
            self.Sprites[hero.networkID]:SetScale(0.45, 0.45)
		else
			self.Allies[#self.Allies + 1] = hero
		end
	end
	for k, v in pairs(self.Sprites) do
		v:SetScale(0.45, 0.45)
	end
	self.Packets = {
		[1] = { --5.13
			['LoseVision'] = { ['Header'] = 0x00C0, ['pos'] = 2, },
			['GainVision'] = { ['Header'] = 0x002D, ['pos'] = 2, },
			['Recall'] = { ['Header'] = 0x0064, ['pos'] = 30, ['stringPos'] = 34, },
			['Reset'] = { ['Header'] = 0x0041, ['pos'] = 2, ['pos2'] = 6, },
			['Aggro'] = { ['Header'] = 0x0039, ['pos'] = 2, },
			['Missile'] = { ['Header'] = 0x00BA, ['pos'] = 2, },
			['JunglePos'] = {
				[0xEC8ABF0C] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',	 	['text'] = 'Top Blue',   },
				[0xECEF186F] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3', 	['text'] = 'Top Blue',   },
				[0xEC910889] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',			['text'] = 'Top Blue',   },
				[0x6C8F874E] = { ['pos'] = GetMinimap(Vector(12600, 60, 6400)), ['name'] = 'SRU_Gromp14.1.1',	 	['text'] = 'Top Gromp',  },
				[0xECE87AC6] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',	['text'] = 'Top Wolves', },
				[0xECE46933] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',	 	['text'] = 'Top Wolves', },
				[0xECADE556] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',	['text'] = 'Top Wolves', },
				[0x21362330] = { ['pos'] = GetMinimap(Vector(10500, 60, 5170)), ['name'] = 'Sru_Crab15.1.1',		['text'] = 'Dragon Crab',},
				[0xECED78FD] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)), 	['name'] = 'SRU_RazorbeakMini3.1.4',['text'] = 'Bot Raptors',},
				[0x6C9D5ABB] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.3',['text'] = 'Bot Raptors',},
				[0xECF7B8BB] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_Razorbeak3.1.1', 	['text'] = 'Bot Raptors',},
				[0xEAA36B39] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.2',['text'] = 'Bot Raptors',},
				[0x6CED46A1] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',	 	['text'] = 'Bot Red',    },
				[0xEEFC6522] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',	 	['text'] = 'Bot Red',    },
				[0x6CD9AB50] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',		 	['text'] = 'Bot Red',    },
				[0xEA18D0ED] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.2',		 	['text'] = 'Bot Krugs',  },
				[0x6EB4A88E]  = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)), 	['name'] = 'SRU_KrugMini5.1.1',	 	['text'] = 'Bot Krugs',  },
				[0x6AD4919F]  = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',['text'] = 'Top Raptors',},
				[0xEE7CD686] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',['text'] = 'Top Raptors',},
				[0x6CEB5850] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1', 	['text'] = 'Top Raptors',},
				[0xECFC3C80] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',['text'] = 'Top Raptors',},
				[0x6CDEE106] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',  	['text'] = 'Top Red',    },
				[0xECEDCB94] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3', 	['text'] = 'Top Red',    },
				[0xEC86FDAB] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',		 	['text'] = 'Top Red',    },
				[0xECBA1121] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.2',	 	['text'] = 'Top Krugs',  },
				[0x6A784FB9]  = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.1', 	['text'] = 'Top Krugs',  },
				[0x216974E1] = { ['pos'] = GetMinimap(Vector(4400, 60, 9600)),  ['name'] = 'SRU_Crab16.1.1',		['text'] = 'Baron Crab', },
				[0x6CA22608] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3', 	['text'] = 'Bot Blue',   },
				[0x6CF11C65] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',	 	['text'] = 'Bot Blue',   },
				[0x6CC58760] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',		 	['text'] = 'Bot Blue',   },
				[0xECED96C4] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',	 	['text'] = 'Bot Gromp',  },
				[0x6CE28181] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',	['text'] = 'Bot Wolves', },
				[0x6CADEC0B] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',	 	['text'] = 'Bot Wolves', },
				[0x6CC59B7D] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',	['text'] = 'Bot Wolves', },
				[0xEC924F2B] = { ['pos'] = GetMinimap(Vector(9866, 60, 4414)),  ['name'] = 'SRU_Dragon6.1.1',	 	['text'] = 'Dragon',	 },
				[0x99999999] = { ['pos'] = GetMinimap(Vector(4400, 60, 9600)),  ['name'] = 'SRU_Baron12.1.1',	 	['text'] = 'Baron',	 	 },
			},	
		},
		[2] = {
			['LoseVision'] = { ['Header'] = 0x005B, ['pos'] = 2, },
			['GainVision'] = { ['Header'] = 0x0007, ['pos'] = 2, },
			['Recall'] = { ['Header'] = 0x00E9, ['pos'] = 30, ['stringPos'] = 35, },
			['Reset'] = { ['Header'] = 0x0034, ['pos'] = 2, ['pos2'] = 7, },
			['Aggro'] = { ['Header'] = 0x009F, ['pos'] = 2, },
			['Missile'] = { ['Header'] = 0x00BA, ['pos'] = 2, },
			['JunglePos'] = {
				[0x782AE808] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',	 	['text'] = 'Top Blue',   },
				[0x78638625] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3', 	['text'] = 'Top Blue',   },
				[0x78AC1739] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',			['text'] = 'Top Blue',   },
				[0x539DEF50] = { ['pos'] = GetMinimap(Vector(12600, 60, 6400)), ['name'] = 'SRU_Gromp14.1.1',	 	['text'] = 'Top Gromp',  },
				[0x785C81BB] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',	['text'] = 'Top Wolves', },
				[0x78C4F5DE] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',	 	['text'] = 'Top Wolves', },
				[0x780CB19E] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',	['text'] = 'Top Wolves', },
				[0xEFDCE43]  = { ['pos'] = GetMinimap(Vector(10500, 60, 5170)), ['name'] = 'Sru_Crab15.1.1',		['text'] = 'Dragon Crab',},
				[0x78E9BF1E] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)), 	['name'] = 'SRU_RazorbeakMini3.1.4',['text'] = 'Bot Raptors',},
				[0x5329C81F] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.3',['text'] = 'Bot Raptors',},
				[0x781B7A1F] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_Razorbeak3.1.1', 	['text'] = 'Bot Raptors',},
				[0xC5D14548] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.2',['text'] = 'Bot Raptors',},
				[0x53E97D0E] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',	 	['text'] = 'Bot Red',    },
				[0xEE0BF1F7] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',	 	['text'] = 'Bot Red',    },
				[0x538B403A] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',		 	['text'] = 'Bot Red',    },
				[0xC58643E9] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.2',		 	['text'] = 'Bot Krugs',  },
				[0x5B6BDAE3] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)), 	['name'] = 'SRU_KrugMini5.1.1',	 	['text'] = 'Bot Krugs',  },
				[0x7723AC80] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',['text'] = 'Top Raptors',},
				[0xEE1272BA] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',['text'] = 'Top Raptors',},
				[0x5384323A] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1', 	['text'] = 'Top Raptors',},
				[0x780BFE3F] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',['text'] = 'Top Raptors',},
				[0x53F0D46F] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',  	['text'] = 'Top Red',    },
				[0x78E96A51] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3', 	['text'] = 'Top Red',    },
				[0x78BA1E40] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',		 	['text'] = 'Top Red',    },
				[0x78332B5D] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.2',	 	['text'] = 'Top Krugs',  },
				[0x77BF689A] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.1', 	['text'] = 'Top Krugs',  },
				[0xED3D6CD]  = { ['pos'] = GetMinimap(Vector(4400, 60, 9600)),  ['name'] = 'SRU_Crab16.1.1',		['text'] = 'Baron Crab', },
				[0x53BEDF17] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3', 	['text'] = 'Bot Blue',   },
				[0x53D642F1] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',	 	['text'] = 'Bot Blue',   },
				[0x53ABEFD8] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',		 	['text'] = 'Bot Blue',   },
				[0x78E9C088] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',	 	['text'] = 'Bot Gromp',  },
				[0x53AA4646] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',	['text'] = 'Bot Wolves', },
				[0x530C78B0] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',	 	['text'] = 'Bot Wolves', },
				[0x53AB67D7] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',	['text'] = 'Bot Wolves', },
				[0x783768A8] = { ['pos'] = GetMinimap(Vector(9866, 60, 4414)),  ['name'] = 'SRU_Dragon6.1.1',	 	['text'] = 'Dragon',	 },
				[0x99999999] = { ['pos'] = GetMinimap(Vector(4400, 60, 9600)),  ['name'] = 'SRU_Baron12.1.1',	 	['text'] = 'Baron',	 	 },
			},
		},
	}
	
	self.JungleTracker = {}
	self.mM = self:Menu()
	if GetGame().map.shortName == 'summonerRift' then
		AddRecvPacketCallback2(function(p) self:JunglePackets(p) end)
	end
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddDrawCallback(function() self:Draw() end)
	loadMsg = loadMsg..'MissTimers, '
end

function MISS:Menu()
	MainMenu:addSubMenu('Missing Enemies', 'MissTracker')
	local mM = MainMenu.MissTracker
	mM:addParam('draw', 'Enable Missing Timers', SCRIPT_PARAM_ONOFF, true)
	mM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	mM:addParam('spriteSize', 'Sprite Size', SCRIPT_PARAM_SLICE, 45, 1, 100)
	mM:addParam('recall', 'Display Recall Status', SCRIPT_PARAM_ONOFF, true)
	mM:addParam('jungle', 'Display Jungle Tracker', SCRIPT_PARAM_ONOFF, true)
	self.LastCheck = mM.spriteSize
	AddTickCallback(function()
		if self.mM.spriteSize ~= self.LastCheck then
			for k, v in pairs(self.Sprites) do
				v:SetScale(self.mM.spriteSize / 100, self.mM.spriteSize / 100)
			end			
		end
	end)
	return mM	
end

function MISS:RecvPacket(p)
	if p.header == self.Packets[MainMenu.version].LoseVision.Header then
		p.pos=self.Packets[MainMenu.version].LoseVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.dead then
				self.missing[o.networkID] = {
					['pos'] = self.recallEndPos,
					['name'] = o.charName, 
					['mTime'] = clock(),
				}			
			else
				self.missing[o.networkID] = {
					['pos'] = GetMinimap(Vector(o.pos)),
					['name'] = o.charName, 
					['mTime'] = clock(),
				}
				return
			end
		end	
	end
	if p.header == self.Packets[MainMenu.version].GainVision.Header then
		p.pos=self.Packets[MainMenu.version].GainVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.missing[o.networkID] = nil
			return
		end
	end
	if p.header == self.Packets[MainMenu.version].Recall.Header then
		p.pos = self.Packets[MainMenu.version].Recall.pos
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = IDBytes[MainMenu.version][p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			p.pos=self.Packets[MainMenu.version].Recall.stringPos
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
				if self.activeRecalls[o.networkID].endT > clock() then
					self.activeRecalls[o.networkID] = nil
					return
				else
					self.missing[o.networkID] = {pos = self.recallEndPos, name = o.charName, mTime = clock(),}
					self.activeRecalls[o.networkID].complete = clock() + 3
					return
				end
			end
		end
	end
end

function MISS:JunglePackets(p)
	if p.header == self.Packets[MainMenu.version].Reset.Header then
		p.pos=self.Packets[MainMenu.version].Reset.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if (not o) or (o.valid and not o.visible) then
			p.pos=self.Packets[MainMenu.version].Reset.pos2
			local d4 = p:Decode4()
			if self.Packets[MainMenu.version].JunglePos[d4] then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets[MainMenu.version].JunglePos[d4].pos.x then 
						return 
					end
				end
				if o then
					for i, ally in ipairs(self.Allies) do
						if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
							return
						end
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets[MainMenu.version].JunglePos[d4].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets[MainMenu.version].JunglePos[d4].text, }
			end
		end
	elseif p.header == self.Packets[MainMenu.version].Aggro.Header then
		p.pos=self.Packets[MainMenu.version].Aggro.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and not o.visible then
			local index
			for _, camp in pairs(self.Packets[MainMenu.version].JunglePos) do
				if camp.name == o.name then
					index = _
				end
			end
			if index then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets[MainMenu.version].JunglePos[index].pos.x then
						return 
					end
				end
				for i, ally in ipairs(self.Allies) do
					if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
						return
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets[MainMenu.version].JunglePos[index].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets[MainMenu.version].JunglePos[index].text, }
			end
		end
	elseif p.header == self.Packets[MainMenu.version].Missile.Header then
		p.pos=self.Packets[MainMenu.version].Missile.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.team == 300 and not o.visible then
			local index
			for i, info in pairs(self.Packets[MainMenu.version].JunglePos) do
				if info.name == o.name then
					index = i
					break
				end
			end
			if index then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets[MainMenu.version].JunglePos[index].pos.x then 
						return 
					end
				end
				for i, ally in ipairs(self.Allies) do
					if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
						return
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets[MainMenu.version].JunglePos[index].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets[MainMenu.version].JunglePos[index].text, }
			end
		end		
	end
end

function MISS:Draw()
	if not self.mM.draw then return end
	local mCount = 1
	for _, info in pairs(self.missing) do
		if info then
			self.Sprites[_]:Draw(info.pos.x - 10, info.pos.y - 10, 255)
			DrawText(('%d'):format(clock()-info.mTime), self.mM.size, info.pos.x - (self.mM.size / 6), info.pos.y - (self.mM.size / 6), COLOR_TRANS_RED)
		end
	end
	if self.mM.recall then
		local count = 0
		for _, info in pairs(self.activeRecalls) do
			local yOffset = count * -30
			local percent = (info.endT - clock()) / info.duration
			local x2 = self.recallBar.x + ((WINDOW_W - 10 - self.recallBar.x) * percent)
			x2 = x2 > self.recallBar.x and x2 or self.recallBar.x
			DrawLine(self.recallBar.x-1, self.recallBar.y + yOffset, x2, self.recallBar.y + yOffset, 16, ARGB(255, 255 * percent, 255 - (255 * percent), 0))
			local Lines = {
				D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y - 8 + yOffset),
				D3DXVECTOR2(WINDOW_W - 10, 			self.recallBar.y - 8 + yOffset),
				D3DXVECTOR2(WINDOW_W - 10, 			self.recallBar.y + 8 + yOffset),
				D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y + 8 + yOffset),
				D3DXVECTOR2(self.recallBar.x - 2, 	self.recallBar.y - 8 + yOffset),
			}
			DrawLines2(Lines, 2, COLOR_WHITE)
			if info.complete then
				local text = info.name..' Completed.'
				DrawText(text, 12, ((self.recallBar.x + (WINDOW_W - 10)) / 2) - (GetTextArea(text, 12).x / 2), self.recallBar.y - 6 + yOffset, COLOR_WHITE)	
				if info.complete < clock() then
					self.activeRecalls[_] = nil
					return
				end
			else
				local text = info.name..' '..ceil(percent * 100)..'%'
				DrawText(text, 12, ((self.recallBar.x + (WINDOW_W - 10)) / 2) - (GetTextArea(text, 12).x / 2), self.recallBar.y - 6 + yOffset, COLOR_WHITE)
			end
			count = count + 1
		end
	end
	if self.mM.jungle then
		for i, camp in ipairs(self.JungleTracker) do
			if camp.endTime < os.clock() then
				table.remove(self.JungleTracker, i)
				return
			end
			local hex = {}
			for theta = 0, (pi2+(pi2/6)), (pi2/6) do
				hex[#hex + 1] = D3DXVECTOR2(camp.pos.x+(12*cos(theta)), camp.pos.y-(12*sin(theta)))
			end
			DrawLines2(hex, 1, COLOR_WHITE)
		end
		if #self.JungleTracker == 1 then
			local x = WINDOW_W/2
			local y = WINDOW_H/8
			local area = GetTextArea(self.JungleTracker[1].text, 32)
			DrawLines2({D3DXVECTOR2(x-100, y-25),D3DXVECTOR2(x+100, y-25),D3DXVECTOR2(x+100, y+25),D3DXVECTOR2(x-100, y+25), D3DXVECTOR2(x-100, y-25)}, 2, COLOR_WHITE)
			DrawLine(x-100, y, x+100, y, 50, COLOR_TRANS_RED)
			DrawText(self.JungleTracker[1].text, 32, x - (area.x / 2), y - 10, COLOR_TRANS_WHITE)
			DrawText('Jungle Tracker', 16, x - 45, y - 25, COLOR_TRANS_WHITE)	
		end
	end
end

class 'SKILLS'

function SKILLS:__init()
	self.Enemies = {}
	self.Allies = {}
	self.SkillText = {
		['summonerdot']      		= 'Ignite',
		['summonerexhaust']  		= 'Exhaust',
		['summonerflash']    		= 'Flash',
		['summonerheal']     		= 'Heal',
		['summonersmite']    		= 'Smite',
		['summonerbarrier']  		= 'Barrier',
		['summonerclairvoyance']    = 'Clairvoyance',
		['summonermana']     		= 'Clarity',
		['summonerteleport']     	= 'Teleport',
		['summonerrevive']     		= 'Revive',
		['summonerhaste']     		= 'Ghost',
		['summonerboost']     		= 'Cleanse',
	}
	self.HPBarOffsets = {}
	self.HeroOffsets = {
		['aatrox']   = -4,		['anivia']		= -2,	['diana']	   =  4,	['fiora']	 = -2,		['gnar']		= -2,	['gragas']	   = -3,
		['janna']	 = -2,		['jayce']		= -2,	['karma']	   = -2,	['kassadin'] = -4,		['kennen']		= -2,	['khazix']	   = -1,
		['leblanc']  =  1,		['leesin']		= -2,	['lulu']  	   = -4,	['nami']     = -5,		['nautilus']	= -4,	['olaf']   	   = -4,
		['orianna']  = -3,		['pantheon']	= -2,	['poppy']      = -4,	['quinn']    = -1,		['quinnvalor']	= -9,	['rammus']     = -1,
		['riven']    = -4,		['rumble']		= -4,	['sion']       = -2,	['sona']     = -5,		['syndra']		= -2,	['teemo']      = -2,
		['twitch']   = -1,		['tryndamere']  = -1,	['urgot']      = -2,	['velkoz']   = -19,		['volibear'] 	= -2,	['vi']         = -1,
		['xerath']   = -2,		['yasuo'] 		= -4,	['zac']        = -1,	['alistar']  = -4,  	['annie']       = -4,  	['blitzcrank'] = -4,
		['brand']    = -3,   	['cassiopeia']  = -2, 	['darius']     = -2,	['drmundo']  =  1,  	['galio']       =  1,  	['garen']      =  1,
		['jarvaniv'] =  2,  	['jax']         = -4,   ['lux']        = -4,	['lucian']   = -4,  	['kayle']       = -5,  	['tristana']   = -3,
		['malzahar'] = -2,  	['missfortune'] = -4,   ['morgana']    = -2,	['nunu']     = -2,      ['renekton']    = -2,	['soraka']     = -5,
		['ryze']     = -3,      ['shen']		= -4,	['shyvana']    = -1,	['swain']    = -3,		['trundle']     =  4,   ['xinzhao']    =  7,
		['ziggs']    = -3,		['zilean']      = -2,	['braum']      = -3,	['corki']    = -4,		['viktor']      = -3,	['azir']       = -4,
		['kalista']  = -4,		['bard'] 		= -6,
	}
	self.DynamicHealthBars = {
		['swain'] = true, ['shyvana'] = true, ['sion'] = true, ['quinn'] = true, ['reksai'] = true, ['renekton'] = true, ['nidalee'] = true, ['nasus'] = true, ['jayce'] = true, ['gnar'] = true, ['chogath'] = true, ['elise'] = true,
	}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies+1] = {
				['hero'] = hero,
				['sum1'] = self.SkillText[hero:GetSpellData(SUMMONER_1).name:lower()],
				['sum2'] = self.SkillText[hero:GetSpellData(SUMMONER_2).name:lower()],
			}
			if self.DynamicHealthBars[hero.charName:lower()] then
				self.HPBarOffsets[hero.networkID] = function() return ((GetUnitHPBarOffset(hero).y - 0.5) * 45) + (self.HeroOffsets[hero.charName:lower()] or 0) end
			else
				local offset = ((GetUnitHPBarOffset(hero).y - 0.5) * 45) + (self.HeroOffsets[hero.charName:lower()] or 0)
				self.HPBarOffsets[hero.networkID] = function() return offset end
			end
		elseif hero ~= myHero then
			self.Allies[#self.Allies+1] = {
				['hero'] = hero,
				['sum1'] = self.SkillText[hero:GetSpellData(SUMMONER_1).name:lower()],
				['sum2'] = self.SkillText[hero:GetSpellData(SUMMONER_2).name:lower()],
			}		
		end
	end
	self.AllyHud = {
		['xLeft']   	= floor((29  * (WINDOW_H / 1080))  * GlobalScale),
		['xRight']  	= floor((51  * (WINDOW_H / 1080))  * GlobalScale),
		['yUp']     	= floor((102 * (WINDOW_H / 1080)) * GlobalScale),
		['size']    	= floor((42  * (WINDOW_H / 1080))  * GlobalScale),
		['skill']   	= floor((13  * (WINDOW_H / 1080))  * GlobalScale),
		['lineOffset'] 	= floor(((8  * (WINDOW_H / 1080))  * GlobalScale) / 2),
	}
	self.sM = self:Menu()
	AddDrawCallback(function() self:Draw() end)
	loadMsg = loadMsg..'CDTracker, '
end

function SKILLS:Menu()
	MainMenu:addSubMenu('Cooldown Tracker', 'CooldownTracker')
	local sM = MainMenu.CooldownTracker
	sM:addParam('Enemy', 'Enable Enemy Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)	
	sM:addParam('Ally', 'Enable Ally Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)
	sM:addParam('Text', 'Enable Cooldown Text', SCRIPT_PARAM_ONOFF, true)
	return sM
end

function SKILLS:Draw()
	if self.sM.Enemy then
		for _, info in ipairs(self.Enemies) do
			local enemy = info.hero
			if enemy.valid and enemy.visible and not enemy.dead then
				local barData = self:BarData(enemy)
				if OnScreen(barData.x, barData.y) then
					for i=_Q, SUMMONER_2 do
						local data = enemy:GetSpellData(i)
						if i<=_R then
							local x = barData.x-27+(i*22)
							local y = barData.y+44
							if data.level > 0 then
								if data.currentCd ~= 0 then
									local cd = ceil(data.cd-(data.cd-data.currentCd))
									DrawLine(x, y, x+((cd / data.cd) * 21), y, 12, COLOR_ORANGE)
									DrawLine(x+((cd / data.cd) * 21), y, x+21, y, 12, COLOR_GREY)
									if self.sM.Text then
										local text = tostring(cd)
										local tA = GetTextArea(text, 14)
										DrawText(text, 14, x + 11 - (tA.x / 2), y - (tA.y / 2), COLOR_WHITE)
									end
								else
									DrawLine(x,y,x+21,y,12,COLOR_GREEN)							
								end
							else
								DrawLine(x,y,x+21,y,12,COLOR_GREY)							
							end
							DrawLines2({D3DXVECTOR2(x, y-6), D3DXVECTOR2(x, y+6), D3DXVECTOR2(x+21, y+6), D3DXVECTOR2(x+21, y-6)}, 2, COLOR_TRANS_WHITE)						
						else
							local x = barData.x-27+((i-4)*44) - ((i-4)*1)
							local y = barData.y+47
							if data.currentCd ~= 0 then
								local cd = ceil(data.cd-(data.cd-data.currentCd))
								DrawLine(x, y+11, x+((cd / data.cd) * 44), y+11, 12, COLOR_ORANGE)
								DrawLine(x+((cd / data.cd) * 44), y+11, x+44, y+11, 12, COLOR_GREY)
							else
								DrawLine(x, y+11, x+44, y+11, 12, COLOR_GREEN)								
							end
							DrawLines2({D3DXVECTOR2(x, y+5), D3DXVECTOR2(x, y+17), D3DXVECTOR2(x+44, y+17), D3DXVECTOR2(x+44, y+5), D3DXVECTOR2(x, y+5),}, 2, COLOR_TRANS_WHITE)
							local text = info['sum'..(i-3)]
							local tA = GetTextArea(text, 11)
							if self.sM.Text then
								DrawText(text, 11, x + 22 - (tA.x / 2), y + 11 - (tA.y / 2), COLOR_WHITE)
							end
						end
					end
				end
			end
		end
	end
	if self.sM.Ally then
		for i, info in ipairs(self.Allies) do
			if info.hero.valid then
				for j=_R, SUMMONER_2 do
					local data = info.hero:GetSpellData(j)
					local y = ((j - 3) * self.AllyHud.skill) + (self.AllyHud.yUp + (self.AllyHud.size * (i - 1)))
					local rSize = ((y + self.AllyHud.lineOffset) - (y - self.AllyHud.lineOffset))
					local Lines = {
						D3DXVECTOR2(self.AllyHud.xLeft,  y + self.AllyHud.lineOffset), 
						D3DXVECTOR2(self.AllyHud.xRight, y + self.AllyHud.lineOffset),
						D3DXVECTOR2(self.AllyHud.xRight, y - self.AllyHud.lineOffset),
						D3DXVECTOR2(self.AllyHud.xLeft,  y - self.AllyHud.lineOffset),
						D3DXVECTOR2(self.AllyHud.xLeft,  y + self.AllyHud.lineOffset),
					}
					local offset = floor(GlobalScale*0.75)
					DrawLines2(Lines, 1+offset, COLOR_TRANS_WHITE)
					if data.currentCd == 0 then
						DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xRight, y, rSize, COLOR_TRANS_GREEN)
					else
						local cd = data.currentCd/data.cd
						DrawLine(self.AllyHud.xLeft + offset, y, self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, rSize, COLOR_ORANGE)
						DrawLine(self.AllyHud.xLeft + ((self.AllyHud.xRight - self.AllyHud.xLeft) * cd), y, self.AllyHud.xRight, y, rSize, COLOR_GREY)				
					end
					if j ~= _R and self.sM.Text then
						local text = info['sum'..j-3]
						local tA = GetTextArea(text, rSize-4)
						local cX = (self.AllyHud.xLeft + self.AllyHud.xRight) / 2
						local cY = (y + y) / 2
						DrawText(text, rSize-4, cX - (tA.x / 2), cY - (tA.y / 2), COLOR_WHITE)
					end
				end
			end
		end
	end
end

function SKILLS:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	return {['x'] = barPos.x - 38, ['y'] = floor(barPos.y + self.HPBarOffsets[enemy.networkID]()),}
end

class 'TIMERS'

function TIMERS:__init()
	self.map = GetGame().map.shortName
	if self.map == 'summonerRift' then 
		AddApplyBuffCallback(function(s,u,b) self:ApplyBuff(s,u,b) end)
	end
	self.Packets = {
		[1] = { --5.13
			['Jungle'] = { ['Header'] = 0x011D, ['campPos'] = 10, ['idPos'] = 6,},
			['Inhibitor'] = { ['Header'] = 0x00A1, ['pos'] = 2, },
			['Dragon'] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  },
			['Baron'] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), },
			['summonerRift'] = {
				[0xD5] = { ['pos'] =  Vector(3850, 60, 7880), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
				[0xC5] = { ['pos'] =  Vector(3800, 60, 6500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
				[0xB5] = { ['pos'] =  Vector(7000, 60, 5400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
				[0xA5] = { ['pos'] =  Vector(7800, 60, 4000), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
				[0xE4] = { ['pos'] =  Vector(8400, 60, 2700), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
				[0xD4] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  }, --Dragon
				[0xC4] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
				[0xB4] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves
				[0xE0] = { ['pos'] =  Vector(7850, 60, 9500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
				[0xD0] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
				[0xC0] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
				[0xB0] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
				[0xDC] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
				[0xCC] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
				[0xBC] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
				[0xAC] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
				[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
				[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
				[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
				[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
				[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
				[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor			
			},
			['twistedTreeline'] = {
				[0xD5] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
				[0xC5] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
				[0xB5] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
				[0xA5] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
				[0xE4] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
				[0xD4] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
				[0xC4] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
				[0xB4] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
				[0xFF9303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
				[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
				[0xFF6793D0] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
				[0xFF26AC0F] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor		
			},
			['howlingAbyss'] = {
				[0xD5] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
				[0xC5] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
				[0xB5] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
				[0xE4] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
				[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
				[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
			},
			['crystalScar'] = {
				[0x67] = { ['pos'] = Vector(4948, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4948, -100, 9329)),  }, 
				[0xA2] = { ['pos'] = Vector(8972, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(8972, -100, 9329)),  }, 
				[0x6A] = { ['pos'] = Vector(6949, -100, 2855),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6949, -100, 2855)),  },
				[0x6E] = { ['pos'] = Vector(6947, -100, 12116), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6947, -100, 12116)), },
				[0x9A] = { ['pos'] = Vector(12881, -100, 8294), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(12881, -100, 8294)), },
				[0x9E] = { ['pos'] = Vector(10242, -100, 1519), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(10242, -100, 1519)), },
				[0x8E] = { ['pos'] = Vector(3639, -100, 1490),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(3639, -100, 1490)),  },
				[0x7E] = { ['pos'] = Vector(1027, -100, 8288),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(1027, -100, 8288)),  },
				[0x8A] = { ['pos'] = Vector(4324, -100, 5500),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4324, -100, 5500)),  },
				[0x7A] = { ['pos'] = Vector(9573, -100, 5530),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(9573, -100, 5530)),  },			
			},
		},
		[2] = { --HOPEFULLY 5.12
			['Jungle'] = { ['Header'] = 0x0060, ['campPos'] = 10, ['idPos'] = 6,},
			['Inhibitor'] = { ['Header'] = 0x0099, ['pos'] = 2, },
			['Dragon'] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  },
			['Baron'] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, 
			['summonerRift'] = {
				[0x4A] = { ['pos'] =  Vector(3850, 60, 7880), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
				[0x9F] = { ['pos'] =  Vector(3800, 60, 6500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
				[0xC3] = { ['pos'] =  Vector(7000, 60, 5400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
				[0x1F] = { ['pos'] =  Vector(7800, 60, 4000), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
				[0x71] = { ['pos'] =  Vector(8400, 60, 2700), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
				[0x84] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  }, --Dragon
				[0xB0] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
				[0xEB] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves
				[0x98] = { ['pos'] =  Vector(7850, 60, 9500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
				[0xE5] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
				[0xBA] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
				[0x41] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
				[0xA9] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
				[0x36] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
				[0xA2] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
				[0x1A] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
				[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
				[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
				[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
				[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
				[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
				[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
			},
			['twistedTreeline'] = {
				[0x4A] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
				[0x9F] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
				[0xC3] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
				[0x1F] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
				[0x71] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
				[0x84] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
				[0xB0] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
				[0xEB] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
				[0xFF9303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
				[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
				[0xFF6793D0] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
				[0xFF26AC0F] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
			},
			['howlingAbyss'] = {
				[0x4A] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
				[0x9F] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
				[0xC3] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
				[0x1F] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
				[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
				[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
			},
			['crystalScar'] = {
				[0xE4] = { ['pos'] = Vector(4948, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4948, -100, 9329)),  }, 
				[0x85] = { ['pos'] = Vector(8972, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(8972, -100, 9329)),  }, 
				[0xE0] = { ['pos'] = Vector(6949, -100, 2855),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6949, -100, 2855)),  },
				[0x6E] = { ['pos'] = Vector(6947, -100, 12116), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6947, -100, 12116)), },
				[0xF9] = { ['pos'] = Vector(12881, -100, 8294), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(12881, -100, 8294)), },
				[0xD7] = { ['pos'] = Vector(10242, -100, 1519), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(10242, -100, 1519)), },
				[0x32] = { ['pos'] = Vector(3639, -100, 1490),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(3639, -100, 1490)),  },
				[0x8B] = { ['pos'] = Vector(1027, -100, 8288),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(1027, -100, 8288)),  },
				[0xD3] = { ['pos'] = Vector(4324, -100, 5500),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4324, -100, 5500)),  },
				[0xB1] = { ['pos'] = Vector(9573, -100, 5530),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(9573, -100, 5530)),  },			
			},
		},
	}	
	self.activeTimers = {}
	self.checkLastDragon = false
	self.checkLastBaron = false
	self.tM = self:Menu()
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
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
	--for k, v in pairs(self.Packets[1].summonerRift) do
	--	DrawText3D(('0x%02X'):format(k),v.pos.x,v.pos.y,v.pos.z,22,ARGB(255,255,255,255))
	--end
	
	if not self.tM.draw then return end
	for i, info in ipairs(self.activeTimers) do
		local timer = info.spawnTime-clock()
		local text = (self.tM.type == 1) and ('%d'):format(timer) or ('%d:%.2d'):format(timer/60, timer%60)
		DrawText3D(text, info.pos.x, info.pos.y, (info.pos.z-50), self.tM.size, ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4]))
		DrawText(text, self.tM.mapsize, info.minimap.x-5, info.minimap.y-5, ARGB(self.tM.mapRGB[1], self.tM.mapRGB[2], self.tM.mapRGB[3], self.tM.mapRGB[4]))
		if timer <= 1 then 
			table.remove(self.activeTimers,i)
		end
	end
end

function TIMERS:ApplyBuff(s,u,b)
	if u.valid and u.team == TEAM_ENEMY and u.type == 'AIHeroClient' then
		if b.name:find('dragonslayerbuff') then
			for i, timer in ipairs(self.activeTimers) do
				if timer.pos == self.Packets[MainMenu.version].Dragon.pos then
					table.remove(self.activeTimers, i)
				end
			end
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = b.startTime + 360 + (clock() - GetGameTimer()), 
				['pos'] = self.Packets[MainMenu.version].Dragon.pos, 
				['minimap'] = self.Packets[MainMenu.version].Dragon.mapPos,
				['valid'] = true,
			}
		elseif b.name:lower():find('exaltedwithbaronnashor') then
			for i, timer in ipairs(self.activeTimers) do
				if timer.pos == self.Packets[MainMenu.version].Baron.pos then
					table.remove(self.activeTimers, i)
				end
			end
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = b.startTime + 410 + (clock() - GetGameTimer()), 
				['pos'] = self.Packets[MainMenu.version].Baron.pos, 
				['minimap'] = self.Packets[MainMenu.version].Baron.mapPos,
				['valid'] = true,
			}			
		end
	end
end

function TIMERS:RecvPacket(p)
	if p.header == self.Packets[MainMenu.version].Jungle.Header then
		p.pos = self.Packets[MainMenu.version].Jungle.campPos
		local camp = p:Decode1()
		--print(('0x%02X'):format(camp))
		if self.Packets[MainMenu.version][self.map][camp] then
			p.pos = self.Packets[MainMenu.version].Jungle.idPos
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[MainMenu.version][p:Decode1()]
			end
			local o = objManager:GetObjectByNetworkId(DwordToFloat(bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))))
			if not o then return end
			for i, timer in ipairs(self.activeTimers) do
				if timer.pos == self.Packets[MainMenu.version][self.map][camp].pos then
					table.remove(self.activeTimers, i)
				end
			end
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets[MainMenu.version][self.map][camp].time, 
				['pos'] = self.Packets[MainMenu.version][self.map][camp].pos, 
				['minimap'] = self.Packets[MainMenu.version][self.map][camp].mapPos,
				['valid'] = true,
			}
		end
		return
	end
	if p.header == self.Packets[MainMenu.version].Inhibitor.Header then
		p.pos=self.Packets[MainMenu.version].Inhibitor.pos
		local inhib = p:Decode4()
		if self.Packets[MainMenu.version][self.map][inhib] then
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets[MainMenu.version][self.map][inhib].time, 
				['pos'] = self.Packets[MainMenu.version][self.map][inhib].pos, 
				['minimap'] = self.Packets[MainMenu.version][self.map][inhib].mapPos,
			}
		end
		return
	end
end

function TIMERS:WndMsg(m,k)
	if m == 513 and k == 1 and IsKeyDown(self.tM._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for _, info in pairs(self.Packets[MainMenu.version][self.map]) do
			if _ <= 0xFF then
				local miniMap = info.mapPos
				if abs(cP.x-miniMap.x) < 17 and abs(cP.y-miniMap.y) < 17 then
					for i, timer in ipairs(self.activeTimers) do
						if timer.pos == info.pos then
							if timer.valid then return end
							table.remove(self.activeTimers, i)					
						end
					end
					self.activeTimers[#self.activeTimers + 1] = {
						['spawnTime'] = clock()+info.time, 
						['pos'] = info.pos, 
						['minimap'] = info.mapPos,
						['valid'] = false,
					}
					return
				end
			end
		end
	end
end

class 'OTHER'

function OTHER:__init()
	self.Turrets = {}
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and obj.type == 'obj_AI_Turret' and obj.team == TEAM_ENEMY and obj.name:find('Shrine') == nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	self.Enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies+1] = h	
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
		for i, turret in ipairs(self.Turrets) do
			if turret and turret.valid and not turret.dead then
				local c = WorldToScreen(D3DXVECTOR3(turret.x, turret.y, turret.z))
				if c.x > -300 and c.x < WINDOW_W + 200 and c.y > -300 and c.y < WINDOW_H + 300 then
					local quality =  pi2 / 28
					local points = {}
					for theta = 0, pi2 + quality, quality do
						local c2 = WorldToScreen(D3DXVECTOR3(turret.x + 850 * cos(theta), turret.y, turret.z - 850 * sin(theta)))
						points[#points + 1] = D3DXVECTOR2(c2.x, c2.y)
					end
					DrawLines2(points, 2, COLOR_RED)
				end
			else
				table.remove(self.Turrets, i)
			end
		end
	end
	if self.oM.path then
		for _, e in ipairs(self.Enemies) do
			if e and e.valid and not e.dead and e.visible and e.pathCount > 1 then
				local points = {}
				local eC = WorldToScreen(D3DXVECTOR3(e.x, e.y, e.z))
				points[1] = D3DXVECTOR2(eC.x, eC.y)
				local pathLength = 0
				for i=e.pathIndex, e.pathCount do
					local p1 = e:GetPath(i)
					local p2 = e:GetPath(i-1)
					if p1 then
						local c = WorldToScreen(D3DXVECTOR3(p1.x, p1.y, p1.z))
						points[#points + 1] = D3DXVECTOR2(c.x, c.y)
						if p2 then
							if (i==e.pathIndex) then
								pathLength = pathLength + GetDistanceSqr(p1, e.pos)
							else
								pathLength = pathLength + GetDistanceSqr(p1, p2)
							end
						end
					end
				end			
				if self.oM.type == 1 then
					local draw = false
					for i, point in ipairs(points) do
						if point.x > 0 and point.x < WINDOW_W and point.y > 0 and point.y < WINDOW_H then
							draw = true
							break
						end
					end
					if draw then
						DrawLines2(points, 2, COLOR_RED)
						DrawText3D(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, COLOR_WHITE)
					end
				else
					local x, y = points[#points].x, points[#points].y
					if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
						DrawText3D(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName, e.endPath.x, e.endPath.y, e.endPath.z, 12, COLOR_WHITE)
					end
				end
			end
		end
	end
end

class 'TRINKET'

function TRINKET:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end
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
	self.Packets = {
		[1] = {
			['Send'] = { ['Header'] = 0x0008, ['vTable'] = 0xEAC648, ['hash'] = 0xE1240DFD, },
			['Recv'] = { ['Header'] = 0x005C, ['pos'] = 2, ['pos2'] = 12, },		
		},
		[2] = {
			['Send'] = { ['Header'] = 0x0042, ['vTable'] = 0xE810FC, ['hash'] = 0xE1240DFD, },
			['Recv'] = { ['Header'] = 0x0085, ['pos'] = 2, ['pos2'] = 10, },		
		},
	}
	self.trM = self:Menu()
	if self.trM.ward and clock()/60 < 1.1 then 
		DelayAction(
		function() 
			if myHero:GetSpellData(ITEM_7).name == '' then
				self:BuyItem(3339+self.trM.type) 
			end
		end, 5)
	end
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
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
	for i=0, 255 do rB[IDBytes[MainMenu.version][i]] = i end
	local p = CLoLPacket(self.Packets[MainMenu.version].Send.Header)
	p.vTable = self.Packets[MainMenu.version].Send.vTable
	p:EncodeF(myHero.networkID)
	local b1 = lshift(band(rB[band(rshift(band(id,0xFFFF),24),0xFF)],0xFF),24)
	local b2 = lshift(band(rB[band(rshift(band(id,0xFFFFFF),16),0xFF)],0xFF),16)
	local b3 = lshift(band(rB[band(rshift(band(id,0xFFFFFFFF),8),0xFF)],0xFF),8)
	local b4 = band(rB[band(id ,0xFF)],0xFF)
	p:Encode4(bxor(b1,b2,b3,b4))
	p:Encode4(self.Packets[MainMenu.version].Send.hash)
	SendPacket(p)
end

function TRINKET:RecvPacket(p)
	if p.header == self.Packets[MainMenu.version].Recv.Header then
		p.pos=self.Packets[MainMenu.version].Recv.pos
		if p:DecodeF() == myHero.networkID then
			p.pos=self.Packets[MainMenu.version].Recv.pos2
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[MainMenu.version][p:Decode1()]
			end
			local itemID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
			local currentTrinket = myHero:GetSpellData(ITEM_7)
			if not currentTrinket then return end
			local gameTime = clock()/60
			if self.trM.sweeper and self.trinketID[currentTrinket.name] == 3340 and gameTime >= self.trM.timer then
				self:BuyItem(3341)
				return
			end
			if (self.trinketID[currentTrinket.name] == 3340 or self.trinketID[currentTrinket.name] == 3341) and self.trM.scryorb and gameTime >= self.trM.timer2 then
				self:BuyItem(3342)
				return
			end
			if self.trM.sightstone and itemID == 2049 then
				if self.trinketID[currentTrinket.name] == 3340 then
					self:BuyItem(3341)
					return
				end
			end
		end
	end
end
