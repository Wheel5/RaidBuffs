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
				if value == RaidBuffs.savedVariables.trackingName then
					return
				end
				RaidBuffs.savedVariables.tracking = RaidBuffs[value]
				RaidBuffs.savedVariables.trackingName = value
				RaidBuffs.savedVariables.numTracked = #RaidBuffs.savedVariables.tracking
				RaidBuffs.savedVariables.currRows = math.ceil(#RaidBuffs.savedVariables.tracking / 2)
			end,
			requiresReload = true
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

