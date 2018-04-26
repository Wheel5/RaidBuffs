RaidBuffs = RaidBuffs or {}
local RaidBuffs = RaidBuffs

RaidBuffs.name		= "RaidBuffs"
RaidBuffs.version	= "0.8.7a"
RaidBuffs.varVersion	= 2

RaidBuffs.bosses = { }

RaidBuffs.debug = false


RaidBuffs.X_DIM = 235
RaidBuffs.TEMPLATE = "BossFrameTemplate"
RaidBuffs.frames = { }
RaidBuffs.MAX_ROWS = 5

RaidBuffs.GROWTH = {
	[1] = "Down",
	[2] = "Up"
}

RaidBuffs.CustomAbilityName = {
	[75753] = GetAbilityName(75753),	-- Line-Breaker
	[17906] = GetAbilityName(17906),	-- Crusher
	[17945] = GetAbilityName(17945),	-- Weakening
	[62870] = GetAbilityName(62870),	-- Off Balance (to bottom)
	[62880] = GetAbilityName(62880),
	[62887] = GetAbilityName(62887),
	[62968] = GetAbilityName(62968),
	[62973] = GetAbilityName(62973),
	[62978] = GetAbilityName(62978),
	[62983] = GetAbilityName(62983),
	[62988] = GetAbilityName(62988),
	[62993] = GetAbilityName(62993),
	[62998] = GetAbilityName(62998),
	[63003] = GetAbilityName(63003),
	[70054] = GetAbilityName(70054),
	[71877] = GetAbilityName(71877),
	[72279] = GetAbilityName(72279),
	[75214] = GetAbilityName(75214),
	[96260] = GetAbilityName(96260),
	[100582] = GetAbilityName(100582),
	[100582] = GetAbilityName(100582),
}

local function GetFormattedAbilityName(id)	-- Fix to Lui conflict - thank you Solinur
	local name = RaidBuffs.CustomAbilityName[id] or zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
	return name
end

RaidBuffs.UPDATE_INTERVAL = 200

RaidBuffs.debuffsInvert = { }

RaidBuffs.debuffsMaster = {
	[GetFormattedAbilityName(75753)] = {
		name = "Alkosh",
		updated = false
	},
	[GetFormattedAbilityName(63003)] = {
		name = "Off-Balance",
		updated = false
	},
	[GetFormattedAbilityName(17906)] = {
		name = "Crusher",
		updated = false
	},
	[GetFormattedAbilityName(102771)] = {
		name = "Immunity",
		updated = false
	},
	[GetFormattedAbilityName(81519)] = {
		name = "Minor Vuln",
		updated = false
	},
	[GetFormattedAbilityName(34050)] = {
		name = "Engulfing",
		updated = false
	},
	[GetFormattedAbilityName(60416)] = {
		name = "Sunder",
		updated = false
	},
	[GetFormattedAbilityName(34384)] = {
		name = "Morag",
		updated = false
	},
	[GetFormattedAbilityName(34386)] = {
		name = "NMG",
		updated = false
	},
	[GetFormattedAbilityName(27587)] = {
		name = "PotL",
		updated = false
	},
	[GetFormattedAbilityName(88634)] = {
		name = "Lifesteal",
		updated = false
	},
	[GetFormattedAbilityName(62796)] = {
		name = "Magsteal",
		updated = false
	},
	[GetFormattedAbilityName(17945)] = {
		name = "Weakening",
		updated = false
	},
}

RaidBuffs.Full = {
	[1]	= GetFormattedAbilityName(75753),
	[2]	= GetFormattedAbilityName(63003),
	[3]	= GetFormattedAbilityName(17906),
	[4]	= GetFormattedAbilityName(102771),
	[5]	= GetFormattedAbilityName(81519),
	[6]	= GetFormattedAbilityName(34050),
	[7]	= GetFormattedAbilityName(60416),
	[8]	= GetFormattedAbilityName(34384),
	[9]	= GetFormattedAbilityName(34386),
	[10]	= GetFormattedAbilityName(27587)
}

RaidBuffs.Healer = {
	[1]	= GetFormattedAbilityName(62796),
	[2]	= GetFormattedAbilityName(63003),
	[3]	= GetFormattedAbilityName(88634),
	[4]	= GetFormattedAbilityName(102771),
	[5]	= GetFormattedAbilityName(81519)
}

RaidBuffs.Tank = {
	[1]	= GetFormattedAbilityName(75753),
	[2]	= GetFormattedAbilityName(34050),
	[3]	= GetFormattedAbilityName(17906)
}

RaidBuffs.Dps = {
	[1]	= GetFormattedAbilityName(63003),
	[2]	= GetFormattedAbilityName(102771),
	[3]	= GetFormattedAbilityName(60416),
	[4]	= GetFormattedAbilityName(34384),
	[5]	= GetFormattedAbilityName(34386),
	[6]	= GetFormattedAbilityName(27587)
}

RaidBuffs.defaults = {
	["OffsetX"] = 400,
	["OffsetY"] = 400,
	["tracking"] = { },
	["Custom"] = { },
	["numTracked"] = 10,
	["numCustom"] = 0,
	["trackingName"] = "Full",
	["growthDir"] = RaidBuffs.GROWTH[1],
	["currRows"] = 5,
	["trackHealth"] = true
}

-- Important Buffs:
-- The Morag Tong:	34384
-- Night Mother's Gaze: 34386
-- Sunderflame:		60416
-- Crusher:		17906
-- Alkosh:		75753
-- Minor Vulnerability:	81519
-- Power of the Light:	27587
-- Off-Balance:		63003
-- OB Immunity:		102771
-- Engulfing:		34050


function RaidBuffs.Init()

	for i = 1, MAX_BOSSES do
		RaidBuffs.bosses[i] = false
	end

	EVENT_MANAGER:RegisterForEvent(RaidBuffs.name, EVENT_BOSSES_CHANGED, RaidBuffs.BossUpdate)
	EVENT_MANAGER:RegisterForEvent(RaidBuffs.name, EVENT_PLAYER_ACTIVATED, RaidBuffs.BossUpdate)
	EVENT_MANAGER:RegisterForEvent(RaidBuffs.name, EVENT_RETICLE_HIDDEN_UPDATE, RaidBuffs.reticleChange)
	RaidBuffs.savedVariables = ZO_SavedVars:New("RBSavedVariables", RaidBuffs.varVersion, nil, RaidBuffs.defaults)

	local empty = true
	for _,_ in pairs(RaidBuffs.savedVariables.tracking) do
		empty = false
		break
	end
	if empty then RaidBuffs.savedVariables.tracking = RaidBuffs.Full end

	for k, v in pairs(RaidBuffs.savedVariables.tracking) do
		RaidBuffs.debuffsInvert[v] = k
	end

	RaidBuffs.buildMenu(RaidBuffs.defaults)

	RaidBuffs.setPosition()
	RaidBuffs.BossUpdate()
end

function RaidBuffs.OnMoveStop()
	RaidBuffs.savedVariables.OffsetX = RaidBuffs.frames[1]:GetLeft()
	RaidBuffs.savedVariables.OffsetY = RaidBuffs.frames[1]:GetTop()
end

function RaidBuffs.setPosition()
	local x, y = RaidBuffs.savedVariables.OffsetX, RaidBuffs.savedVariables.OffsetY
	RaidBuffs.spawnFrame("BossFrame1", 1)
	RaidBuffs.frames[1]:ClearAnchors()
	RaidBuffs.frames[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function RaidBuffs.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function RaidBuffs.setupCustom(value)
	RaidBuffs.savedVariables.tracking = { }
	RaidBuffs.savedVariables.tracking = RaidBuffs.savedVariables.Custom
	RaidBuffs.debuffsInvert = { }
	for k, v in pairs(RaidBuffs.savedVariables.tracking) do RaidBuffs.debuffsInvert[v] = k end
	RaidBuffs.savedVariables.trackingName = value
	RaidBuffs.savedVariables.numTracked = #RaidBuffs.savedVariables.tracking
	RaidBuffs.savedVariables.currRows = math.ceil(#RaidBuffs.savedVariables.tracking / 2)
	for i = 1, MAX_BOSSES do	-- Appears redundant, easier than making new function for the time being
		if RaidBuffs.frames[i] ~= nil then
			RaidBuffs.frames[i].bossName:SetText('')
			for j = 1, RaidBuffs.MAX_ROWS do
				RaidBuffs.frames[i].rows[j].buffName1:SetText('')
				RaidBuffs.frames[i].rows[j].buffTime1:SetText('')
				RaidBuffs.frames[i].rows[j].buffName2:SetText('')
				RaidBuffs.frames[i].rows[j].buffTime2:SetText('')
			end
		end
	end
	RaidBuffs.BossUpdate()
end

function RaidBuffs.reticleChange(event, hidden)
	local h = hidden or true
	for i = 1, MAX_BOSSES do
		if RaidBuffs.frames[i] ~= nil and DoesUnitExist('boss'..i) then
			RaidBuffs.frames[i]:SetHidden(hidden)
		end
	end
end

function RaidBuffs.spawnFrame(frameName, num)
	if num > 2 and RaidBuffs.frames[num - 1] == nil then	-- in case you encounter bossX before bossX-1
		RaidBuffs.spawnFrame("BossFrame"..num-1, num-1)
	end
	local dir = RaidBuffs.savedVariables.growthDir
	local currRows = RaidBuffs.savedVariables.currRows
	RaidBuffs.frames[num] = WINDOW_MANAGER:CreateControlFromVirtual(frameName, GuiRoot, RaidBuffs.TEMPLATE)
	RaidBuffs.frames[num].rows = {}
	RaidBuffs.frames[num].bossName = RaidBuffs.frames[num]:GetNamedChild("BossName")
	RaidBuffs.frames[num].bossHealth = RaidBuffs.frames[num]:GetNamedChild("BossHealth")
	for i = 1, RaidBuffs.MAX_ROWS do
		RaidBuffs.frames[num].rows[i] = RaidBuffs.frames[num]:GetNamedChild("Row"..i)
		RaidBuffs.frames[num].rows[i].buffName1 = RaidBuffs.frames[num].rows[i]:GetNamedChild("BuffName1")
		RaidBuffs.frames[num].rows[i].buffTime1 = RaidBuffs.frames[num].rows[i]:GetNamedChild("BuffTime1")
		RaidBuffs.frames[num].rows[i].buffName2 = RaidBuffs.frames[num].rows[i]:GetNamedChild("BuffName2")
		RaidBuffs.frames[num].rows[i].buffTime2 = RaidBuffs.frames[num].rows[i]:GetNamedChild("BuffTime2")
	end
	RaidBuffs.frames[num]:SetDimensions(RaidBuffs.X_DIM, (currRows * 18 + 24))
	if num ~= 1 then
		RaidBuffs.frames[num]:ClearAnchors()
		if dir == RaidBuffs.GROWTH[1] then
			RaidBuffs.frames[num]:SetAnchor(TOPLEFT, RaidBuffs.frames[num - 1], BOTTOMLEFT, 0, 3)
		elseif dir == RaidBuffs.GROWTH[2] then
			RaidBuffs.frames[num]:SetAnchor(BOTTOMLEFT, RaidBuffs.frames[num - 1], TOPLEFT, 0, -3)
		end
	end
end

function RaidBuffs.BossUpdate()
	local trackedBuffs = RaidBuffs.savedVariables.tracking
	local currRows = RaidBuffs.savedVariables.currRows
	for i = 1, MAX_BOSSES do
		if DoesUnitExist("boss"..i) then
			if RaidBuffs.frames[i] == nil then
				RaidBuffs.spawnFrame("BossFrame"..i, i)
			end
			RaidBuffs.frames[i]:SetDimensions(RaidBuffs.X_DIM, (currRows * 18 + 24))
			RaidBuffs.frames[i].bossName:SetText(GetUnitName('boss'..i))
			local row = 1
			for j = 1, RaidBuffs.savedVariables.numTracked do
				if j % 2 ~= 0 then
			 		RaidBuffs.frames[i].rows[row].buffName1:SetText(RaidBuffs.debuffsMaster[trackedBuffs[j]].name..":")
			 		RaidBuffs.frames[i].rows[row].buffTime1:SetText("0.0")
				elseif j % 2 == 0 then
			 		RaidBuffs.frames[i].rows[row].buffName2:SetText(RaidBuffs.debuffsMaster[trackedBuffs[j]].name..":")
			 		RaidBuffs.frames[i].rows[row].buffTime2:SetText("0.0")
					row = row + 1
				end
			end
			RaidBuffs.frames[i].bossHealth:SetText('')
			RaidBuffs.frames[i]:SetHidden(IsReticleHidden())
			RaidBuffs.bosses[i] = true
		else
			if RaidBuffs.frames[i] ~= nil then
				RaidBuffs.frames[i]:SetHidden(true)
				RaidBuffs.frames[i].bossName:SetText('')
				for j = 1, RaidBuffs.MAX_ROWS do
					RaidBuffs.frames[i].rows[j].buffName1:SetText('')
					RaidBuffs.frames[i].rows[j].buffTime1:SetText('')
					RaidBuffs.frames[i].rows[j].buffName2:SetText('')
					RaidBuffs.frames[i].rows[j].buffTime2:SetText('')
				end
				RaidBuffs.bosses[i] = false
			end
		end
	end
	for i = 1, MAX_BOSSES do
		if RaidBuffs.bosses[i] then
			EVENT_MANAGER:RegisterForUpdate(RaidBuffs.name..'Update', RaidBuffs.UPDATE_INTERVAL, RaidBuffs.buffUpdate)
			break
		elseif i == 6 and not RaidBuffs.bosses[i] then
			EVENT_MANAGER:UnregisterForUpdate(RaidBuffs.name..'Update')
		end
	end
end

function RaidBuffs.buffUpdate()
	for i = 1, MAX_BOSSES do
		if RaidBuffs.bosses[i] then
			local numBuffs = GetNumBuffs('boss'..i)
			local current, max, effectiveMax = GetUnitPower("boss"..i, POWERTYPE_HEALTH)
			local health = math.floor((current/max*100) + 0.5)
			if RaidBuffs.savedVariables.trackHealth then
				local healthValue = health*2/100	-- ty Marc!
				local red = (health > 50 and 2 - healthValue) or 1
				local green = (health < 50 and healthValue) or 1
				RaidBuffs.frames[i].bossHealth:SetText(health..'%')
				RaidBuffs.frames[i].bossHealth:SetColor(red, green, 0)
			end
			
			for j = 1, numBuffs do
				local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo('boss'..i, j)
				local data = RaidBuffs.debuffsMaster[GetFormattedAbilityName(abilityId)]
				if data and RaidBuffs.debuffsInvert[GetFormattedAbilityName(abilityId)] then
					RaidBuffs.debuffsMaster[GetFormattedAbilityName(abilityId)].updated = true
					local buffNum = RaidBuffs.debuffsInvert[GetFormattedAbilityName(abilityId)]
					local row = math.ceil(buffNum/2)
					if buffNum % 2 ~= 0 then
						RaidBuffs.frames[i].rows[row].buffTime1:SetText(string.format('%.1f', RaidBuffs.time(timeEnding)))
					else
						RaidBuffs.frames[i].rows[row].buffTime2:SetText(string.format('%.1f', RaidBuffs.time(timeEnding)))
					end
				end
			end
			for k,v in pairs(RaidBuffs.debuffsMaster) do
				local buffNum = RaidBuffs.debuffsInvert[k]
				local row
				if buffNum ~= nil then
					row = math.ceil(buffNum/2)
					if v.updated and k ~= GetFormattedAbilityName(102771) then
						if buffNum and buffNum % 2 ~= 0 then
							RaidBuffs.frames[i].rows[row].buffName1:SetColor(0, 1, 0)
						elseif buffNum and buffNum % 2 == 0 then
							RaidBuffs.frames[i].rows[row].buffName2:SetColor(0, 1, 0)
						end
						v.updated = false
					elseif v.updated and k == GetFormattedAbilityName(102771) then
						if buffNum and buffNum % 2 ~= 0 then
							RaidBuffs.frames[i].rows[row].buffName1:SetColor(1, 0, 0)
						elseif buffNum and buffNum % 2 == 0 then
							RaidBuffs.frames[i].rows[row].buffName2:SetColor(1, 0, 0)
						end
						v.updated = false
					elseif not v.updated then
						if buffNum and buffNum % 2 ~= 0 then
							RaidBuffs.frames[i].rows[row].buffName1:SetColor(1, 1, 1)
							RaidBuffs.frames[i].rows[row].buffTime1:SetText('0.0')
						elseif buffNum and buffNum % 2 == 0 then
							RaidBuffs.frames[i].rows[row].buffName2:SetColor(1, 1, 1)
							RaidBuffs.frames[i].rows[row].buffTime2:SetText('0.0')
						end
					end
				end
			end
		end
	end
end

function RaidBuffs.onAddonLoaded(event, addonName)
	if addonName ~= RaidBuffs.name then return end
	EVENT_MANAGER:UnregisterForEvent(RaidBuffs.name, EVENT_ADD_ON_LOADED)
	RaidBuffs.Init()
end

EVENT_MANAGER:RegisterForEvent(RaidBuffs.name, EVENT_ADD_ON_LOADED, RaidBuffs.onAddonLoaded)
