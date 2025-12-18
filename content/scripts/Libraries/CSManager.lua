local Settings = UserSettings()
local GameSettings = Settings.GameSettings
local YearSettingEnum = GameSettings.YearSetting.Value
local scriptContext = game:GetService("ScriptContext")
local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
local RobloxGuiBackup = game:GetService("CoreGui"):WaitForChild("RobloxGuiBackup")
local ContextActionService = game:GetService("ContextActionService")
local modules = RobloxGui:FindFirstChild("Modules")

CSManager = {}


CSManager.keep = {
	Modules = true,
	Sounds = true
}

CSManager.CurrentCoreScript = nil

CSManager.switchgui = function(yearenum)
	CSManager.loadgui(yearenum)
end

CSManager.loadgui = function (yearenum)
	if CSManager.switch[yearenum] then
		CSManager.clearcoregui()
	    CSManager.switch[yearenum]()
	else
	    CSManager.switch["default"]()
	end
end

CSManager.clearcoregui = function()

	--settingshub = require(game:GetService("CoreGui"):WaitForChild("RobloxGui").Modules.Settings.SettingsHub

	for _, child in ipairs(RobloxGui:GetChildren()) do
		if not CSManager.keep[child.Name] then
			child:Destroy()
		end
	end
	
	local controls = Instance.new("Frame")
	controls.Name = "ControlFrame"
	controls.BackgroundTransparency = 1
	controls.Size = UDim2.new(1, 0, 1, 0)
	controls.Parent = RobloxGui

	local bottomLeftControl = Instance.new("Frame")
	bottomLeftControl.Size = UDim2.new(0, 130, 0, 46)
	bottomLeftControl.Position = UDim2.new(0, 0, 1, -46)
	bottomLeftControl.BackgroundTransparency = 1
	bottomLeftControl.Name = "BottomLeftControl"
	bottomLeftControl.Parent = controls

	local bottomRightControl = Instance.new("Frame")
	bottomRightControl.Size = UDim2.new(0, 180, 0, 41)
	bottomRightControl.Position = UDim2.new(1, -180, 1, -41)
	bottomRightControl.BackgroundTransparency = 1
	bottomRightControl.Name = "BottomRightControl"
	bottomRightControl.Parent = controls

	local topLeftControl = Instance.new("Frame")
	topLeftControl.Size = UDim2.new(0.05, 0, 0.05, 0)
	topLeftControl.BackgroundTransparency = 1
	topLeftControl.Name = "TopLeftControl"
	topLeftControl.Parent = controls

	ContextActionService:UnbindCoreAction("RBXEscapeMainMenu")
	ContextActionService:UnbindCoreAction("Open Dev Console")
	ContextActionService:UnbindCoreAction("RbxSettingsHubSwitchTab")
	ContextActionService:UnbindCoreAction("RbxSettingsScrollHotkey")
	ContextActionService:UnbindCoreAction("RbxSettingsHubStopCharacter")
	
end


CSManager.switch = {
	[0] = function()
		if CSManager.CurrentCoreScript == 0 then return end
		print("Loading 2016 CoreScripts")
		scriptContext:AddCoreScriptLocal("CoreScripts/2016/StarterScript", RobloxGui)
		CSManager.CurrentCoreScript = 0
		YearSettingEnum = 0
	end,
	[1] = function()
		if CSManager.CurrentCoreScript == 1 then return end
		print("Loading 2015 CoreScripts")
		scriptContext:AddCoreScriptLocal("CoreScripts/2015/StarterScript", RobloxGui)
		CSManager.CurrentCoreScript = 1
		YearSettingEnum = 1
	end,
	[2] = function()
		print("Loading 2014 CoreScripts")
		if CSManager.CurrentCoreScript == 2 then return end
		scriptContext:AddCoreScriptLocal("CoreScripts/2014/StarterScript", RobloxGui)
		CSManager.CurrentCoreScript = 2
		YearSettingEnum = 2
	end,
	[3] = function()
		print("Loading 2013 CoreScripts")
		if CSManager.CurrentCoreScript == 3 then return end
		scriptContext:AddCoreScriptLocal("CoreScripts/2013/StarterScript", RobloxGui)
		CSManager.CurrentCoreScript = 3
		YearSettingEnum = 3
	end,
	["default"] = function()
		if CSManager.CurrentCoreScript == 0 then return end
		print("Falling back to 2016 CoreScripts!") 
		scriptContext:AddCoreScriptLocal("CoreScripts/2016/StarterScript", RobloxGui)
		CSManager.CurrentCoreScript = 0
		YearSettingEnum = 0
	end
}

return CSManager