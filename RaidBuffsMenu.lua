RaidBuffs = RaidBuffs or {}
local RaidBuffs = RaidBuffs

function RaidBuffs.buildMenu(svdefaults)
	local LAM = LibStub("LibAddonMenu-2.0")
	local def = svdefaults
	local trackingPresets = {
		"Full",
		"Dps",
		"Tank",
		"Healer"
	}
	-- local names = { }
	-- for k,v in pairs(RaidBuffs.debuffsMaster) do
	-- 	table.insert(names, k.name)
	-- end
	-- d(names)
	
	local panelData = {
		type = "panel",
		name = RaidBuffs.name,
		displayName = RaidBuffs.name,
		author = "Wheels",
		version = ""..RaidBuffs.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(RaidBuffs.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Allows for positioning of UI",
			warning = "Will automatically ReloadUI when locked",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(RaidBuffs.name, EVENT_RETICLE_HIDDEN_UPDATE)
					RaidBuffs.frames[1]:SetHidden(false)
					RaidBuffs.frames[1]:SetMovable(true)
					RaidBuffs.frames[1]:SetMouseEnabled(true)
				else
					ReloadUI()
				end
			end,
			requiresReload = true
					
		},
		{
			type = "header",
			name = "General Options"
		},
		{
			type = "dropdown",
			name = "Growth Direction",
			tooltip = "Determines which direction additional boss frames are placed in",
			default = def.growthDir,
			choices = RaidBuffs.GROWTH,
			sort = "name-up",
			getFunc = function() return RaidBuffs.savedVariables.growthDir end,
			setFunc = function(value)
				if value == RaidBuffs.savedVariables.growthDir then return end
				for i = 1, #RaidBuffs.GROWTH do
					if value == RaidBuffs.GROWTH[i] then
						RaidBuffs.savedVariables.growthDir = value
					end
				end
			end,
			requiresReload = true
		},
		{
			type = "dropdown",
			name = "Tracking Preset",
			tooltip = "Select debuff tracking preset (custom tracking coming soon)",
			default = def.trackingName,
			choices = trackingPresets,
			getFunc = function() return RaidBuffs.savedVariables.trackingName end,
			setFunc = function(value)
				if value == RaidBuffs.savedVariables.trackingName then return end
				RaidBuffs.savedVariables.tracking = { }
				RaidBuffs.savedVariables.tracking = RaidBuffs[value]
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
			end,
		},
		{
			type = "checkbox",
			name = "Track boss HP",
			tooltip = "Toggles boss frames displaying boss HP",
			default = def.trackHealth,
			getFunc = function() return RaidBuffs.savedVariables.trackHealth end,
			setFunc = function(value)
				RaidBuffs.savedVariables.trackHealth = value
				RaidBuffs.BossUpdate()
			end
		},
	}
	
	LAM:RegisterOptionControls(RaidBuffs.name.."Options", options)
end

