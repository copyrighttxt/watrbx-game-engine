local Settings = UserSettings()
local GameSettings = Settings.GameSettings
local YearSettingEnum = GameSettings.YearSetting.Value
local scriptContext = game:GetService("ScriptContext")
local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
local Backup = RobloxGui:Clone()
Backup.Name = "RobloxGuiBackup"
Backup.Parent = game:GetService("CoreGui")

local switch = {
	[0] = function()
		scriptContext:AddCoreScriptLocal("CoreScripts/2016/LoadingScript", RobloxGui)
	end,
	[1] = function()
		scriptContext:AddCoreScriptLocal("CoreScripts/2015/LoadingScript", RobloxGui)
	end,
	[2] = function()
		scriptContext:AddCoreScriptLocal("CoreScripts/2014/LoadingScript", RobloxGui)
	end,
	[3] = function()
		scriptContext:AddCoreScriptLocal("CoreScripts/2013/LoadingScript", RobloxGui)
	end,
	["default"] = function() 
		scriptContext:AddCoreScriptLocal("CoreScripts/2016/LoadingScript", RobloxGui)
	end
}

if switch[YearSettingEnum] then
   switch[YearSettingEnum]()
else
   switch["default"]()
end